# Description

# Author: Julia Park
# Version: 2020-10-28

# Libraries
library(tidyverse)
library(readxl)


# Parameters
setwd("~/GitHub/Lab_Legal_Design/schema_eval/data/New_York")

file_out <- "search_result_performance.rds"
file_avgposition <- "search_console_avgposition.xlsx"
file_clicks <- "search_console_clicks.xlsx"
file_CTR <- "search_console_CTR.xlsx"
file_impressions <- "search_console_impressions.xlsx"

#===============================================================================

avgposition <- 
  file_avgposition %>% 
  read_excel(sheet = "Dataset2") %>% 
  select(Date = `Day Index`, `Average Position`)

clicks <- 
  file_clicks %>% 
  read_excel(sheet = "Dataset2") %>% 
  select(Date = `Day Index`, `Clicks`)

CTR <- 
  file_CTR %>% 
  read_excel(sheet = "Dataset2") %>% 
  select(Date = `Day Index`, `CTR`)

impressions <- 
  file_impressions %>% 
  read_excel(sheet = "Dataset2") %>% 
  select(Date = `Day Index`, `Impressions`)

avgposition %>% 
  left_join(clicks, by = "Date") %>% 
  left_join(CTR, by = "Date") %>% 
  left_join(impressions, by = "Date") %>% 
  write_rds(file_out)
