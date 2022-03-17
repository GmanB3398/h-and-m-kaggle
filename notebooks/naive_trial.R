# Run from base directory
library(dplyr)
library(readr)
library(lubridate)
library(ggplot2)
library(plotly)

articles <- read_csv('data/articles.csv')
customers <- read_csv('data/customers.csv')
all_trans_full <- read_csv('data/transactions_train.csv', n_max = 5e6)

all_trans_full %>% pull(customer_id) %>% unique() %>% length()
# Work on Subset of Customer Data
customer_subset <- all_trans_full$customer_id %>% unique() %>% sample(50000)
all_trans <- all_trans_full %>% filter(customer_id %in% customer_subset)
rm(customer_subset)

all_trans %>% 
  group_by(customer_id) %>% 
  summarize(target = as.numeric(length(unique(t_dat))>1)) %>% 
  distinct() -> target_df

all_trans %>% 
  group_by(customer_id) %>% 
  filter(t_dat == min(t_dat)) %>% 
  summarize(linear_dt = round(as.numeric(difftime(t_dat,'2018-01-01', units='days'))), avg_price=mean(price), number_pieces=length(article_id)) %>% 
  inner_join(target_df) %>% distinct() -> base_testing_df

base_testing_df %>% 
  glm(target ~ avg_price*number_pieces + linear_dt, data=., family='binomial') %>% 
  summary()
  
set.seed(1234)
trn_index <- caret::createDataPartition(base_testing_df$target, p = 0.7, list=F)
train <- base_testing_df[trn_index,]
test <- base_testing_df[-trn_index,]

glm(target ~ avg_price*number_pieces + poly(linear_dt, 5), data=train, family='binomial') %>% 
  summary()

basic_glm <- glm(target ~ avg_price*number_pieces + poly(linear_dt, 5), data=train, family='binomial')

test$pred <- predict(basic_glm, newdata = test, type = 'response')

pROC::roc(test$target,test$pred) #%>% plot()

train$target %>% summary

