## Section 2: Max (Day 1 Morning)

library(tidyverse)
theme_set(theme_bw())

library(AmesHousing)
ames <- make_ames()

ames %>%
  group_by(Pool_QC) %>%
  count()

table(ames$Overall_Cond, ames$Overall_Qual)


ggplot(ames, aes(x = reorder(Neighborhood, Sale_Price), y = Sale_Price)) +
  geom_violin() +
  scale_y_log10() +
  coord_flip()

ames %>%
  group_by(Neighborhood) %>%
  count() %>%
  ggplot(aes(x = Neighborhood, y = n)) +
  geom_bar(stat = "identity") +
  coord_flip()

ggplot(data = ames, aes(x = Sale_Price)) +
  geom_line(stat = "density") +
  geom_rug()


# Part 2 hands-on

ggplot(simple_lm_values,
       aes(x = .fitted, y = log10.Sale_Price.)) +
  geom_point(alpha = .5) +
  geom_abline(col = "red")

ggplot(simple_lm_values,
       aes(x = .fitted, y = .resid)) +
  geom_point(alpha = .5)

ggplot(simple_lm_values,
       aes(x = Longitude, y = .resid)) +
  geom_point(alpha = .5)

ggplot(simple_lm_values,
       aes(x = .hat, y = .resid)) +
  geom_point(alpha = .5)


linear_reg() %>% set_engine("stan", chains = 10) %>% translate()

## Section 2 (Alex - Day 1 Afternoon)

cv_splits <- vfold_cv(
  data = ames_train,
  v = 10,
  strata = "Sale_Price"
)

cv_splits %>% slice(1:6)

ggplot(holdout_results, aes(First_Flr_SF, .resid)) +
  geom_point() +
  geom_smooth()

x <- list(1, 2, 3)
map(x, paste)

y <- list("A", "B", "C")

f <- function(u, v) paste(u, v)
map2(x, y, f,)

model.matrix(Sepal.Length ~ Species, data = iris)










