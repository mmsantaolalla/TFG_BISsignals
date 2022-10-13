library(tidymodels)
library(doParallel)
library(themis)

set.seed(123) # evitamos que cada vez que corremos al ser resultados aleatorios distintos

data = read.csv("resultados/final_data.csv")
data$attack = factor(data$attack)

 # seleccionar el archivo y la columna de la que se hace referencia
files <-  unique(data$file)
test_files <- files[(length(files) - 2):length(files)]
train_files <- files[1:(length(files) - 3)]
trees_train <- filter(data, file %in% train_files)
trees_test <- filter(data, file %in% test_files)

trees_train$file = NULL
trees_test$file = NULL

tree_rec <- recipe(attack ~ ., data = trees_train) %>% # hacer el estudio respecto a la columna attack (el resto respecto a la de referencia)
  step_upsample() # balanceamos datoss

tune_spec <- rand_forest( # creamos la funcion random forest
  mtry = tune(),
  trees = tune(),
  min_n = tune()
) %>%
  set_mode("classification") %>%
  set_engine("ranger")

tune_wf <- workflow() %>% # combinammos columna principal(attack) con el resto de columnas seleccionadas anteriormente
  add_recipe(tree_rec) %>%
  add_model(tune_spec)

trees_folds <- vfold_cv(trees_train) # llevamos a cabo la cross validation del estudio

doParallel::registerDoParallel() # (buffer)

set.seed(345) 
tune_res <- tune_grid( # generamos los foldings del arbol( seleccionamos un resultado de 20 muestras )
  tune_wf,
  resamples = trees_folds,
  grid = 20 # numero de muestras optimo por tiempo y accuracy  
)


best_auc <- select_best(tune_res, "roc_auc") # seleccionamos de los 20 modelos el mejor
final_wf <- finalize_workflow(
  tune_wf,
  best_auc
)


final_res <- final_wf %>% fit(trees_train)

preds_df <- final_res %>% predict(trees_test) %>% bind_cols("truth"=trees_test$attack)

print(
  conf_mat(preds_df, truth = truth, estimate = .pred_class)
)


# REFERENCIAS: 
# https://juliasilge.com/blog/sf-trees-random-tuning/
# https://themis.tidymodels.org/reference/step_upsample.html
