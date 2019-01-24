Test markdown page

# here is a header

```R
library(dplyr)
x <- 10
```

### a small header

This is some text that will be about what I did to analyze the data.

I typed this is Typora.

![network_plot](network_plot.jpg)

Cool image of the words.

Here is some of the code:

```R
# Date: 2019-01-01
# S Ogletree
# Description: Analysis of Google Earth Engine help forum posts

library(tidyverse)
library(tidytext)
library(lubridate)
library(here)
library(widyr)
library(igraph)
library(ggraph)

posts <- readRDS(here("gee_posts_data.rds"))
names(posts)


# plot for fun
posts %>% filter(dates < "2018-12-01") %>% # filter out Dec 2018 as data is through Dec 10
  count(dd = floor_date(dates, "month")) %>% 
  ggplot(aes(dd, n)) + geom_line() + labs(title="Posts by month", x="Date", y="Count")

posts %>% filter(dates < "2018-12-09") %>% # filter out last week as it's not a complete week
  count(dd = floor_date(dates, "weeks")) %>% 
  ggplot(aes(dd, n)) + geom_line() + labs(title="Posts by week", x="Date", y="Count")
# count by day
t <- as.data.frame(table(posts$dates), stringsAsFactors = F) %>% mutate(date = as.Date(Var1))
t %>% ggplot(aes(date, Freq)) + geom_line()
t %>% arrange(desc(Freq)) %>% slice(1:10)
# day with most posts, what was going on?
t %>% arrange(desc(Freq)) %>% slice(1:10)
posts %>% filter(dates == "2017-02-16")


# time of day, most times were UTC -4 or -5, maybe the server time? or maybe my local time zone as that is what is displayed in the forum.
posts %>% 
  mutate(hr = hour(times)) %>% 
  ggplot(aes(hr)) + 
    geom_bar() + 
    labs(title="Posts by time of day", x="Hour", y="Count")

posts %>% 
  mutate(dow = wday(times, label = T)) %>% 
  ggplot(aes(dow)) + 
    geom_bar() + 
    labs(title="Posts by day of week", x="Day of week", y="Count")

# Most frequent user posting
posts %>% 
  count(og_poster) %>% 
  arrange(desc(n))

posts %>% 
  count(og_poster) %>% 
  arrange(desc(n)) %>% 
  slice(1:10) %>% 
  ggplot(aes(fct_rev(fct_inorder(og_poster)), n)) + 
    geom_col() + 
    coord_flip() + 
    labs(title= "Top 10 post authors", y = "Number of posts", x = "Forum User")

# Most viewed post
posts %>% 
  arrange(desc(views)) %>% 
  slice(1:10)

# Posts with the most responses
posts %>% 
  arrange(desc(responses)) %>% 
  slice(1:10)

#

# text analysis -----------------------------------------------------------

tx <- posts %>% select(post_id, post_titles)

tx <- tx %>% 
  unnest_tokens(word, post_titles) %>% 
  anti_join(stop_words)

# get word count
tx %>%
  count(word, sort = TRUE)

# word pairs
title_word_pairs <- tx %>% 
  pairwise_count(word, post_id, sort = TRUE, upper = FALSE)

title_word_pairs

# network plot of word pairs
set.seed(1234)

title_word_pairs %>%
  filter(n >= 20) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void()

ggsave("network_plot.pdf", height = 10)

# get trigrams and see what was the most common 3 words together
tx_trigrams <- tx %>%
  unnest_tokens(trigram, word, token = "ngrams", n = 3)

# NA means that there were not 3 words in the post title
tx_trigrams %>%
  filter(!is.na(trigram)) %>% 
  count(trigram, sort = TRUE)


# topic modeling ----------------------------------------------------------
# make a term frequency-inverse document frequency
desc_tf_idf <- tx %>% 
  count(post_id, word, sort = TRUE) %>%
  ungroup() %>%
  bind_tf_idf(word, post_id, n)

desc_tf_idf %>% 
  arrange(-tf_idf)

desc_tf_idf %>% 
  arrange(-tf_idf) %>% 
  filter(n > 2)

word_counts <- tx %>%
  anti_join(stop_words) %>%
  count(post_id, word, sort = TRUE) %>%
  ungroup()

word_counts

desc_dtm <- word_counts %>%
  cast_dtm(post_id, word, n)

desc_dtm

library(topicmodels)
# be aware that running this model is time intensive, if the number is larger
desc_lda <- LDA(desc_dtm, k = 8, control = list(seed = 1234))

desc_lda

tidy_lda <- tidy(desc_lda)

tidy_lda

top_terms <- tidy_lda %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms

top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  group_by(topic, term) %>%    
  arrange(desc(beta)) %>%  
  ungroup() %>%
  mutate(term = factor(paste(term, topic, sep = "__"), 
                       levels = rev(paste(term, topic, sep = "__")))) %>%
  ggplot(aes(term, beta, fill = as.factor(topic))) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_x_discrete(labels = function(x) gsub("__.+$", "", x)) +
  labs(title = "Top 10 terms in each LDA topic",
       x = NULL, y = expression(beta)) +
  facet_wrap(~ topic, ncol = 4, scales = "free")
ggsave("topic_terms.pdf", width = 10)

# get probabilities for each document (post) in each topic
lda_gamma <- tidy(desc_lda, matrix = "gamma")

lda_gamma

# ggplot(lda_gamma, aes(gamma)) +
#   geom_histogram() +
#   scale_y_log10() +
#   labs(title = "Distribution of probabilities for all topics",
#        y = "Number of documents", x = expression(gamma))
# 
# ggplot(lda_gamma, aes(gamma, fill = as.factor(topic))) +
#   geom_histogram(show.legend = FALSE) +
#   facet_wrap(~ topic, ncol = 4) +
#   scale_y_log10() +
#   labs(title = "Distribution of probability for each topic",
#        y = "Number of documents", x = expression(gamma))

# see what topic each post is most likely to belong to
lda_gamma %>% 
  group_by(document) %>% 
  top_n(1, gamma) %>% 
  janitor::tabyl(topic)

```

