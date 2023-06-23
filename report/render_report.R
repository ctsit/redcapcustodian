library(tidyverse)
library(dotenv)
library(REDCapR)
library(lubridate)
library(rmarkdown)
library(sendmailR)
library(redcapcustodian)
library(argparse)

init_etl("render_report")

parser <- ArgumentParser()
parser$add_argument("script_name", nargs=1, help="Script to be run")
if (!interactive()) {
  args <- parser$parse_args()
  script_name <- args$script_name
  if(!fs::file_exists(script_name)) {
    stop(sprintf("Specified file, %s, does not exist", script_name))
  }
} else {
  script_name <- "dummy.qmd"
  stop(sprintf("Specified file, %s, does not exist", script_name))
}

report_name <- word(script_name, 1, sep = "\\.")
report_type <- word(script_name, 2, sep = "\\.")

script_run_time <- set_script_run_time()
output_file <-
  paste0(str_replace(report_name, ".*/", ""),
         "_",
         format(script_run_time, "%Y%m%d%H%M%S"),
         if_else(report_type == "qmd", ".pdf", "")
         )

if (report_type == "qmd") {
  quarto::quarto_render(
    script_name,
    output_file = output_file,
    output_format = "pdf"
  )
} else {
  render(
    script_name,
    output_file = output_file
  )
}

output_file_extension <- word(output_file, 2 , sep = "\\.")
attachment_object <- mime_part(output_file, output_file)

email_subject <- paste(report_name, "|", script_run_time)
body <- "Please see the attached report."

email_body <- list(body, attachment_object)

# send the email with the attached output file
send_email(email_body, email_subject)

log_job_success(jsonlite::toJSON(script_name))
