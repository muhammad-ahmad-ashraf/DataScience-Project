# ==============================
# Cyber Attack Flow Map (Origin -> Target)
# ==============================

library(tidyverse)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(geosphere)

# -----------------------------
# 1) Load
# -----------------------------
df <- readr::read_csv("data_cleaning_transformation_phase/outputs/Cleaned_new_main_dataset.csv")

# -----------------------------
# 2) Flows (top N)
# -----------------------------
flows <- df %>%
  filter(!is.na(Origin_Country), !is.na(Target_Country)) %>%
  count(Origin_Country, Target_Country, name = "attacks") %>%
  arrange(desc(attacks)) %>%
  slice_head(n = 80)

# -----------------------------
# 3) World + centroids
# -----------------------------
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")

centroids <- world %>%
  st_centroid(of_largest_polygon = TRUE) %>%
  mutate(lon = st_coordinates(.)[,1],
         lat = st_coordinates(.)[,2]) %>%
  st_drop_geometry() %>%
  select(name_long, lon, lat)

country_fix <- function(x) {
  x <- str_trim(x)
  recode(x,
         "USA" = "United States",
         "UK"  = "United Kingdom",
         "UAE" = "United Arab Emirates",
         "Russia" = "Russian Federation",
         "South Korea" = "Korea, Republic of",
         .default = x)
}

flows <- flows %>%
  mutate(
    Origin_Country = country_fix(Origin_Country),
    Target_Country = country_fix(Target_Country)
  )

flow_xy <- flows %>%
  left_join(centroids, by = c("Origin_Country" = "name_long")) %>%
  rename(o_lon = lon, o_lat = lat) %>%
  left_join(centroids, by = c("Target_Country" = "name_long")) %>%
  rename(t_lon = lon, t_lat = lat) %>%
  drop_na(o_lon, o_lat, t_lon, t_lat) %>%
  mutate(id = row_number())

# -----------------------------
# 4) Build smooth curves WITHOUT dateline ugly lines
#    (each dateline segment becomes its own group)
# -----------------------------
make_gc_segments <- function(o_lon, o_lat, t_lon, t_lat, n = 80) {
  pts <- geosphere::gcIntermediate(
    c(o_lon, o_lat), c(t_lon, t_lat),
    n = n, addStartEnd = TRUE, breakAtDateLine = TRUE
  )
  
  # If gcIntermediate returns multiple segments (list), keep segment IDs
  if (is.list(pts)) {
    segs <- purrr::imap_dfr(pts, ~{
      d <- as.data.frame(.x)
      colnames(d) <- c("lon", "lat")
      d$seg <- .y
      d
    })
    return(tibble::as_tibble(segs))
  } else {
    d <- as.data.frame(pts)
    colnames(d) <- c("lon", "lat")
    d$seg <- 1
    return(tibble::as_tibble(d))
  }
}

lines_df <- flow_xy %>%
  rowwise() %>%
  mutate(path = list(make_gc_segments(o_lon, o_lat, t_lon, t_lat, n = 90))) %>%
  ungroup() %>%
  tidyr::unnest(path) %>%
  mutate(group_id = interaction(id, seg, drop = TRUE))

# -----------------------------
# 5) BEAUTIFUL PLOT (like 2nd picture)
# -----------------------------
ggplot() +
  # light ocean background
  theme_void() +
  theme(
    plot.background  = element_rect(fill = "#d9eefc", color = NA),
    panel.background = element_rect(fill = "#d9eefc", color = NA),
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5, color = "#053b5c")
  ) +
  
  # land
  geom_sf(data = world, fill = "white", color = "#bcd7ea", linewidth = 0.25) +
  
  # glow line (thick)
  geom_path(
    data = lines_df,
    aes(x = lon, y = lat, group = group_id, linewidth = attacks),
    color = "#6cc6ff", alpha = 0.25, lineend = "round"
  ) +
  # main line (thin bright)
  geom_path(
    data = lines_df,
    aes(x = lon, y = lat, group = group_id, linewidth = attacks),
    color = "darkblue", alpha = 0.75, lineend = "round"
  ) +
  
  # points (small, clean)
  geom_point(
    data = flow_xy,
    aes(x = o_lon, y = o_lat, size = attacks),
    color = "#2aa9ff", alpha = 0.55
  ) +
  geom_point(
    data = flow_xy,
    aes(x = t_lon, y = t_lat, size = attacks),
    color = "#2aa9ff", alpha = 0.55
  ) +
  
  scale_linewidth(range = c(0.2, 1.6)) +
  scale_size(range = c(0.6, 2.2)) +
  coord_sf(expand = FALSE) +
  ggtitle("Global Cyber Attack Flows (Origin → Target)")

