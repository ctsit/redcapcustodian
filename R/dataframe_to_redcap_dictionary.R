#' Create a REDCap data dictionary from a dataframe
#'
#' @param df the dataframe to generate the data dictionary for
#' @param record_id_col a column in the dataframe that uniquely  identifies each record
#' @param form_name  the form name to display in REDCap
#' @param write_to_csv If TRUE will write the data dictionary to a csv.
#' @param filename A string specifying the filename for the CSV.
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
#' redcap_data_dictionary <- dataframe_to_redcap_dictionary(df, "pk_col", "test_form")
#' redcap_data_dictionary <- dataframe_to_redcap_dictionary(
#' df, "pk_col", "test_form"
#' TRUE, "<output_path>.csv"
#' )
#' }
dataframe_to_redcap_dictionary <- function(df,
                                           record_id_col,
                                           form_name,
                                           write_to_csv = FALSE,
                                           filename = NULL) {
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

  if (!record_id_col %in% names(df)) {
    stop("The provided record_id_col does not exist in the input dataframe.")
  }

  # create the record_id and make it the first column in df
  df_with_record_id <- df |>
    dplyr::rename(record_id = tidyselect::all_of(record_id_col)) |>
    dplyr::select("record_id", dplyr::everything())

  df_with_ordered_cols <- df |>
    dplyr::select(tidyselect::all_of(record_id_col), dplyr::everything())

  redcap_data_dictionary <- data.frame(
    field_name = names(df_with_record_id),
    form_name = form_name,
    section_header = as.character(NA),
    field_type = "text",
    field_label = names(df_with_ordered_cols),
    select_choices_or_calculations = as.character(NA),
    field_note = as.character(NA),
    text_validation_type_or_show_slider_number = sapply(df_with_record_id, get_validation_type)
  )

  rownames(redcap_data_dictionary) <- NULL

  if (write_to_csv) {
    if (is.null(filename)) {
      stop("Please provide a filename if you want to write to CSV.")
    }
    utils::write.csv(redcap_data_dictionary,
                     filename,
                     na = "",
                     row.names = FALSE)
  }

  return(redcap_data_dictionary)
}
