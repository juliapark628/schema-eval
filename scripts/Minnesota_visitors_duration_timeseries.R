# Description

# Author: Julia Park
# Version: 2020-08-18

# Libraries
library(tidyverse)
library(readxl)


# Parameters
setwd("~/GitHub/Lab_Legal_Design/schema_eval/data")

file_out <- "Minnesota/visitors-duration-timeseries.rds"
downloaded_data_prefix <- "Minnesota/Minnesota-duration/visitors-engagement("
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
 0:33 %>% 
 map_chr(~ str_glue(downloaded_data_prefix, ., downloaded_date_suffix))

0:33 %>% 
 map2_dfr(file_names, ., ~ read_files(.x, .y)) %>% 
 write_rds(file_out)
