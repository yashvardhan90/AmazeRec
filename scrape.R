pacman::p_load(rvest, tidyverse)


df_items <- 
  read_csv("data/asin.txt")


make_landing_url <- function(param){
  url <- 
    "https://www.amazon.com/gp/product/" %>% 
    str_c(param) %>% 
    str_replace_all(" ", "")
  # %>%
  # url()
  curl::curl(url, handle = curl::new_handle("useragent" = "Mozilla/5.0"))
} 

# 
# fetch_page_and_test <- function(str){
#   str %>% 
#     make_landing_url() %>% 
#     read_html_safe() %>% 
#     test_landing()
# } 


df_item_page <- 
  df_items %>% 
  mutate(page = map(item, function(x){
    print(x)
    read_html(paste0("https://www.amazon.com/gp/product/",x))
  }))
