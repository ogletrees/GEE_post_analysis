---
title: "Earth Engine Post Analysis"
---
Google Earth Engine is a platform for analyzing satellite data and makes this type of work much easier for the researcher. To quote from the [source](https://earthengine.google.com):

> Google Earth Engine combines a multi-petabyte catalog of satellite imagery and geospatial datasets with planetary-scale analysis capabilities and makes it available for scientists, researchers, and developers to detect changes, map trends, and quantify differences on the Earth's surface.

Earth Engine was started in 2010 (as far as I can tell) and has become a great tool for doing simple to complex analysis of satellite imagery. 

If you use Earth Engine you might encounter issues that others can help with. Of course, you should consult the documentation first, but a help forum is available where other users and staff can help out. In my work I have found many answers on the forum and this led me to wonder what has been discussed in the many posts over time.

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

First let's take a look at the number of posts made over time.

![](plot_by_month.jpg)

Looking at the number of posts by month there has been a steady growth in the use of the GEE forum since 2012. There appears to have been a big jump in use at the beginning of 2017. A dip in use looks to show up around the new year's holiday season. Let's look at the number of posts by week for more detail.

![](plot_by_week.jpg)

This view is a bit more busy, but a distinct dip in use shows up at the beginning of each year. Perhaps everyone takes a break for the holidays :smile:

We can also look at the number of posts by time of day.

![](plot_time_of_day.jpg)

The date and time shown looked to be localized to my timezone, which is -4 UTC. From the plots it looks like Earth Engine users are active during typical working days and hours. Most active days of the week were Tuesday and Thursday. During the day most activity was at 1 p.m. There is a bump in activity at 4 a.m., but this would be 8 a.m. UTC and so could be users in Europe in the morning or midday in India.

If we look at posts by day of the week...

![](plot_day_of_week.jpg)

we see that most use is on weekdays. Perhaps users are spending much of their GEE time doing works tasks.

