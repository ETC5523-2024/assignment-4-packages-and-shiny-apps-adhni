server <- function(input, output) {
  output$medals <- renderText({
    paste("You selected", input$country)
  })
}

