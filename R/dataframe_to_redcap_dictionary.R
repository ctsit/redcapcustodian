#' Create a REDCap data dictionary from a dataframe
#'
#' @param df the dataframe to generate the data dictionary for
#' @param form_name  the form name to display in REDCap
#' @param record_id_col a column in the dataframe that uniquely  identifies each record
#'
#' @return A redcap data dictionary
#' @export
#'
#' @examples
#' \dontrun{
#'
#' df <- data.frame(
#'   pk_col = c("a1", "a2", "a3"),
#'   integer_col = c(1, 2, 3),
#'   numeric_col = 5.9,
#'   character_col = c("a", "b", "c"),
#'   date_col = as.Date("2011-03-07"),
#'   date_time_col = as.POSIXct(strptime("2011-03-27 01:30:00", "%Y-%m-%d %H:%M:%S")),
#'   email_col = c("test@example.com", "test.2@example.edu", "3test@example.net")
#' )
#'
#' redcap_data_dictionary <- dataframe_to_redcap_dictionary(df, "test_form")
#' redcap_data_dictionary <- dataframe_to_redcap_dictionary(df, "test_form", "character_col")
#' }
dataframe_to_redcap_dictionary <- function(df,
                                           form_name,
                                           record_id_col = NULL) {
  contains_emails <- function(col) {
    email_pattern <- "^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
    return(any(grepl(email_pattern, col)))
  }

  get_validation_type <- function(col) {
    if (contains_emails(col)) {
      return("email")
    }

    col_type <- class(col)[1]
    switch(
      col_type,
      "numeric" = "number",
      "integer" = "number",
      "Date" = "datetime_ymd",
      "POSIXct" = "datetime_seconds_ymd",
      as.character(NA)
    )
  }

  # Rearrange the dataframe if a record_id_col is provided
  if (!is.null(record_id_col)) {
    ordered_df <- df |>
      dplyr::select(record_id_col, dplyr::everything())
  } else {
    ordered_df <- df
  }

  redcap_data_dictionary <- data.frame(
    field_name = names(ordered_df),
    form_name = form_name,
    section_header = as.character(NA),
    field_type = "text",
    field_label = names(ordered_df),
    select_choices_or_calculations = as.character(NA),
    field_note = as.character(NA),
    text_validation_type_or_show_slider_number = sapply(ordered_df, get_validation_type)
  )

  rownames(redcap_data_dictionary) <- NULL

  return(redcap_data_dictionary)
}
