# Date: 2019-01-01
# S Ogletree
# Description: Further clean up of data

library(tidyverse)
library(here)
library(lubridate)

df <- readRDS(here("gee_posts.rds"))

str(df)

# fix dates
df <- df %>% mutate(date = gsub(".*y, | at.*", "", df$tdates), time = gsub(".*at | UTC-.*", "", df$tdates), datetime = paste(date, time))
# new col for dates and times
df$dates <- mdy(df$date)
df$times <- mdy_hms(df$datetime)
# post id
df$post_id <- gsub("https://groups.google.com/forum/#!topic/google-earth-engine-developers/", "", df$tl)
# respones and views
df$responses <- as.numeric(gsub(" post*.", "", df$tresp))
df$views <- as.numeric(gsub(" view*.", "", df$tviews))
# the post originator
df$og_poster <- gsub("By ","", df$tuser)

# create dataset
ddata <- df %>% select(post_id, og_poster, post_titles, responses, views, dates, times)
# save data out
saveRDS(ddata, "gee_posts_data.rds")
