# Description

# Author: Julia Park
# Version: 2020-08-18

# Libraries
library(tidyverse)
library(readxl)


# Parameters
setwd("~/GitHub/Lab_Legal_Design/schema_eval/data")

file_out <- "Hawaii/visitors-duration-timeseries.rds"
downloaded_data_prefix <- "Hawaii/Hawaii_new/visitors-engagement("
downloaded_date_suffix <- ").xlsx"

#===============================================================================

read_files <- function(filename, index) {
 read_excel(filename, skip = 6) %>% 
  replace_na(list(`Session Duration` = "Total")) %>% 
  mutate(
   week_index = index
  )
}

file_names <- 
 0:27 %>% 
 map_chr(~ str_glue(downloaded_data_prefix, ., downloaded_date_suffix))

0:27 %>% 
 map2_dfr(file_names, ., ~ read_files(.x, .y)) %>% 
 filter(week_index != 14) %>% 
 write_rds(file_out)
