# Data Science Project

## Project: Cybersecurity Breach Data Analysis

This project focuses on exploring and cleaning a real-world **Cybersecurity Breach Dataset** to identify trends, patterns, and insights related to data breaches across different organizations and states.

---

## Dataset Overview

- **Dataset Name:** Cyber Security Breaches
- **Source:** [Publicly available on kaggle](https://www.kaggle.com/datasets/alukosayoenoch/cyber-security-breaches-data/data)
- **File Used:** `data/main_dataset.csv`

### 🔍 Key Columns
| Column | Description |
|---------|-------------|
| **ID** | Unique identifier for each breach record |
| **Name_of_Covered_Entity** | Organization affected by the breach |
| **State** | U.S. state where the entity is located |
| **Business_Associate_Involved** | Indicates if a third-party associate was involved |
| **Individuals_Affected** | Number of people impacted by the breach |
| **Date_of_Breach** | Date when the breach occurred |
| **Type_of_Breach** | Nature of the breach (e.g., Theft, Loss, Hacking/IT Incident) |
| **Location_of_Breached_Information** | Where the data was stored (e.g., Laptop, Network Server) |
| **Date_Posted_or_Updated** | When the incident was reported or last updated |

---

## Data Cleaning Summary

During the data preparation phase, multiple cleaning operations were performed to ensure data consistency and usability.

### Key Steps Performed
1. **Dropped Unnecessary Columns**
   - Removed redundant or irrelevant columns such as:
     - `Unnamed: 0` (auto-generated index)
     - `Business_Associate_Involved` (mostly `Unknown` values)

2. **Renamed Columns**
   - Changed `Number` → `ID` for clarity and consistency.

3. **Handled Missing Values**
   - Columns with **>80% missing values** were dropped (e.g., `Breach End Date`).
   - For categorical variables → missing values filled with `"Unknown"`.
   - For numeric variables → missing values filled with **median**.

4. **Removed Duplicates**
   - Ensured dataset integrity by removing any duplicate rows.

5. **Converted Data Types**
   - Converted date columns (`Date_of_Breach`, `Date_Posted_or_Updated`, `breach_start`) into `datetime` format.
   - Converted relevant columns to `category` type for encoding and analysis efficiency.

---

## Data Transformation

Transformation involves feature creation, encoding, and aggregation.

### Steps Included
1. **Fixed Missing Breach Dates**
   - Filled missing `Date_of_Breach` values using `breach_start` or `year` fields.

2. **Derived Temporal Features**
   - Extracted `Breach_Month` and `Breach_Quarter` from the breach date for time-based analysis.

3. **Encoded Categorical Variables**
   - Applied **Label Encoding** to convert categorical columns (e.g., `State`, `Type_of_Breach`, etc.) into numeric form for ML compatibility.

4. **Aggregation for Insights**
   - Created summary metrics like:
     ```text
     Average Individuals Affected per Type of Breach
     ```
   - This helps understand which breach types cause the most damage.

---

## Example Output Columns After Transformation
| Column | Example Value |
|---------|----------------|
| Name_of_Covered_Entity | Brooke Army Medical Center |
| State | TX |
| Individuals_Affected | 1000 |
| Date_of_Breach | 2009-10-16 |
| Type_of_Breach | Theft |
| Location_of_Breached_Information | Paper |
| Breach_Month | 10 |
| Breach_Quarter | 4 |
| State_Encoded | 44 |
| Type_of_Breach_Encoded | 11 |

---

## Project Outputs

- **Cleaned Dataset Saved To:**  
  `outputs/cleaned/Cleaned_main_dataset.csv`

- **Main Script:**  
  `scripts/datacleaning_transformation.py`

---

## Tools & Libraries Used

- **Python 3.12+**
- **Pandas** → Data manipulation  
- **NumPy** → Numeric operations  
- **Matplotlib / Seaborn** → Visualization  
- **scikit-learn** → Label Encoding and preprocessing  

---

## Key Insights

- Majority of breaches are related to **Theft** and **Loss**.  
- Certain states report a **higher frequency** of breaches.  
- The number of individuals affected varies widely, showing the **impact diversity** among breach types.

---

> “Clean data is the foundation of powerful insights.” – Data Science Principle
