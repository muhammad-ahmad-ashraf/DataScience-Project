
library(dplyr)     
library(readr)      
library(lubridate)  

df <- read_csv("data_cleaning_transformation_phase/data/new_dataset.csv")

glimpse(df)
summary(df)
head(df, 10)

sum(is.na(df))

colSums(is.na(df))

missing_percent <- colSums(is.na(df)) / nrow(df) * 100
cols_to_drop <- names(missing_percent[missing_percent > 80])
df <- df %>% select(-all_of(cols_to_drop))
cat("Dropped columns with >80% missing values:", cols_to_drop, "\n")

cat_cols <- names(df)[sapply(df, is.character)]
df <- df %>% mutate(across(all_of(cat_cols), ~ifelse(is.na(.), "Unknown", .)))

num_cols <- names(df)[sapply(df, is.numeric)]
df <- df %>% mutate(across(all_of(num_cols), ~ifelse(is.na(.), median(., na.rm=TRUE), .)))

colSums(is.na(df))

dup_count <- sum(duplicated(df))
cat("Duplicate rows before cleaning:", dup_count, "\n")

df <- df %>% distinct()
cat("Duplicates removed successfully!\n")

date_cols <- c("Breach_Start_Date", "Breach_End_Date")
df <- df %>% mutate(across(all_of(date_cols), ~as.Date(., format="%Y-%m-%d")))

df <- df %>% mutate(
  Breach_Month = month(Breach_Start_Date),
  Breach_Quarter = quarter(Breach_Start_Date)
)

df <- df %>%
  mutate(
    Breach_Duration = as.numeric(Breach_End_Date - Breach_Start_Date) + 1  # +1 to include start date
  )


df <- df %>% mutate(Year = as.integer(Year))
df <- df %>% mutate(Breach_Month = as.integer(Breach_Month))


cat_cols <- c("Attack_Type", "Attack_Vector", "Vulnerability", "Detection_Method",
              "System_Affected", "Breach_Severity", "How_Resolved",
              "Origin_Country", "Target_Country", "Target_Sector")
df <- df %>% mutate(across(all_of(cat_cols), as.factor))



avg_duration <- df %>%
  group_by(Attack_Type) %>%
  summarise(
    Avg_Duration = mean(Breach_Duration, na.rm = TRUE),
    Count = n()
  ) %>%
  arrange(desc(Avg_Duration))

write_csv(df, "data_cleaning_transformation_phase/outputs/Cleaned_main_dataset.csv")





