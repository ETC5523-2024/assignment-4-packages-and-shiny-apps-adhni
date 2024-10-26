# Load necessary libraries
library(shiny)
library(leaflet)
library(dplyr)
library(countrycode)
library(rnaturalearth)
library(rnaturalearthdata)

# Load the OlympicsMedal dataset
load("data/OlympicsMedal.rda")

# Ensure that OlympicsMedal has the iso_a3 column
OlympicsMedal <- OlympicsMedal %>%
  mutate(iso_a3 = countrycode(Country, "country.name", "iso3c")) %>%
  mutate(iso_a3 = ifelse(is.na(iso_a3), "UNKNOWN", iso_a3))

# Load world map data with ISO3 codes
world <- ne_countries(scale = "medium", returnclass = "sf") %>%
  select(iso_a3, geometry) %>%
  left_join(OlympicsMedal, by = "iso_a3")

# Define UI
ui <- fluidPage(
  titlePanel("Explore Olympic Medal Data on World Map"),

  # Main panel with map and medal details below
  mainPanel(
    leafletOutput("map", height = 500),
    hr(),
    uiOutput("country_info")  # Medal information displayed below the map
  )
)

# Define server logic
server <- function(input, output, session) {

  # Render the map without interactivity
  output$map <- renderLeaflet({
    leaflet(world, options = leafletOptions(zoomControl = FALSE, dragging = FALSE)) %>%
      setView(lng = 0, lat = 20, zoom = 2) %>%  # Centered view
      addTiles() %>%
      addPolygons(
        fillColor = "blue",
        fillOpacity = 0.5,
        color = "white",
        weight = 1,
        layerId = ~iso_a3,
        label = ~Country
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
          h3(paste("Medals for", selected_country$Country)),
          div(
            style = "display: flex; justify-content: center; gap: 15px;",
            div(
              style = "padding: 10px; background-color: gold; border-radius: 10px; text-align: center; width: 80px; color: white;",
              span("🥇", style = "font-size: 20px;"),
              p("Gold:", selected_country$Gold, style = "font-weight: bold;")
            ),
            div(
              style = "padding: 10px; background-color: silver; border-radius: 10px; text-align: center; width: 80px; color: black;",
              span("🥈", style = "font-size: 20px;"),
              p("Silver:", selected_country$Silver, style = "font-weight: bold;")
            ),
            div(
              style = "padding: 10px; background-color: #cd7f32; border-radius: 10px; text-align: center; width: 80px; color: white;",
              span("🥉", style = "font-size: 20px;"),
              p("Bronze:", selected_country$Bronze, style = "font-weight: bold;")
            ),
            div(
              style = "padding: 10px; background-color: #333; border-radius: 10px; text-align: center; width: 80px; color: white;",
              span("🏅", style = "font-size: 20px;"),
              p("Total:", selected_country$Total, style = "font-weight: bold;")
            )
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
}

# Run the application
shinyApp(ui = ui, server = server)


