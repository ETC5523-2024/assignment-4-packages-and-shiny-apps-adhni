ui <- fluidPage(
  titlePanel("Explore Olympic Medal Data"),

  sidebarLayout(
    sidebarPanel(
      selectInput("country", "Choose a country:",
                  choices = unique(OlympicsMedal$Country)),  # Dropdown menu
      helpText("Select a country to view its Olympic medal data.")
    ),

    mainPanel(
      textOutput("summaryText"),
      plotOutput("medalPlot")
    )
  )
)
