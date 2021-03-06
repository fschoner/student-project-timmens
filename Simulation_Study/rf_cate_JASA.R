rf_cate_JASA <- function(data, num_trees){
  
  df <- data
  df_part <- modelr::resample_partition(df, c(train = 0.5, test = 0.5))
  df_train <- as.data.frame(df_part$train)
  df_test <- as.data.frame(df_part$test)
  
  allX <- grep("^[X]", names(df), value=TRUE)
  
  set.seed(1001)
  cf <- grf::causal_forest(X = as.matrix(df_train[, allX]),
                           Y = as.matrix(df_train$Y_obs),
                           W = as.matrix(df_train$D),
                           num.trees = num_trees, # Make this larger for better acc.
                           num.threads = 1,
                           honesty = TRUE)
  cf_res <- predict(cf, as.matrix(df_test[, allX]), estimate.variance = TRUE)
  tauhatx_cf <- cf_res$predictions %>% as.numeric()
  
  MSE_cf <- mean((df_test$CATE - tauhatx_cf)^2)
  #MSE_cf <- MSE_fun(tauhatx_cf, df_test$CATE)
  cf_se <- mean(sqrt(cf_res$variance.estimates))
  return(list(MSE=MSE_cf, se=cf_se))
  
}