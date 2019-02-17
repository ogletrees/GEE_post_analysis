# Date: 2018-12-20
# S Ogletree
# Description: Google Earth Engine post analysis - #1

library(rvest)
library(dplyr)
library(httr)
library(here) # for file locations

# the html file of all posts from front page
url <-  here("GEE_posts_analysis/(99+) Google Earth Engine Developers - Google Groups.htm")
dp <- read_html(url)

# get post titles ---------------------------------------------------------

dnodes <- html_nodes(dp, ".F0XO1GC-p-Q")
post_titles <- html_text(dnodes)
head(post_titles)

# get post links ----------------------------------------------------------

# get link part to post
tl <- html_attr(dnodes, "href")
head(tl)
# make a full url
tl <- paste0("https://groups.google.com/forum/", tl)

# get post dates and times ------------------------------------------------
# reusing dt_nodes
dt_nodes <- dp %>% html_nodes(xpath = "//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"F0XO1GC-rb-r\", \" \" ))]//span")
tdates <- html_attr(dt_nodes, "title")
head(tdates)

# get number of responses to the post -------------------------------------
dt_nodes <- dp %>% html_nodes(xpath = "//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"F0XO1GC-rb-r\", \" \" )) and (((count(preceding-sibling::*) + 1) = 2) and parent::*)]")
tresp <- html_text(dt_nodes)


# get the number of views of the post -------------------------------------
dt_nodes <- dp %>% html_nodes(xpath = "//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"F0XO1GC-rb-r\", \" \" )) and (((count(preceding-sibling::*) + 1) = 3) and parent::*)]")
tviews <- html_text(dt_nodes)

# get the user who posted the post ----------------------------------------
dt_nodes <- dp %>% html_nodes(xpath = "//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"F0XO1GC-rb-b\", \" \" ))]")
tuser <- html_text(dt_nodes)

# build data frame ---------------------------------------------------------
gp_data <- data.frame(post_titles, tl, tdates, tresp, tviews, tuser, stringsAsFactors = F)
head(gp_data)
str(gp_data)
# write out
saveRDS(gp_data, here("gee_posts.rds"))
