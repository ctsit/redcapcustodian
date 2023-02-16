#' Format and write summary metrics to the redcap_summary_metrics table in your LOG_DB
#'
#' @param reporting_period_start a datetime object, e.g. ymd_hms("2022-11-01 00:00:00")
#' @param reporting_period_end a datetime object, e.g. ymd_hms("2022-12-01 00:00:00")
#' @param metric_type a character string representing the metric type, e.g. "flux", "state"
#' @param metric_dataframe A wide data frame of key-value pairs with a single row of data
#'
#' @return nothing
#'
#' @export
#' @examples
#' \dontrun{
#'  write_summary_metrics(
#'    reporting_period_start = ymd_hms("2022-01-01 00:00:00", tz=Sys.getenv("TIME_ZONE")),
#'    reporting_period_end = ceiling_date(reporting_period_start, "month", change_on_boundary = T)
#'    metric_type = "state",
#'    metric_dataframe = my_cool_df
#'  )
#' }
write_summary_metrics <- function(reporting_period_start,
                                  reporting_period_end,
                                  metric_type,
                                  metric_dataframe) {

  tall_df <- metric_dataframe %>%
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "key",
      values_to = "value"
    ) %>%
    cbind(
      reporting_period_start,
      reporting_period_end,
      metric_type,
      script_name = get_script_name(),
      script_run_time = get_script_run_time()
    ) %>%
    dplyr::select(
      "reporting_period_start",
      "reporting_period_end",
      "key",
      "value",
      "metric_type",
      "script_name",
      "script_run_time"
    )

  log_conn <- get_package_scope_var("log_con")

  # log data in redcap_summary_metrics
  DBI::dbAppendTable(log_conn, "redcap_summary_metrics", tall_df)
}
