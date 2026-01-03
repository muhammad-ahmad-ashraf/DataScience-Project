
library(caret)
library(ranger)   # faster + often better RF than randomForest
library(e1071)    # SVM backend
library(nnet)     # multinom
library(dplyr)
library(readr)
library(recipes)
library(themis)
library(MLmetrics)

# ---- Load data ----
df <- read_csv("data_cleaning_transformation_phase/outputs/Cleaned_new_main_dataset.csv")

# ---- Choose columns (target = Breach_Severity) ----
df_model <- df %>%
  select(Attack_Type, Target_Sector, Breach_Duration, Year, Breach_Severity) %>%
  na.omit()

# ---- Ensure correct types ----
df_model$Attack_Type      <- as.factor(df_model$Attack_Type)
df_model$Target_Sector    <- as.factor(df_model$Target_Sector)
df_model$Breach_Severity  <- as.factor(df_model$Breach_Severity)

# (Optional but good) Drop rare severity levels if any have too few rows:
# df_model <- df_model %>% filter(Breach_Severity %in% names(which(table(Breach_Severity) >= 10)))

# ---- Train/Test Split 70/30 (stratified) ----
set.seed(123)
idx <- createDataPartition(df_model$Breach_Severity, p = 0.70, list = FALSE)
train_data <- df_model[idx, ]
test_data  <- df_model[-idx, ]

# ---- Preprocess recipe: one-hot + scale + (optional) SMOTE ----
# SMOTE helps when classes are imbalanced (recommended given your accuracy)
rec <- recipe(Breach_Severity ~ ., data = train_data) %>%
  step_dummy(all_nominal_predictors(), one_hot = TRUE) %>%
  step_zv(all_predictors()) %>%
  step_center(all_numeric_predictors()) %>%
  step_scale(all_numeric_predictors()) %>%
  step_smote(Breach_Severity)  # remove this line if you do NOT want SMOTE

prep_rec <- prep(rec, training = train_data)

train_pp <- bake(prep_rec, new_data = NULL)
test_pp  <- bake(prep_rec, new_data = test_data)

# ---- Train control (CV for model selection) ----
ctrl <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 2,
  classProbs = TRUE,
  summaryFunction = multiClassSummary,
  savePredictions = "final"
)

metric_used <- "Accuracy"   # you can also use "Kappa"

# ============================================================
# Train models (same preprocessed training set)
# ============================================================

set.seed(123)
m_multinom <- train(
  Breach_Severity ~ .,
  data = train_pp,
  method = "multinom",       # multinomial logistic regression
  trControl = ctrl,
  metric = metric_used,
  trace = FALSE
)

set.seed(123)
m_svm <- train(
  Breach_Severity ~ .,
  data = train_pp,
  method = "svmRadial",
  trControl = ctrl,
  metric = metric_used,
  tuneLength = 8
)

set.seed(123)
m_knn <- train(
  Breach_Severity ~ .,
  data = train_pp,
  method = "knn",
  trControl = ctrl,
  metric = metric_used,
  tuneLength = 15
)

set.seed(123)
m_rf <- train(
  Breach_Severity ~ .,
  data = train_pp,
  method = "ranger",         # random forest (fast)
  trControl = ctrl,
  metric = metric_used,
  tuneLength = 10,
  importance = "impurity"
)

# ---- Compare CV performance ----
models <- list(
  Multinomial_Regression = m_multinom,
  SVM_Radial = m_svm,
  KNN = m_knn,
  Random_Forest = m_rf
)

res <- resamples(models)
print(summary(res))
print(res$values)  # detailed per-resample metrics

# ---- Pick best model by Accuracy ----
cv_table <- summary(res)$statistics$Accuracy
cv_table <- data.frame(Model = rownames(cv_table), MeanAccuracy = cv_table[,"Mean"])
cv_table <- cv_table[order(-cv_table$MeanAccuracy), ]
print(cv_table)

best_model_name <- cv_table$Model[1]
cat("\nBEST MODEL (CV):", best_model_name, "\n")

best_model <- models[[best_model_name]]

# ============================================================
# Final evaluation on 30% holdout test set
# ============================================================

pred_test <- predict(best_model, newdata = test_pp)
cm <- confusionMatrix(pred_test, test_pp$Breach_Severity)

print(cm)

# ---- Extra: class-wise metrics ----
# cm$byClass  # precision/recall/F1 per class (multiclass shows matrix)

# ============================================================
# (Optional) Feature importance if best model is RF
# ============================================================
if (best_model_name == "Random_Forest") {
  print(varImp(best_model))
}
