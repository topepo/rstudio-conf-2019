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



