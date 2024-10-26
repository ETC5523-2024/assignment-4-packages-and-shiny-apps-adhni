server <- function(input, output) {
  # Reactive expression to filter data for the selected country
  country_data <- reactive({
    OlympicsMedal[OlympicsMedal$Country == input$country, ]
  })

  # Text output for summary
  output$summaryText <- renderText({
    paste("Medal data for", input$country, ":",
          "Gold:", country_data()$Gold,
          "Silver:", country_data()$Silver,
          "Bronze:", country_data()$Bronze)
  })

  # Plot output for medals
  output$medalPlot <- renderPlot({
    barplot(as.numeric(country_data()[, c("Gold", "Silver", "Bronze")]),
            names.arg = c("Gold", "Silver", "Bronze"),
            col = c("gold", "gray", "brown"),
            main = paste("Medals for", input$country),
            ylab = "Count of Medals")
  })
}
