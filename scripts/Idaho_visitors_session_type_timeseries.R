# Description

# Author: Julia Park
# Version: 2020-08-18

# Libraries
library(tidyverse)
library(readxl)


# Parameters
setwd("~/GitHub/Lab_Legal_Design/schema_eval/data")

file_out <- "Idaho/visitors-session-type-timeseries.rds"
file_out_2020 <- "Idaho/visitors-session-type-timeseries-2020.rds"
downloaded_data_prefix <- "Idaho/Idaho_new/visitors-overview-session-type("
downloaded_data_suffix <- ").xlsx"

#===============================================================================

read_files_2019 <- function(filename) {
  read_excel(filename, skip = 6) %>% 
    drop_na() %>% 
    filter(str_detect(`Date Range`, "2019")) %>% 
    mutate(
      `Week Index` =
        case_when(
          `Date Range` == "Jan 1, 2019 - Apr 2, 2019"   ~  `Week Index` + 0, 
          `Date Range` == "Apr 3, 2019 - Jul 4, 2019"   ~  `Week Index` + 14, 
          `Date Range` == "Jul 5, 2019 - Aug 17, 2019"   ~  `Week Index` + 28, 
          TRUE ~ -1
        ), 
      Year = "2019"
    ) %>% 
    filter(`Week Index` != -1) %>%
    select(
      Week_Index = `Week Index`, 
      Year,
      Segment, 
      Users, 
    )
}

read_files_2020 <- function(filename) {
  read_excel(filename, skip = 6) %>% 
    drop_na() %>% 
    filter(str_detect(`Date Range`, "2020")) %>% 
    mutate(
      `Week Index` =
        case_when(
          `Date Range` == "Jan 1, 2020 - Apr 2, 2020"   ~  `Week Index` + 0, 
          `Date Range` == "Apr 3, 2020 - Jul 4, 2020"   ~  `Week Index` + 14, 
          `Date Range` == "Jul 5, 2020 - Aug 17, 2020"   ~  `Week Index` + 28, 
          TRUE ~ -1
        ), 
      Year = "2020"
    ) %>% 
    filter(`Week Index` != -1) %>% 
    select(
      Week_Index = `Week Index`, 
      Year,
      Segment, 
      Users
    )
}


file_names <- 
 0:2 %>% 
  map_chr(~ str_glue(downloaded_data_prefix, ., downloaded_data_suffix))


session_2019 <-
  file_names %>% 
  map_dfr(~ read_files_2019(.))

session_2020 <- 
  file_names %>% 
  map_dfr(~ read_files_2020(.)) 

rbind(session_2019, session_2020) %>% 
  write_rds(file_out)
