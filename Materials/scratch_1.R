theme_set(theme_bw())

holdout_results %>% 
  filter(Second_Flr_SF > 0) %>% 
  ggplot(aes(x = Second_Flr_SF, y = .resid)) + 
  geom_point(alpha =.5)  + 
  geom_smooth(se = FALSE)


holdout_results %>% 
  ggplot(aes(x = TotRms_AbvGrd, y = .resid)) + 
  geom_point(alpha =.5)  + 
  geom_smooth(se = FALSE)

holdout_results %>% 
  ggplot(aes(x = Lot_Area, y = .resid)) + 
  geom_point(alpha =.5)  + 
  geom_smooth(se = FALSE) + 
  scale_x_log10()


holdout_knn <- 
  cv_splits %>%
  unnest(pred_knn) %>%
  mutate(.resid = Sale_Price_Log - .pred)


holdout_knn %>% 
  ggplot(aes(x = Lot_Area, y = .resid)) + 
  geom_point(alpha =.5)  + 
  geom_smooth(se = FALSE) + 
  scale_x_log10()



