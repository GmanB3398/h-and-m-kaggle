# Run from base directory
library(dplyr)
library(readr)

articles <- read_csv('data/articles.csv')
customers <- read_csv('data/customers.csv')
all_trans <- read_csv('data/transactions_train.csv', n_max = 2e6)

