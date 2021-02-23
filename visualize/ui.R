

library(shiny)
library(shinyWidgets)


shinyUI(fluidPage(
    
    setBackgroundColor("black"),
    
    plotOutput("plot"),
    
    hr(),
    
    fluidRow(
        column(6, 
               sliderInput(inputId = "range",
                           label = "R value range:",
                           min = -1,
                           max = 1,
                           value = c(-1, 1),
                           step = .1),
               tags$head(tags$style("body {color: white}"))
        ),
        column(3, 
               checkboxGroupInput(inputId = "window", 
                                  label = "Window size:",
                                  choices = c(5, 7, 9),
                                  selected = c(5, 7, 9),
                                  inline = FALSE),
               tags$head(tags$style("body {color: white}"))
        ),
        column(3, 
               checkboxGroupInput(inputId = "strain", 
                                  label = "Strains:",
                                  choices = c("invasive", "other"),
                                  selected = c("invasive", "other"),
                                  inline = FALSE),
               tags$head(tags$style("body {color: white}"))
        ),
    )
)
)
