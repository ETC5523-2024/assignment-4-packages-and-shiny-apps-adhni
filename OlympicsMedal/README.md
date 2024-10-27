# OlympicsMedal <img src="man/figures/OlympicsMedal.png" align="right" height="80" width="80" alt="" />

OlympicsMedal offers a comprehensive toolkit to analyze data related to the Olympic Games. This package empowers users to explore medal distribution, country performance, and trends over the years, with seamless integration of an interactive Shiny dashboard for deeper insights.

Imagine you are an analyst working for an Olympic committee. Your team is conducting this study to help strategize future performance enhancements. Through this analysis, the goal is to uncover key trends in medal counts and country performances, providing actionable insights for decision-making.

## Installation

You can install the development version of OlympicsMedal from [GitHub](https://github.com/ETC5523-2024/assignment-4-packages-and-shiny-apps-adhni/tree/main/OlympicsMedal) with:


```r
# Install remotes if you don't have it
install.packages("remotes")

# Install the OlympicsMedal package
remotes::install_github("ETC5523-2024/assignment-4-packages-and-shiny-apps-adhni", subdir = "OlympicsMedal")

```

## Usage

After installation, load the package:

```r
library(OlympicsMedal)
```

You can load the Olympic medal dataset using:

```r
OlympicsMedal <- data("OlympicsMedal")
```

## Shiny App
The OlympicsMedal package includes a built-in Shiny app for interactive data exploration. You can launch the app with:

shiny::runApp('inst/shiny')





