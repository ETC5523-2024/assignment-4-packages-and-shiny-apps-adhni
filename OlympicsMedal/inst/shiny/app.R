library(shiny)
library(leaflet)
library(dplyr)
library(countrycode)
library(rnaturalearth)
library(rnaturalearthdata)
library(tidyverse)
library(DT)

# Load the OlympicsMedal dataset from the package's data directory
load("data/OlympicsMedal.rda")

# Ensure that OlympicsMedal has the iso_a3 column
OlympicsMedal <- OlympicsMedal %>%
  mutate(iso_a3 = countrycode(Country, "country.name", "iso3c")) %>%
  mutate(iso_a3 = ifelse(is.na(iso_a3), "UNKNOWN", iso_a3))

# Load world map data with ISO3 codes
world <- ne_countries(scale = "medium", returnclass = "sf") %>%
  select(iso_a3, geometry) %>%
  left_join(OlympicsMedal, by = "iso_a3")

# Define color palette based on the number of total medals
color_palette <- colorNumeric(
  palette = c("#FFD700", "#C0C0C0", "#cd7f32"),
  domain = world$Total,
  na.color = "grey"
)

# Define the UI
ui <- fluidPage(
  tags$style(HTML("
    body {
      background-color: #a499c3; /* Solid background color */
      font-family: 'Roboto', sans-serif; /* Updated font */
    }
    .title {
      text-align: center;
      color: #002e54; /* Darker color for better contrast */
      margin: 20px 0;
      font-size: 48px; /* Larger font size */
      font-weight: 700; /* Bold font */
      letter-spacing: 1px; /* Spacing between letters */
      padding: 10px 20px; /* Padding around text */
      background-color: rgba(255, 255, 255, 0.8); /* Light background */
      border-radius: 8px; /* Rounded corners */
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* Subtle shadow */
    }
    .table-container {
      background-color: rgba(255, 255, 255, 0.9); /* Light background for table */
      padding: 20px;
      border-radius: 8px; /* Rounded corners */
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* Light shadow */
    }
    .medal-info {
      padding: 15px;
      background: rgba(255, 255, 255, 0.9); /* Light background for medal info */
      border-radius: 8px; /* Rounded corners */
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2); /* Light shadow */
      margin-top: 20px;
      display: flex; /* Use flexbox for layout */
      justify-content: space-around; /* Evenly distribute items */
    }
    .medal-box {
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 5px;
      padding: 15px; /* Increased padding for height */
      margin: 5px;
      width: 120px; /* Fixed width for consistency */
      height: 70px; /* Fixed height for consistency */
      font-weight: bold; /* Bold text */
      font-size: 24px; /* Larger font size */
    }
    .gold { background-color: gold; }
    .silver { background-color: silver; color: black; }
    .bronze { background-color: #cd7f32; }
    .total { background-color: #002e54; color: white; } /* Darker background for total */
  ")),
  titlePanel("", windowTitle = "Olympic Medal Data"),
  tags$h1(class = "title", "Explore Olympic Medal Data for the 2024 Paris Olympics"),

  sidebarLayout(
    sidebarPanel(
      class = "table-container",
      DTOutput("medal_table")  # Move the table to the sidebar
    ),
    mainPanel(
      leafletOutput("map", height = 500),
      hr(),
      uiOutput("country_info")
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  # Render the static map with enhanced color scheme
  output$map <- renderLeaflet({
    leaflet(world, options = leafletOptions(zoomControl = FALSE, dragging = FALSE)) %>%
      setView(lng = 0, lat = 20, zoom = 2) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~color_palette(Total),
        fillOpacity = 0.7,
        color = "white",
        weight = 1,
        layerId = ~iso_a3,
        label = ~Country,
        highlightOptions = highlightOptions(
          weight = 5,
          color = "#666",
          fillOpacity = 0.7,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(
        pal = color_palette,
        values = ~Total,
        title = "Total Medals",
        position = "topright"
      )
  })

  # Display medal data when a country is clicked
  observeEvent(input$map_shape_click, {
    country_iso <- input$map_shape_click$id

    selected_country <- world %>%
      filter(iso_a3 == country_iso) %>%
      select(Country, Gold, Silver, Bronze, Total) %>%
      as.data.frame()

    if (nrow(selected_country) > 0) {
      output$country_info <- renderUI({
        tagList(
          h3(class = "title", paste("Medals for", selected_country$Country)),
          div(class = "medal-info",
              div(class = "medal-box gold", span("🥇 ", selected_country$Gold, style = "font-size: 28px;")),
              div(class = "medal-box silver", span("🥈 ", selected_country$Silver, style = "font-size: 28px;")),
              div(class = "medal-box bronze", span("🥉 ", selected_country$Bronze, style = "font-size: 28px;")),
              div(class = "medal-box total", paste("Total: ", selected_country$Total, style = "font-size: 28px;"))  # Removed emoji from total
          ),
          p("Click another country on the map to view detailed medal information.")
        )
      })
    } else {
      output$country_info <- renderUI({
        h4("Click a country on the map to view medal information.")
      })
    }
  })

  # Render the medal table with only the specified columns
  output$medal_table <- renderDT({
    datatable(OlympicsMedal %>% select(Country, Gold, Silver, Bronze, Total),
              options = list(pageLength = 10, lengthMenu = c(10, 25, 50),
                             dom = 'tp',  # No search box or extra controls
                             pagingType = 'simple'),  # Simple pagination
              rownames = FALSE,
              colnames = c("Country", "Gold", "Silver", "Bronze", "Total"))
  })
}

# Run the application
shinyApp(ui = ui, server = server)


