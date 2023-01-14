library(tidyverse)
library(dotenv)
library(REDCapR)
library(lubridate)
library(rmarkdown)
library(sendmailR)
library(redcapcustodian)

init_etl("render_report")

if (!dir.exists("output")){
  dir.create("output")
}

if (!interactive()) {
  args <- commandArgs(trailingOnly = T)
  script_name <- word(args, 2, sep = "=")
} else {
  script_name <- "sample_report.Rmd"
}

report_name <- word(script_name, 1, sep = "\\.")

script_run_time <- set_script_run_time()

output_file <- here::here(
  "output",
  paste0(report_name,
  "_",
  format(script_run_time, "%Y%m%d%H%M%S"))
)

full_path_to_output_file <- render(
  here::here("report", script_name),
  output_file = output_file
)

output_file_extension <- word(full_path_to_output_file, 2 , sep = "\\.")
attachment_object <- mime_part(full_path_to_output_file, paste0(basename(output_file), ".", output_file_extension))

email_subject <- paste(report_name, "|", script_run_time)
body <- "Please see the attached report."

email_body <- list(body, attachment_object)

# send the email with the attached output file
send_email(email_body, email_subject)

log_job_success(jsonlite::toJSON(script_name))
