#' dataframe_to_redcap_dictionary
#'
#' Create a REDCap data dictionary for a dataframe
#'
#' @param df the dataframe to generate the data dictionary for
#' @param form_name  the form name to display in REDCap
#' @param write_to_csv If TRUE will write the datadictionary to a csv.
#' @param filename A string specifying the filename for the CSV.
#'
#' @return A redcap data dictionary
#' @export
#'
#' @examples
#' \dontrun{
#'
#' df <- data.frame(
#'   numeric_col = c(1, 2, 3),
#'   integer_col = as.integer(5.9),
#'   character_col = c("a", "b", "c"),
#'   date_col = as.Date("2011-03-07"),
#'   date_time_col = as.POSIXct(strptime("2011-03-27 01:30:00", "%Y-%m-%d %H:%M:%S"))
#' )
#'
#' redcap_data_dictionary <- dataframe_to_redcap_dictionary(df, "test")
#' redcap_data_dictionary <- dataframe_to_redcap_dictionary(df, "test", TRUE, "<output_path>.csv")
#' }
dataframe_to_redcap_dictionary <- function(
    df,
    form_name,
    write_to_csv = FALSE,
    filename = NULL) {

  get_validation_type <- function(col) {
    col_type <- class(col)[1]
    switch(col_type,
           "numeric" = "number",
           "integer" = "integer",
           "Date" = "date_dmy",
           "POSIXct" = "datetime_dmy",
           "text")
  }

  # create unique identifier for each record
  df$record_id <- seq_len(nrow(df))
  # make record_id the first column
  df <- df[, c("record_id", setdiff(names(df), "record_id"))]

  redcap_data_dictionary <- data.frame(
    field_name = names(df),
    form_name = form_name,
    section_header = as.character(NA),
    field_type = "text",
    field_label = names(df),
    select_choices_or_calculations = as.character(NA),
    field_note = as.character(NA),
    text_validation_type_or_show_slider_number = sapply(df, get_validation_type)
  )

  rownames(redcap_data_dictionary) <- NULL

  if (write_to_csv) {
    if(is.null(filename)) {
      stop("Please provide a filename if you want to write to CSV.")
    }
    utils::write.csv(redcap_data_dictionary, filename, na = "", row.names = FALSE)
  }

  return(redcap_data_dictionary)
}








