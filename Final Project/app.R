#----------------------------------------------------#
# Data 608 - Final Project
# S. Tinapunan, 5/17/2019
# Data Process Narrative:  http://rpubs.com/Shetura36/Data608-FinalProject-PrepareData
# 



library(shinydashboard)
library(shiny)
library(leaflet)
library(dplyr)
library(lubridate)
library(readr)
library(zipcode)

##-------------------------------- Helper Functions----------------------------------------------##


#Add date related columns 
process_date <- function(data){
  pickup_nyc <- data
  pickup_nyc$pickup_datetime <- readr::parse_datetime(pickup_nyc$pickup_datetime, "%m/%d/%Y %H:%M:%S")
  pickup_nyc$date <- lubridate::date(pickup_nyc$pickup_datetime)
  pickup_nyc$hour <- lubridate::hour(pickup_nyc$pickup_datetime)
  pickup_nyc$dayOfWeek <- 
    wday(pickup_nyc$pickup_datetime, label = TRUE, abbr = TRUE, 
         week_start = getOption("lubridate.week.start", 7), locale = Sys.getlocale("LC_TIME"))
  return(pickup_nyc)
}

#Select by Borough, Date, Hour
#Borough is required
filter_by_borough_date_hour <- function(data, this_borough, this_date, this_hour){
  
  #Case 1: Borough and date selected
  if(this_borough!='' & is.null(this_date)==FALSE & this_hour=='ALL'){
    print('CASE 1: Borough and Date')
    return(data %>% dplyr::filter(date == this_date & Borough==this_borough))
  }
  
  #Case 2: Borough, date range, and hour selected
  else if(this_borough!='' & is.null(this_date)==FALSE & is.null(this_hour)==FALSE){
    print('CASE 2: Borough, Date, and Hour')
    return(data %>% dplyr::filter(date == this_date & Borough==this_borough & hour==this_hour))
  }
  
  #Case 3: Invalid input 
  else{ 
    print('CASE 3: Invalid Input')
    return(NULL) 
  }
}


##--------------------------- Begin Shiny App --------------------------------------##

df <- readRDS("./NYC_Uber_pickup_Sept2014.rds")
df <- process_date(df)

print(nrow(df))

header <- dashboardHeader(title = 'NYC Uber Pickups')

sidebar <- dashboardSidebar(
  
  # Create a select list
  selectInput(
              inputId = "borough", 
              label = "NYC Borough",
              choices = unique(df$Borough),
              selected = 'Manhattan'
  ),
  
  #Pickup date
  dateInput(
              inputId = 'date_input',
              label = 'Date for Sept 2014 Only',
              value = '2014-09-01',
              min = '2014-09-01',
              max = '2014-09-30'),
  
  #hour
  selectInput(
              inputId = "hour_input",
              label = "Hour (Military):",
              choices = append(c("ALL"), unique(df$hour)),
              selected = 'All'
    
  ),
  
  HTML("<br>"),
  
  #action button
  actionButton(
     inputId = "update_map", 
     label = "Update"
  )
  
)

body <- dashboardBody(
  
  fluidRow(
    tabBox(
      title = "Sept 2014 - NYC Pickup Locations",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "tabset1", height = "900px", width=8,
      tabPanel("Map", leafletOutput("mymap", width="100%", height='900px'))
    ),
    tabBox(
      title = uiOutput("title_info"),
      height = "900px", width=4,
      #selected = "Charts",
      tabPanel("Report",
               fluidRow(
                  column(10,htmlOutput("total_pickups")),
                  column(10,tableOutput(("neighborhood_count")),
                  column(10,tableOutput("zip_count")))
               ))
    )
  )
)

# Create the UI using the header, sidebar, and body
ui <- dashboardPage(
                    
                    header = header,
                    sidebar = sidebar,
                    body = body
                   )

#Server function 
server <- function(input, output, session){
  
  output$mymap <- renderLeaflet({
    selected_data <- data()
    
    map <- leaflet(data = selected_data) %>%
      addTiles() %>%
      addMarkers(lng = ~longitude.pickup,
                 lat = ~latitude.pickup,
                 clusterOptions = markerClusterOptions(),
                 popup = paste(
                               "Neighborhood:", selected_data$Neighborhood, "<br>",
                               "City:", selected_data$city, "<br>",
                               "Zip:", selected_data$zip, "<br>",
                               "Pickup Date/Time:", selected_data$pickup_datetime, "<br>",
                               "Base:", selected_data$base))
    map
  })
  
  #Neighbhorhood Count: renderTable
  output$neighborhood_count <- renderTable({
    print("in render plot")
    selected_data <- data()
    this_data <- as.data.frame(dplyr::count(selected_data, Borough, Neighborhood) %>% dplyr::arrange(desc(n)))
    names(this_data) <- c("Borough", "Neighborhood", "Count")
    this_data

  })
  
  #zip Count: renderTable
  output$zip_count <- renderTable({
    print("in render plot")
    selected_data <- data()
    this_data <- as.data.frame(dplyr::count(selected_data, city, zip) %>% dplyr::arrange(desc(n)))
    names(this_data) <- c("City", "Zip Code", "Count") 
    head(this_data,10)
    
  })
  
  #total pickups as per selection
  output$total_pickups <- renderUI({
    selected_data <- data()
    count <- nrow(selected_data)
    HTML(paste("<h3>Total Pickups: ", count, "</h3><br>"))
  })
  
  #dynamic title
  output$title_info = renderText({
    paste("Day: ", input$date_input, ", Hour: ", input$hour_input)
  }) 
  
  #for update_map button
  observeEvent(input$update_map, {
    print('update map called')
    print(input$borough)
    print(input$date_input)
    print(input$hour_input)
  })
  
  #event Reactive for currently selected data
  data <- eventReactive(
    eventExpr = input$update_map, {
    req(input$date_input)
    valueExpr = filter_by_borough_date_hour(df, this_borough=input$borough, this_date = input$date_input, this_hour=input$hour_input)
    }
  )

} #server end


#create app
shinyApp(ui, server)
