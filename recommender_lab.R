pacman::p_load(recommenderlab)


mat <-  as(user_item_matrix, "realRatingMatrix")

rec <- Recommender(mat, method = "SVD")

pred_matrix <- predict(rec, mat)

write_rds(pred_matrix, "pred_svd.rds")


(df_test <- 
    df_test %>% 
    mutate(pred =  map2_dbl(user_id, item_id, ~pred_matrix[.x,.y]@data[1,])))

(df_test <- 
    df_test %>% 
    mutate(abs_diff = abs(sentiment - pred),
           squared_error = abs_diff^2))

df_test %>% 
  pull(abs_diff) %>% 
  mean(na.rm = T)

df_test %>% 
  pull(squared_error) %>% 
  mean(na.rm = T) %>% 
  sqrt()

pushover(message = "svd_complete", user = "u1s528fxej49kf333pxdbc95ewsphz", app = "a9nsstadvwr98esup368161qmdd7eq")
walk(1:15, ~beepr::beep(sound = "ping"))

# df
#   df_test %>% 
#   mutate(pred = map2_dbl(user_id, item_id, ~pred_matrix[.x,.y]@data[1,]))

         