from_cran <- 
  c("AmesHousing", "caret", "doParallel", "e1071", "earth", "glmnet", "ipred", 
    "klaR", "kknn", "pROC", "rpart", "sessioninfo", "tidymodels")

install.packages(from_cran, repos = "http://cran.rstudio.com")

# check the installs:
for (pkg in from_cran)
  library(pkg, character.only = TRUE)

session_info()

if (!interactive())
  q("no")

