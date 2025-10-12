import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import StandardScaler

# Load dataset
df = pd.read_csv("data/main_dataset.csv")

print(df.info())
print(df.describe())
print(df.head(10))

# Rename column
df.rename(columns={'Number': 'ID'}, inplace=True)

# Handling Missing Values

# #Missing values per column
print(df.isnull().sum())

missing_percent = (df.isnull().sum() / len(df)) * 100
columns_to_drop = missing_percent[missing_percent > 80].index
df.drop(columns=columns_to_drop, inplace=True)
print(f"\nDropped columns with >80% missing values: {list(columns_to_drop)}")

for col in df.select_dtypes(include='object').columns:
    df[col] = df[col].fillna("Unknown")

for col in df.select_dtypes(include=np.number).columns:
    df[col] = df[col].fillna(df[col].median())
print("\nMissing values after cleaning:")
print(df.isnull().sum())

# Checking Duplicates
duplicates = df.duplicated().sum()
print(f"\nDuplicate rows before cleaning: {duplicates}")

df = df.drop_duplicates()
print("✅ Duplicates removed successfully!")


#DataType Conversions

if 'year' in df.columns:
    df['year'] = pd.to_datetime(df['year'], format='%Y', errors='coerce')

for col in ['Date_of_Breach', 'Date_Posted_or_Updated', 'breach_start', 'breach_end']:
    if col in df.columns:
        df[col] = pd.to_datetime(df[col], errors='coerce')

cat_cols = ['Name_of_Covered_Entity', 'State', 'Type_of_Breach', 
            'Location_of_Breached_Information', 'Business_Associate_Involved']
for col in cat_cols:
    if col in df.columns:
        df[col] = df[col].astype('category')

# Dropping column
columns_to_drop = [
    'Unnamed: 0',
    "Business_Associate_Involved"      
]
df.drop(columns=[col for col in columns_to_drop if col in df.columns], inplace=True, errors='ignore')

#Transformation
if 'Date_of_Breach' in df.columns:
    if 'breach_start' in df.columns:
        df['Date_of_Breach'] = df['Date_of_Breach'].fillna(df['breach_start'])
    elif 'year' in df.columns:
        df['Date_of_Breach'] = df.apply(
            lambda x: pd.Timestamp(year=x['year'].year, month=1, day=1)
            if pd.isna(x['Date_of_Breach']) else x['Date_of_Breach'], axis=1
        )

df.drop(columns=['breach_start'], inplace=True)

if 'Date_of_Breach' in df.columns:
    df['Breach_Month'] = df['Date_of_Breach'].dt.month
    df['Breach_Quarter'] = df['Date_of_Breach'].dt.quarter

    df['Breach_Month'] = df['Breach_Month'].fillna(df['Breach_Month'].mode()[0])
    df['Breach_Quarter'] = df['Breach_Quarter'].fillna(df['Breach_Quarter'].mode()[0])

le = LabelEncoder()
for col in df.select_dtypes(include='category').columns:
    df[col + "_Encoded"] = le.fit_transform(df[col].astype(str))

if 'Type_of_Breach' in df.columns:
    breach_summary = (
        df.groupby('Type_of_Breach', observed=False)['Individuals_Affected']
        .mean()
        .reset_index()
        .rename(columns={'Individuals_Affected': 'Avg_Individuals_Affected'})
    )

    print("\n📊 Average Individuals Affected per Breach Type:")
    print(breach_summary.head())

# Verify Cleaned Dataset

print("\nFinal Dataset Info:")
print(df.info())
print("\nSample of Cleaned Data:")
print(df.head())

#  Save Cleaned Data

df.to_csv("outputs/Cleaned_main_dataset.csv", index=False)
print("\n✅ Cleaned dataset saved ")