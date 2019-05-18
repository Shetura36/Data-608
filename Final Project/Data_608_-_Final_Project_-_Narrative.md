---
title: "Data 608 Final Project"
author: "S. Tinapunan"
date: "May 17, 2019"
output: 
  html_document: 
    keep_md: yes
---



<br> 

---

### Video Presentation

http://somup.com/cqhFIhnkns

<br> 

---

### September 2014 NYC Uber Pickup Viewer

Shiny application: https://shetura36.shinyapps.io/Data608_Uber_Final_Project/

For this project, I created a Shiny application that displays NYC pickup locations made by Uber during the month of September 2014. The application displays each pickup point on an interactive map that enables end-user to expand cluster points and zoom-in. End-user is also able to click on each pickup marker and view information such as neighborhood, city, zip code, pickup date/time, and base. The application also provides a report of the number of pickups by neighborhood and the top ten areas by zip codes. 

The scope of each map view is limited to daily and/or hourly view for the selected borough. This tool is useful for understanding pickup zones throughout the five boroughs of New York City. The interactive map allows end-user to see establishments around high pick zones, and the report gives a quick overview of top neighborhoods and zip codes.

To generate the interactive map, the *Leaflet* library was used. 

<br> 

### About the Data

Data set: https://www.kaggle.com/fivethirtyeight/uber-pickups-in-new-york-city/version/2 


<b> Data Processing Narrative </b> 

http://rpubs.com/Shetura36/Data608-FinalProject-PrepareData

The data processing narrative gives an overview of how the September 2014 data set was prepared. The Uber data set only includes longitude and latitude location data for each pickup. Part of my Data 607 project was to convert longitude and latitude to zip code, city, neighborhood, and borough. This process is called reverse geocoding. At that time, I was not able to find a package in R that could do the conversation. The conversion done was an estimate. *geosphere* and *zipcode* libraries were used to do the conversion. The *zipcode* data contains mapping of zip code to longitude and latitude. The *geosphere* calculates the distance between two geolocation points. The nearest zip code to the pickup location was selected by calculating the distance of each NYC zip code geolocation from the pickup point and selecting the zip code with the shortest distance. Upon further investigation, some pickup points in the Uber data set were not in NYC. A reasonable estimate was done by dropping any pickup points that exceed 2000 meters (about 1.24 miles) from the nearest NYC zip code. 

The data set contains 1,028,136 pickup points. 50,636 pickup points were dropped because the distance exceeds 2000 meters from the nearest NYC zip code. So the remaining 977,500 pickup points is size of the data that the pickup viewer is using. 


<br> 

---

### Code

https://github.com/Shetura36/Data-608/tree/master/Final%20Project

*app.R* is the shiny application. 


---

### Fututre Improvements

I would like to develop this viewer more by adding options to select by neighborhood and zip code. This would allow end-user to select very specific areas to investigate. I also would like to add more report tabs that would provide dynamic plots that show information that compare data across different boroughs, neighborhoods, and zip codes. 


<br> 

S. Tinapunan




