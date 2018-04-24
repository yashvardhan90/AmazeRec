pacman::p_load(tidyverse)


df <- read_csv("data/kindle.csv", col_names = T)

# colnames(df) <- c("user", "item", "rating", "timestamp")

k <- 18

remove_user_item <- function(df_remove, k){
  df_remove <- df_remove %>% 
  add_count(reviewerID) %>% 
  add_count(asin) %>% 
  filter(nn >= k, n >= k) %>% 
  select(-n, -nn)
  
  message(nrow(df_remove))
  
  df_remove
}

k_core_user <- function(df_remove) df_remove %>% add_count(reviewerID) %>% arrange(n) %>% pull(n) %>%  .[1] 
k_core_item <- function(df_remove) df_remove %>% add_count(asin) %>% arrange(n) %>% pull(n) %>%  .[1] 

df_count <- df

while (k_core_user(df_count) < k & k_core_item(df_count) < k) {
  df_count <- remove_user_item(df_count, k)
}
 
# df %>% 
#   remove_user_item(10) %>% 
#   remove_user_item(10) %>% 
#   remove_user_item(10) %>% 
#   remove_user_item(10)

df_count %>% 
  write_csv("data/df_count_kindle.csv")


k_item = 500
k_user = 200
df_count2 <- 
  df_count %>% 
  filter(n > k_user, nn > k_item)

df_count2 %>% 
  write_csv(paste0("data/df_u",k_user,"i",k_item,".csv"))


 
# (df_count <- 
#   df %>% 
#   select(-timestamp) %>% 
#   add_count(user))
# 
# df_user_5 <- 
#   df_count %>% 
#   filter(n >= 10)
# 
# 
# df_count2 <- 
#   df_user_5 %>%
#   select(-n) %>% 
#   add_count(item)
# 
# df_item_5 <- 
#   df_count2 %>% 
#   filter(n >= 10)
# 
# df_user_item_k <- 
#   df_item_5 %>% 
#   inner_join(df_user_5)
# 


num_users <- df_user_item_k$user %>% unique() %>% length()
num_items <- df_user_item_k$item %>% unique() %>% length()

user_item_matrix <- matrix(nrow = num_users, ncol = num_items)


for(i in 1:nrow(df_train)){
  x <- df_train[i, ]
  user_item_matrix[x$user_id, x$item_id] <- x$sentiment
}


df <- read_csv("data/kindle.csv", col_names = T)

k = 20

(df_count_kindle <- 
    df %>% 
    add_count(reviewerID) %>% 
    filter(n >= k) %>% 
    add_count(asin) %>% 
    filter(nn >= k) %>% 
    select(-X1))

df_count_kindle %>% 
  write_csv("data/df_count_kindle.csv")
