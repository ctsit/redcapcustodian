#' Render a Markdown Report from Rmd or Qmd Files
#'
#' This function renders a report from a R Markdown (.Rmd) or Quarto Markdown (.Qmd) script.
#' It is designed to be invoked from `render_report.R`. The rendered report is saved in either PDF or HTML format with a
#' timestamp appended to the filename.
#'
#' @param script_path The full path of the script to render
#
#' @return A list containing details about the operation's outcome:
#'
#'  If rendering is successful, the list includes:
#'    \itemize{
#'      \item `success`: TRUE
#'      \item `report_name`: The name of the report file.
#'      \item `filepath`: The full path to the report.
#'  }
#'   If rendering fails, the list includes:
#'   \itemize{
#'     \item `success`: FALSE
#'      \item `logfile`: The full path to the log file.
#'  }
#'
#' @export

#' @examples
#' \dontrun{
#' script_path <- here::here("report", "quarto_html_example.qmd")
#' render_results <- render_report(script_path)
#' }
#'
#'
render_report <- function(script_path) {

  script_path_without_extension <- tools::file_path_sans_ext(script_path)
  base_script_name <- basename(script_path_without_extension)
  logfile <- paste0(script_path_without_extension, "_log.txt")

  result <- tryCatch({
    capture.output(quarto::quarto_render(script_path), file = logfile)
    list(success = TRUE)
  }, error = function(e) {
    list(success = FALSE, logfile = logfile)
  })

  if (!result$success) {
    return(result)
    stop("Report rendering failed: ", result$error)
  }

  default_filenames <- paste0(script_path_without_extension, c(".pdf", ".html"))

  for (default_filename in default_filenames) {
    if (file.exists(default_filename)) {
      file_extension <- tools::file_ext(default_filename)

      report_name <- paste0(
        base_script_name,
        "_",
        format(redcapcustodian::get_script_run_time(), "%Y-%m-%d_%H%M%S"),
        ".",
        file_extension
      )

      report_filepath <- here::here("report", "output", report_name)

      file.rename(default_filename, report_filepath)

      return(list(success = result$success, report_name = report_name, filepath = report_filepath))
    }
  }
}
