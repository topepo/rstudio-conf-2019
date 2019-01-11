## ----startup, include = FALSE, message = FALSE, warning = FALSE----------
options(digits = 3, width = 110)
library(tidymodels)

## ----pipeline-ex, eval = FALSE-------------------------------------------
## data(credit_data)
## 
## imputer <-
##   recipe(Status ~ ., data = credit_data) %>%
##   step_knnimpute(Home, Marital, Job, Income, Assets, Debt) %>%
##   step_downsample(Status)
## 
## credit_pln <-
##   pipeline() %>%
##   add_recipe(imputer) %>%
##   add_model(logistic_reg() %>% set_engine("glmnet")) %>%
##   add_cutoff(0.25)
## 
## trained <- fit(credit_pln, training = credit_data)
## 
## predict(credit_pln, new_data = new_customer)

## ----pipeline-varying, eval = FALSE--------------------------------------
## imputer <-
##   recipe(Status ~ ., data = credit_data) %>%
##   step_knnimpute(Home, Marital, Job,
##                  Income, Assets, Debt,
##                  neighbors = varying()) %>%
##   step_downsample(Status)
## 
## mod <-
##   logistic_reg(
##     mixture = varying(),
##     penalty = varying()
##   ) %>%
##   set_engine("glmnet")
## 
## credit_pln <-
##   pipeline() %>%
##   add_recipe(imputer) %>%
##   add_model(mod) %>%
##   add_cutoff(threshold = varying())

## ----pipeline-varying-call, eval = FALSE---------------------------------
## varying_args(credit_pln)

## ----varying-output, echo = FALSE----------------------------------------
tribble(
  ~name, ~varying, ~id, ~type,
  "neighbors", TRUE,    "step_knnimpute",  "step" ,
  "penalty", TRUE,    "model",   "model_spec",
  "mixture", TRUE,    "model",   "model_spec",
  "threshold", TRUE, "cutoff", "cutoff"
)

## ----tuning-ex, eval = FALSE---------------------------------------------
## resamp <- vfold_cv(credit_data)
## 
## grid_search(credit_pln, resamp, levels = 5)
## 
## # or
## grid_racing(credit_pln, resamp, levels = 5, initial = 3)
## 
## # or
## rnd_param <- random_search(credit_pln, resamp, size = 25)
## 
## # and/or
## bayes_search(credit_pln, resamp, initial = rnd_param, num_iter = 20)
## 
## # Loop back to the pipeline to update
## finalized_pln <-
##   update(credit_pln, param_best(bayes_search)) %>%
##   fit(training = credit_data)

