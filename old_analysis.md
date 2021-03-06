---
title: "Earth Engine Post Analysis"
---
Google Earth Engine is a platform for analyzing satellite data and makes this type of work much easier for the researcher. To quote from the [source](https://earthengine.google.com):

> Google Earth Engine combines a multi-petabyte catalog of satellite imagery and geospatial datasets with planetary-scale analysis capabilities and makes it available for scientists, researchers, and developers to detect changes, map trends, and quantify differences on the Earth's surface.

Earth Engine was started in 2010 (as far as I can tell) and has become a great tool for doing simple to complex analysis of satellite imagery. 

If you use Earth Engine you might encounter issues that others can help with. Of course, you should consult the documentation first, but a help forum is available where other users and staff can help out. In my work I have found many answers on the forum and this led me to wondering what has been discussed in the many posts over time.

# The Data

Post titles were sourced from the forum page. Basically I just scrolled to the bottom and saved that page as `.html`. Then the `.html` file could be scraped in R. I only used post titles as scraping post text seems very complicated for Google Groups that require signing in.

Using R I processed the `.html` with the `rvest` package to extract the title text and other data available. The data extracted included: 

- post title
- the user making the post
- how many responses the post got 
- how many views the post had
- the date and time of the post

The data were extracted on December 10, 2018. At that time there were 7,637 posts in the forum.

# Analysis

```{r echo=FALSE}
posts %>% filter(dates < "2018-12-01") %>% # filter out Dec 2018 as data is through Dec 10
  count(dd = floor_date(dates, "month")) %>% 
  ggplot(aes(dd, n)) + geom_line() + labs(title= "Forum Posts Time Series", subtitle="Number of posts by month", x="Date", y="Count")
```

```{r echo=FALSE}
posts %>% filter(dates < "2018-12-09") %>% # filter out last week as it's not a complete week
  count(dd = floor_date(dates, "weeks")) %>% 
  ggplot(aes(dd, n)) + geom_line() + labs(title = "Forum Posts Time Series", subtitle="Number of posts by week", x="Date", y="Count")
```

```{r echo=FALSE}
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
```

The date and time shown looked to be localized to my timezone, which is -4 UTC. From the plots it looks like Earth Engine users are active during typical working days and hours. Most active days of the week were Tuesday and Thursday. During the day most activity was at 1 p.m. There is a bump in activity at 4 a.m., but this would be 8 a.m. UTC and so could be users in Europe in the morning or midday in India.
