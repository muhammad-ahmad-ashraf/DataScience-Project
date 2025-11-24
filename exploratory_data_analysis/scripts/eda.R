
library(dplyr)
library(ggplot2)
library(lubridate)
library(readr)
library(corrplot)
library(tidyr)

df <- read_csv("data_cleaning_transformation_phase/outputs/Cleaned_main_dataset.csv")

# Count of breaches by Attack_Type
ggplot(df, aes(x = Attack_Type)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Number of Breaches by Attack Type", x = "Attack Type", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Breach Severity distribution
ggplot(df, aes(x = Breach_Severity)) +
  geom_bar(fill = "tomato") +
  labs(title = "Breach Severity Distribution", x = "Severity", y = "Count")

# Breach Duration distribution
ggplot(df, aes(x = Breach_Duration)) +
  geom_histogram(binwidth = 1, fill = "darkgreen", color = "black", alpha = 0.7) +
  labs(title = "Distribution of Breach Duration (Days)", x = "Duration (Days)", y = "Frequency") +
  xlim(0, 30)


# Breaches by Target Sector
ggplot(df, aes(x = Target_Sector)) +
  geom_bar(fill = "orange") +
  labs(title = "Breaches by Target Sector", x = "Sector", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Breach Duration vs Severity
ggplot(df, aes(x = Breach_Severity, y = Breach_Duration)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Breach Duration by Severity", x = "Severity", y = "Duration (Days)")

# Attack_Type vs Avg Breach Duration
df %>%
  group_by(Attack_Type) %>%
  summarise(Avg_Duration = mean(Breach_Duration, na.rm = TRUE)) %>%
  ggplot(aes(x = reorder(Attack_Type, -Avg_Duration), y = Avg_Duration)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Average Breach Duration by Attack Type", x = "Attack Type", y = "Avg Duration (Days)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Target Sector vs Severity
ggplot(df, aes(x = Target_Sector, fill = Breach_Severity)) +
  geom_bar(position = "dodge") +
  labs(title = "Breach Severity by Target Sector", x = "Sector", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Heatmap of average duration by Severity and Target Sector
duration_matrix <- df %>%
  group_by(Breach_Severity, Target_Sector) %>%
  summarise(Avg_Duration = mean(Breach_Duration, na.rm = TRUE)) %>%
  tidyr::pivot_wider(names_from = Target_Sector, values_from = Avg_Duration, values_fill = 0)

duration_mat <- as.matrix(duration_matrix[,-1])
rownames(duration_mat) <- duration_matrix$Breach_Severity
corrplot::corrplot(duration_mat, method = "color", is.corr = FALSE, tl.col = "black", addCoef.col = "white")


# Breaches over time (monthly)
df %>%
  group_by(Year, Breach_Month) %>%
  summarise(Count = n()) %>%
  ggplot(aes(x = interaction(Year, Breach_Month, sep = "-"), y = Count, group = 1)) +
  geom_line(color = "blue") +
  geom_point() +
  labs(title = "Breaches Over Time (Monthly)", x = "Year-Month", y = "Number of Breaches") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


