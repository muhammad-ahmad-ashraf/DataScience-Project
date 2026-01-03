# Data Science Project  
## Cybersecurity Breach Data Analysis

This project analyzes a real-world **Cybersecurity Breach Dataset** to explore patterns, trends, and predictive factors associated with cyber-attacks, breach durations, and global attack flows.

---

##  Dataset Overview

- **Dataset Name:** Cyber Security Breaches  
- **Source:** Kaggle  
- **File Used:** `Cleaned_new_main_dataset.csv`

### Key Columns

| Column | Description |
|-------|-------------|
| Attack_Type | Category of cyber-attack |
| Origin_Country | Attacker source country |
| Target_Country | Victim country |
| Target_Sector | Industry affected |
| Breach_Duration_Days | Length of breach |
| Detection_Method | How the breach was detected |
| System_Affected | Infrastructure impacted |
| Breach_Month / Breach_Quarter / Year | Temporal attributes |

---

## Data Cleaning & Transformation

- Removed null values and duplicate records.  
- Standardized country names and categorical labels.  
- Converted date columns into numeric temporal features.  
- Derived new features: `Breach_Month`, `Breach_Quarter`, `Breach_Duration_Days`.  
- Converted all categorical variables to factors for modeling.

---

## Exploratory Data Analysis (EDA)

The following analyses were performed:

- Distribution of **Attack Types**  
- Relationship between **Breach Severity and Duration**  
- **Target Sector vs Attack Type** frequency analysis  
- **Monthly Breach Trends**  
- **Average Breach Duration** by Attack Type and Sector  
- Heatmap of **Severity vs Target Sector**

### Key Insights

- *Ransomware* and *Zero-Day Exploits* cause the longest breaches.  
- *Manufacturing* and *Finance* sectors are the most targeted.  
- Breaches peak between **March and August**.

---

## Predictive Modeling

### Task  
**Predict Breach Duration (Regression)**

### Model Used  
**XGBoost Regression**

| Metric | Value |
|------|-------|
| RMSE | 3.31 Days |
| MAE | 2.73 Days |
| R² | 0.48 |

### Most Influential Features

- Year  
- Breach_Month  
- Detection_Method  
- Attack_Type  
- Target_Sector  

---

## Cyber Attack Flow Visualization

A global flow-map was created showing:

**Origin_Country → Target_Country attack routes**

### Features

- Curved great-circle attack arcs  
- Glow-effect cyber lines  
- ISO-code based country matching  
- Line thickness proportional to attack frequency  

---

## Tools & Libraries

- **R Language**  
- `tidyverse`, `sf`, `rnaturalearth`, `geosphere`  
- `xgboost` – machine learning  
- `ggplot2` – visualization  

---

## Final Conclusion

This project demonstrates that cybersecurity breaches are **measurable, pattern-driven, and predictable**.  
Temporal attributes, detection systems, and attack characteristics strongly influence breach duration, while global flow visualization reveals major international cyber-threat corridors.

> *Cybersecurity is not random — it follows patterns that data science can expose.*
