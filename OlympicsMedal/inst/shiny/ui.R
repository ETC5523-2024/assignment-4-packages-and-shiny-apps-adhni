library(shiny)

ui <- fluidPage(
  titlePanel("Olympic Medals"),
  sidebarLayout(
    sidebarPanel(
      selectInput("country", "Choose a country:", choices = c("USA", "China", "Japan"))
    ),
    mainPanel(
      textOutput("medals")
    )
  )
)
