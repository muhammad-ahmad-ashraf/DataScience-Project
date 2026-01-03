
library(xgboost)
library(Matrix)
library(dplyr)
library(readr)

# ---- Load data ----
df <- read_csv("data_cleaning_transformation_phase/outputs/Cleaned_new_main_dataset.csv")

df_model <- df %>%
  select(
    Year, Breach_Month, Breach_Quarter,
    Attack_Type, Attack_Vector, Vulnerability,
    Detection_Method, System_Affected,
    Origin_Country, Target_Country, Target_Sector,
    Breach_Duration_Days
  ) %>%
  na.omit()

# Ensure target is numeric
df_model$Breach_Duration_Days <- as.numeric(df_model$Breach_Duration_Days)

# Convert chars to factor (so model.matrix can one-hot encode)
df_model <- df_model %>% mutate(across(where(is.character), as.factor))

# ---- Train/Test split 70/30 ----
set.seed(123)
n <- nrow(df_model)
train_idx <- sample(seq_len(n), size = floor(0.7 * n))
train <- df_model[train_idx, ]
test  <- df_model[-train_idx, ]

# ---- One-hot encode (sparse matrix, memory efficient) ----
x_train <- sparse.model.matrix(Breach_Duration_Days ~ . - 1, data = train)
y_train <- train$Breach_Duration_Days

x_test  <- sparse.model.matrix(Breach_Duration_Days ~ . - 1, data = test)
y_test  <- test$Breach_Duration_Days

dtrain <- xgb.DMatrix(data = x_train, label = y_train)
dtest  <- xgb.DMatrix(data = x_test,  label = y_test)

# ---- XGBoost parameters (good defaults for regression) ----
params <- list(
  objective = "reg:squarederror",
  eval_metric = "rmse",
  eta = 0.05,
  max_depth = 6,
  subsample = 0.85,
  colsample_bytree = 0.85,
  min_child_weight = 5
)

# ---- Train with early stopping (prevents overfit + saves time) ----
set.seed(123)
xgb_model <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 2000,
  watchlist = list(train = dtrain, test = dtest),
  early_stopping_rounds = 50,
  verbose = 1
)

# ---- Predict ----
pred <- predict(xgb_model, dtest)

# ---- Metrics: RMSE, MAE, R^2 ----
rmse <- sqrt(mean((pred - y_test)^2))
mae  <- mean(abs(pred - y_test))
r2   <- 1 - sum((y_test - pred)^2) / sum((y_test - mean(y_test))^2)

cat("\n===== TEST METRICS =====\n")
cat("RMSE:", round(rmse, 3), "\n")
cat("MAE :", round(mae, 3), "\n")
cat("R^2 :", round(r2, 3), "\n")

# ---- Feature importance (top predictors) ----
imp <- xgb.importance(model = xgb_model)
print(head(imp, 20))






