ames_train %>%
  filter(Neighborhood == "Landmark")

ames_zv <- ames_train %>%
  filter(Neighborhood != "Landmark")

recipe(
  Sale_Price ~ Longitude + Latitude + Neighborhood,
  data = ames_zv
) %>%
  step_log(Sale_Price, base = 10) %>%
  step_dummy(all_nominal()) %>%
  prep(training = ames_zv) %>%
  juice() %>%
  select(Neighborhood_Landmark) %>%
  count(Neighborhood_Landmark)

recipe(
    Sale_Price ~ Longitude + Latitude + Neighborhood,
    data = ames_zv
  ) %>%
  step_log(Sale_Price, base = 10) %>%
  step_dummy(all_nominal()) %>%
  step_zv(contains("Neighborhood")) %>%
  prep(training = ames_zv) %>%
  juice()
