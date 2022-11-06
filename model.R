library(tidymodels)
library(doParallel)
library(themis)

set.seed(123) # We avoid that every time we run the results vary (because they are random).

data = read.csv("resultados/final_data.csv")
data$attack = factor(data$attack)

 #divide between training and test files (cross validation)
files <-  unique(data$file)
test_files <- files[(length(files) - 2):length(files)] # only the last 3 files are used for testing the prediction
train_files <- files[1:(length(files) - 3)] # the rest are used in the model
trees_train <- filter(data, file %in% train_files)
trees_test <- filter(data, file %in% test_files)

trees_train$file = NULL
trees_test$file = NULL

tree_rec <- recipe(attack ~ ., data = trees_train) %>%
  step_upsample() # data balancing

tune_spec <- rand_forest( # creating the random forest function
  mtry = tune(),
  trees = tune(),
  min_n = tune()
) %>%
  set_mode("classification") %>%
  set_engine("ranger")

tune_wf <- workflow() %>% 
  add_recipe(tree_rec) %>%
  add_model(tune_spec)

trees_folds <- vfold_cv(trees_train) # Cross validation of the model data (10 folds)

doParallel::registerDoParallel() # (buffer)

set.seed(345) 
tune_res <- tune_grid( # tuning the model( especifying the number of trees and folds)
  tune_wf,
  resamples = trees_folds,
  grid = 20 # optimal number of trees per time and accuracy  
)


best_auc <- select_best(tune_res, "roc_auc") # from the 20 model results, the best one is selected
final_wf <- finalize_workflow(
  tune_wf,
  best_auc
)


final_res <- final_wf %>% fit(trees_train)

preds_df <- final_res %>% predict(trees_test) %>% bind_cols("truth"=trees_test$attack)

print(
  conf_mat(preds_df, truth = truth, estimate = .pred_class) #confusion matrix is generated
)


# REFERENCES: 
# https://juliasilge.com/blog/sf-trees-random-tuning/
# https://themis.tidymodels.org/reference/step_upsample.html
