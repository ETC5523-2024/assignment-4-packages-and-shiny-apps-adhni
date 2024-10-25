#' Summarize Medal Counts
#'
#' This function summarizes the medal counts by country.
#'
#' @param df A data frame of medal data.
#' @return A summary table of medals by country.
#' @export
summarize_medals <- function(df) {
  aggregate(cbind(Gold, Silver, Bronze) ~ Country, data = df, sum)
}
