
library(dplyr)
library(shiny)
library(ggplot2)
library(rsconnect)


#The provided data source (a CSV file) contains some html tags. Meaningful row data in the file starts at row 880. The read call below instructs to skip the first 879 rows and read 49,806 rows. This is determined by analyzing the data ahead of time. The series of characters "&quot" was replaced with a double quote (") in a text editor. This was the easiest solution to parse the file properly so that disease names with commas were escaped with the double quote. 
data <- read.csv("https://raw.githubusercontent.com/Shetura36/Data-608/master/module%203/cleaned-cdc-mortality-1999-2010-2-ver2.csv", skip=879, nrows=49806, header=TRUE, sep=",", strip.white = TRUE, quote = "\"'")

#Remove rows that do not have values for State
data <-data[!(data$State==''),]

#Keep complete cases only 
data <- data[complete.cases(data), ]

#Set column names
colnames(data) <- c('Disease', 'State', 'Year', 'Deaths', 'Population', 'Crude.Rate')

#Change data type
data$Disease <- as.character(data$Disease)
data$Crude.Rate <- as.numeric(data$Crude.Rate)

#Extract only disease categories from string
data$Disease <- substr(data$Disease, regexpr('>', data$Disease)+1, nchar(data$Disease))

#Subset for 2010 only
data_2010 <- data[data$Year == 2010, ]

#unique(data$State)
#unique(data$Disease)

#calculate national average of crude mortality rate
temp <- data_2010 %>% group_by(Disease)  %>% summarise(total_population = sum(Population)) %>% inner_join(data_2010, by="Disease")
temp$Weighted_CrudeRate <- (temp$Population/temp$total_population) * temp$Crude.Rate

#Add disease_national_avg to data_2010
data_2010 <- 
  temp %>% group_by(Disease) %>% summarise(disease_national_avg = sum(Weighted_CrudeRate)) %>% inner_join(data_2010, by="Disease")

#National average for each disease
national_avg_2010 <- as.data.frame(unique(data_2010 %>% group_by(Disease) %>% select(Disease, disease_national_avg)))


# UI
ui <- fluidPage(
  sidebarLayout(
    
    # Input
    sidebarPanel(
      
      # Select variable for y-axis
      selectInput(inputId = "disease", 
                  label = "Select disease:",
                  choices = unique(data_2010$Disease),
                  selected = "Neoplasms",
                  width = '500px')
      
    ),
    
    # Output:
    mainPanel(
      plotOutput(outputId = "bargraph")
    )
  )
)

#typeof(unlist(national_avg_2010 %>% filter(Disease=="Neoplasms") %>% select(disease_national_avg)))

#Question 2
# Define server function required to create the scatterplot-
server <- function(input, output, session) {
  
  #This is an event reactive element that responds to a specific event (in this case a button clicked)
  #and sets the valueExpr to a specific value (in this case the plot title)
  ordered <- eventReactive(
    eventExpr = input$disease, 
    valueExpr = {data_2010 %>% filter(Disease==input$disease) %>% arrange(Crude.Rate)},
    ignoreNULL = FALSE
  )
  
  national_avg <- eventReactive(
    eventExpr = input$disease,
    valueExpr = {unlist(national_avg_2010 %>% filter(Disease==input$disease) %>% select(disease_national_avg))}
  )
  
  #Create bar graph
  output$bargraph <- renderPlot({ggplot(data = ordered(), aes(x=reorder(State,-Crude.Rate), y=Crude.Rate)) + 
      geom_bar(stat="identity", width=0.7, color="#1F3552", fill="steelblue", 
               position=position_dodge()) +
      #geom_text(aes(label=round(Crude.Rate, digits=2)), hjust=0, size=3.0, color="white") + 
      #coord_flip() + 
      geom_hline(yintercept=national_avg(), color="red", size=1) + 
      ggtitle("Crude Mortality for Selected Disease for 2010 with National Average") +
      xlab("") + ylab("") + 
      theme_minimal()}, height = 600, width = 1000)
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)





