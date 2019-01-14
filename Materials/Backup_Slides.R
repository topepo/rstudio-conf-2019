# Slides for Applied Machine Learning workshop at 2019 RStudio ---
# Conference -----------------------------------------------------

# Backup Slides

#  Slide 3 -------------------------------------------------------

library(tidymodels)

# also will need

library(furrr)
library(rstanarm)
library(probably)
library(emo)


#  Slide 10 ------------------------------------------------------

make_fit <- function(recipe, ...) {
  logistic_reg() %>%
    set_engine("stan", chains = 4, cores = 1, QR = TRUE, init = 0, iter = 5000, seed = 25622) %>%
    fit(..., data = juice(recipe))
}

make_preds <- function(splits, recipes, models, ...) {
  # Get the dummy variables
  holdout <- bake(recipes, new_data = assessment(splits))
  holdout %>%
    bind_cols(predict(models, holdout %>% select(-Class), type = "class")) %>%
    bind_cols(predict(models, holdout %>% select(-Class), type = "prob")) %>%
    bind_cols(predict(models, holdout %>% select(-Class), type = "conf_int", std_error = TRUE)) %>%
    dplyr::select(Class, starts_with(".")) %>% 
    # Get information about the resample and the original data index
    mutate(
      resample = labels(splits) %>% pull(id),
      .row = as.integer(splits, data = "assessment")
    ) %>%
    as_tibble()
}

#  Slide 11 ------------------------------------------------------

load("Data/okc.RData")

keywords <- names(okc_train)[32:91]
okc_lr_train <- 
  okc_train %>%
  dplyr::select(Class, where_town, age, male, diet, 
                religion, education, !!!keywords)

dummies <- 
  recipe(Class ~ ., data = okc_lr_train) %>%
  step_dummy(all_nominal(), -Class) %>%
  step_downsample(Class) %>%
  step_zv(all_predictors())

# For parallel processing
# or plan("sequential")
# plan("multicore") # non-windows implementation 

set.seed(9798)
okc_splits <- 
  vfold_cv(okc_lr_train) %>%
  mutate(
    recipes =  map(splits, prepper, dummies),
    # The next line takes a long time to execute. 
    # It took 77 min using 10 cores for me. 
    models = future_map(recipes, make_fit, Class ~ .)
  ) %>%
  mutate(
    preds = pmap(., make_preds)
  )

#  Slide 12 ------------------------------------------------------

okc_tr_res <- 
  okc_splits %>%
  pull(preds) %>%
  bind_rows()

std_error_mod <-
  nls(
    .std_error ~ a * sqrt((.pred_stem) * (1 - .pred_stem)),
    data = okc_tr_res,
    start = list(a = .5)
  )

okc_tr_res <- 
  okc_tr_res %>%
  mutate(
    bl_std_error = predict(std_error_mod, .),
    fold = .std_error/bl_std_error,
    cut_point = 1.5 * bl_std_error
  )

ggplot(okc_tr_res, aes(x = .pred_stem, y = .std_error))  +
  geom_point(aes(col = Class), alpha = .3) +
  geom_line(aes(y = bl_std_error), col = rgb(0, 0, 0, .75), lty = 2) +
  ylab("Std Dev of Posterior") + 
  xlab("STEM Probability (Posterior Mean)")

#  Slide 14 ------------------------------------------------------

av_std_error <-
  nls(
    .std_error ~ a * 
      sqrt((.pred_stem) * 
             (1 - .pred_stem)),
    data = okc_tr_res,
    start = list(a = .5)
  )

okc_tr_res <- 
  okc_tr_res %>%
  mutate(
    exp_std_err = predict(av_std_error, .),
    fold_above = .std_error/exp_std_err
  )
okc_tr_res %>%
  dplyr::select(.pred_stem, .std_error, 
                exp_std_err, fold_above) %>%
  slice(1:8)

#  Slide 16 ------------------------------------------------------

okc_tr_res <- 
  okc_tr_res %>%
  mutate(
    in_eq_zone = 
      fold_above > 10 &
      (.pred_stem > 0.45 | .pred_stem < 0.55),
    new_pred  = 
      class_pred(.pred_class, which = which(in_eq_zone))
  )
okc_tr_res %>%
  dplyr::select(.pred_class, new_pred) %>% 
  slice(1:5)

okc_tr_res %>% pull(new_pred) %>% class()
okc_tr_res %>% pull(new_pred) %>% levels()
okc_tr_res %>% slice(1:6) %>% pull(new_pred) %>% as.factor()

#  Slide 17 ------------------------------------------------------

okc_tr_res %>% slice(1:5) %>% pull(new_pred)

okc_tr_res %>%
  summarise(reportable = reportable_rate(new_pred))

okc_tr_res %>%
  mutate(new_pred = as.factor(new_pred)) %>%
  kap(Class, new_pred)


#  Slide 19 ------------------------------------------------------

up <- ji("white_check_mark")
down <- ji("rage")

prec_example <- tibble(
  truth = factor(c(up, down, up, down, down), levels = c(up, down)),
  estimate = factor(c(up, down, up, up, down), levels = c(up, down))
)

prec_example

precision(prec_example, truth, estimate)

#  Slide 21 ------------------------------------------------------

eh <- ji("shrug")

prec_multi <- tibble(
  truth = factor(c(up, eh, up, down, down), levels = c(up, down, eh)),
  estimate = factor(c(up, down, up, eh, down), levels = c(up, down, eh))
)

prec_multi

precision(prec_multi, truth, estimate)

#  Slide 22 ------------------------------------------------------

precision(prec_multi, truth, estimate, estimator = "macro_weighted")

#  Slide 25 ------------------------------------------------------

library(tidymodels)
library(AmesHousing)
library(tidypredict)

ames <- make_ames() %>% 
  dplyr::select(-matches("Qu")) %>% 
  # Manually log the variables :-(
  mutate(
    Sale_Price = log10(Sale_Price),
    Lot_Area = log10(Lot_Area),
    Gr_Liv_Area = log10(Gr_Liv_Area)
  )

set.seed(4595)
data_split <- 
  initial_split(ames, strata = "Sale_Price")

ames_train <- training(data_split) 
ames_test  <- testing(data_split) 

ames_mod <- 
  lm(Sale_Price ~ Bldg_Type + Neighborhood + 
       Year_Built +  Gr_Liv_Area + 
       Full_Bath + Lot_Area + 
       Central_Air*Year_Sold,
     data = ames_train)

acceptable_formula(ames_mod) # Silence is golden here

ames_sql <- tidypredict_fit(ames_mod)

# Check against `lm()`:

tidypredict_test(ames_mod, ames_test)

#  Slide 26 ------------------------------------------------------

print(ames_sql)

tidypredict_sql(ames_mod, dbplyr::simulate_mssql()) %>% substr(1, 85)
