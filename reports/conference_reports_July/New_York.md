New York
================
Julia Park
2020-10-28

  - [Visitors](#visitors)
  - [Duration](#duration)

``` r
# Libraries
library(tidyverse)
library(readxl)
library(lubridate)

# Parameters
# change this to your directory
setwd("~/GitHub/Lab_Legal_Design/schema_eval/data")

file_weekly_visitors = "New_York/visitors-overview-total.xlsx"
file_engagement_depth = "New_York/visitors-engagement-depth.xlsx"
file_engagement_duration = "New_York/visitors-engagement-duration.xlsx"
file_freq_session_count = "New_York/visitors-frequency-recency-session-count.xlsx"

#multi vs single
file_session_type = "New_York/visitors-overview-session-type.xlsx" 

#direct vs search vs organic
file_traffic_type = "New_York/visitors-overview-traffic-type.xlsx"

file_engagement_duration_timeseries = "New_York/visitors-duration-timeseries.rds"


#===============================================================================

# Code
schema_week <- 19
weekly_visitors <- 
  read_excel(file_weekly_visitors, skip = 6) %>% 
  filter(`Week Index` < 39)
engagement_depth <- read_excel(file_engagement_depth)
engagement_duration <- read_excel(file_engagement_duration)
freq_session_count <- read_excel(file_freq_session_count)
session_type <- read_excel(file_session_type)
traffic_type <- read_excel(file_traffic_type)
traffic_type_2019 <- 
  read_excel(file_traffic_type, skip = 6) %>% 
  filter(`Date Range` == "Jan 1, 2019 - Dec 31, 2019") %>% 
  filter(`Week Index` < 39)
traffic_type_2020 <- 
  read_excel(file_traffic_type, skip = 6) %>% 
  filter(`Date Range` == "Jan 1, 2020 - Sep 28, 2020") %>% 
  filter(`Week Index` < 39)

engagement_duration_timeseries <- read_rds(file_engagement_duration_timeseries)
```

## Visitors

``` r
x_labels <- function(x) {
 case_when(
  x == 0 ~ "January", 
  x == 9 ~ "March", 
  x == 18 ~ "May", 
  x == 26 ~ "July", 
  x == 35 ~ "September",
 )
}

x_breaks <- c(0, 9, 18, 26, 35)
```

``` r
weekly_visitors %>% 
  drop_na() %>% 
  ggplot(aes(x = `Week Index`, y = Users, color = `Date Range`)) +
  geom_vline(aes(xintercept = schema_week)) +
  geom_smooth() + 
  geom_line() + 
  scale_x_continuous(
    breaks = x_breaks, 
    labels = x_labels
  ) + 
  labs(
    title = "Visitor counts roughly increase at same rate in 2019 and 2020", 
    subtitle = "Large visitor spike in July/August"
  ) + 
  theme_minimal()
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

![](New_York_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

``` r
traffic_type_2020 %>% 
  drop_na() %>% 
  filter(Segment != "All Users") %>% 
  filter(Segment != "Organic Traffic") %>% 
  ggplot(aes(x = `Week Index`, y = Users, color = Segment)) +
  geom_vline(aes(xintercept = schema_week)) + 
  geom_line() + 
  scale_x_continuous(
   breaks = x_breaks, 
   labels = x_labels
  ) +
  labs(
    title = "2020 traffic sources: visitor spike likely due to environmental factors", 
    subtitle = "But schema may have increased click through rate during this timeframe",
    x = "Date"
  ) + 
  theme_minimal()
```

![](New_York_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

## Duration

``` r
new_engagement_duration_timeseries <-
 engagement_duration_timeseries %>% 
 mutate(
  `Session Duration` = fct_collapse(`Session Duration Bucket`, 
     `0 - 10 seconds` = c("0-10 seconds"), 
     `10 sec - 1 min` = c("11-30 seconds", "31-60 seconds"),
     `1 min - 10 min` = c("61-180 seconds", "181-600 seconds"), 
     `10 min - 30 min` = c("601-1800 seconds"), 
     `30+ min` = c("1801+ seconds")
   ), 
  `Session Duration` = fct_relevel(`Session Duration`, "0 - 10 seconds", "10 sec - 1 min", "1 min - 10 min", "10 min - 30 min", "30+ min")
 ) %>% 
 group_by(`Session Duration`, week_index) %>% 
 summarize(
  Sessions = sum(Sessions), 
  Pageviews = sum(Pageviews)
 ) %>% 
 ungroup() %>% 
 filter(`Session Duration` != "Total")
```

``` r
new_engagement_duration_timeseries %>% 
  filter(`Session Duration` != "Total") %>% 
  ggplot(aes(x = week_index, y = Sessions, color = `Session Duration`)) + 
  geom_line() + 
  geom_vline(xintercept = schema_week) + 
  scale_x_continuous(
   labels = x_labels, 
   breaks = x_breaks
  ) +
  labs(
   title = "Slightly more bouncers/short-duration visitors after schema implementation", 
   subtitle = "Disclaimer: increase is slight enough that it may be due to chance",
   x = "Date"
  ) +
  theme_minimal() 
```

![](New_York_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
new_engagement_duration_timeseries %>% 
  filter(`Session Duration` != "Total") %>% 
  filter(`Session Duration` != "0 - 10 seconds") %>% 
  ggplot(aes(x = week_index, y = Sessions, color = `Session Duration`)) + 
  geom_line() + 
  geom_vline(xintercept = schema_week) + 
  scale_x_continuous(
   labels = x_labels, 
   breaks = x_breaks
  ) +
  labs(
   title = "Short-duration visitor count slightly increases after schema implementation", 
   subtitle = "Long-duration visitor count stays steady",
   x = "Date"
  ) +
  theme_minimal() 
```

![](New_York_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

``` r
new_engagement_duration_timeseries %>% 
  mutate(
    pageview_per_session = Pageviews / Sessions
  ) %>% 
  filter(`Session Duration` != "Total") %>% 
  ggplot(aes(x = week_index, y = pageview_per_session, color = `Session Duration`)) + 
  geom_line() + 
  geom_vline(xintercept = schema_week) + 
  scale_x_continuous(
   labels = x_labels, 
   breaks = x_breaks
  ) +
  labs(
   title = "Pageview per session shows no indication of schema effect", 
   x = "Date", 
   y = "Pageview per session"
  ) +
  theme_minimal()
```

![](New_York_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->
