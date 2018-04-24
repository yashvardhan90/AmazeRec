pacman::p_load(tidyverse, rebus, anytime, lubridate, RSentiment, tidytext, sentimentr, scales)

df <- read_csv("data/df_count_kindle.csv")

# df <-
#   df %>% 
#   filter(n > 30, nn > 60) %>% 
#   arrange(n, reviewerID)

###########
# df_clean <- 
#   df %>% 
#   left_join(tibble(user = unique(df$user)) %>% mutate(user_id = row_number())) %>% 
#   left_join(tibble(item = unique(df$item)) %>% mutate(item_id = row_number())) %>% 
#   rename(overall = rating) %>%
#   mutate(review_id = row_number())
###########

# df %>%
#   select(-X1) %>% write_csv("data/reviews2.csv")

(df_clean <- 
  df %>% 
  mutate(helpful = helpful %>% str_replace_all(rebus::or("\\[", "\\]"), "")) %>% 
  separate(helpful, into = c("helpful", "unhelpful"), sep = ",", convert = TRUE)
)

df_clean <- 
  df_clean %>% 
  # rename(review_id = X1) %>% 
  mutate(review_id = row_number(),
         time = anytime(unixReviewTime) %>% as_date()) %>% 
  left_join(tibble(reviewerID = unique(df_clean$reviewerID)) %>% mutate(user_id = row_number())) %>% 
  left_join(tibble(asin = unique(df_clean$asin)) %>% mutate(item_id = row_number())) %>% 
  select(-reviewerID, -reviewerName, -asin, -reviewTime, -unixReviewTime)

df_clean_sentiment <- 
  df_clean %>% 
  mutate(sentences = get_sentences(reviewText)) %$% 
  sentiment_by(sentences, list(user_id, item_id, review_id)) %>% 
  as_tibble() %>%
  left_join(df_clean) %>% 
  mutate(sentiment = rescale(ave_sentiment, to=c(1,5)),
         net = overall - sentiment) %>% 
  select(review_id, user_id, item_id, overall, sentiment, net, everything())

df_clean <- df_clean_sentiment

max(df_clean$user_id)
max(df_clean$item_id)
max(df_clean$review_id)

set.seed(1)

unique_ids <- 
  df_clean %>% 
  pull(user_id) %>% 
  unique() %>% 
  sample(as.integer(length(.)*.3))

df_test <- 
  df_clean %>% 
  filter(user_id %in% unique_ids) %>%
  group_by(user_id) %>% 
  sample_n(3)

df_train <- 
  df_clean %>% 
  anti_join(df_test, by = "review_id")

df_test %>% 
  anti_join(df_train, by = "user_id")

num_users <- df_clean$user_id %>% unique() %>% length()
num_items <- df_clean$item_id %>% unique() %>% length()

user_item_matrix <- matrix(nrow = num_users, ncol = num_items)
user_item_matrix_sentiment <- matrix(nrow = num_users, ncol = num_items)

for(i in 1:nrow(df_train)){
  x <- df_train[i, ]
  user_item_matrix[x$user_id, x$item_id] <- x$overall
  user_item_matrix_sentiment[x$user_id, x$item_id] <- x$sentiment
}

# write_rds(user_item_matrix_tr,"user_item_matrix_tr.rds")

similarity <- cor(t(user_item_matrix), use = "pairwise.complete.obs", method = "pearson")
similarity_sentiment <- cor(t(user_item_matrix_sentiment), use = "pairwise.complete.obs", method = "pearson")
mean_ratings = rowMeans(user_item_matrix, na.rm = T)
mean_ratings_sentiment = rowMeans(user_item_matrix_sentiment, na.rm = T)

calc_rating <- function(user_id, item_id, type = "regular"){
  # browser()
  if(type == "regular"){
    active_user_mean <- mean_ratings[user_id]
    active_user_similarity <- similarity[user_id, ]
    item_ratings <- user_item_matrix[,item_id]
    w_r <- sum(active_user_similarity * (item_ratings - mean_ratings), na.rm = T)
    active_user_mean + (w_r/sum(abs(active_user_similarity), na.rm = T))
  } else {
    active_user_mean <- mean_ratings_sentiment[user_id]
    active_user_similarity <- similarity_sentiment[user_id, ]
    item_ratings <- user_item_matrix_sentiment[,item_id]
    w_r <- sum(active_user_similarity * (item_ratings - mean_ratings), na.rm = T)
    active_user_mean + (w_r/sum(abs(active_user_similarity), na.rm = T))
  }
  
}



(df_test <- 
    df_test %>% 
    mutate(pred = map2_dbl(user_id, item_id, calc_rating)))



df_test %>% 
  grou

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

df_reco <- 
  df_test %>% 
  filter(!is.na(squared_error)) %>% 
  group_by(user) %>% 
  arrange(squared_error, .by_group = T) %>% 
  slice(1:3) 


df_reco %>% 
  ungroup() %>% 
  select(item) %>% 
  distinct() %>% 
  write_csv("data/asin.txt")


df_reco %>% write_csv("data/recommendations_books_ucf.csv")



# (df_train_sentiment <- 
# df_train %>% 
#   mutate(sentences = get_sentences(reviewText)) %$% 
#   sentiment_by(sentences, list(user_id, item_id, review_id)) %>% 
#   as_tibble() %>%
#   left_join(df_train) %>% 
#   mutate(sentiment = rescale(ave_sentiment, to=c(1,5)),
#          net = overall - sentiment) %>% 
#   select(overall, sentiment, net, everything()) %>% 
#   arrange(desc(sentiment)))
# 
# user_item_matrix_sentiment <- matrix(nrow = num_users, ncol = num_items)
# 
# for(i in 1:nrow(df_train_sentiment)){
#   x <- df_train_sentiment[i, ]
#   user_item_matrix_sentiment[x$user_id, x$item_id] <- x$sentiment
# }
# 
# 
# similarity_sentiment <- cor(t(user_item_matrix_sentiment), use = "pairwise.complete.obs", method = "pearson")
# 
# 
# mean_ratings_sentiment = rowMeans(user_item_matrix_sentiment, na.rm = T)
# 
# calc_rating__sentiment <- function(user_id, item_id){
#   # browser()
#   active_user_mean <- mean_ratings_sentiment[user_id]
#   active_user_similarity <- similarity_sentiment[user_id, ]
#   item_ratings <- user_item_matrix_sentiment[,item_id]
#   w_r <- sum(active_user_similarity * (item_ratings - mean_ratings), na.rm = T)
#   active_user_mean + (w_r/sum(abs(active_user_similarity), na.rm = T))
# }
# 
# (df_test <- 
#     df_test %>% 
#     mutate(pred = map2_dbl(user_id, item_id, calc_rating__sentiment)))
# 
# (df_test <- 
#     df_test %>% 
#     mutate(abs_diff = abs(overall - pred),
#            squared_error = abs_diff^2))
# 
# df_test %>% 
#   pull(abs_diff) %>% 
#   mean(na.rm = T)
# 
# df_test %>% 
#   pull(squared_error) %>% 
#   mean(na.rm = T) %>% 
#   sqrt()


df_clean_sentiment %>% 
  ggplot(aes(sentiment, overall)) +
  geom_point()
