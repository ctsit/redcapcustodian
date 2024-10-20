library(tidyverse)
library(dotenv)
library(sendmailR)
library(redcapcustodian)
library(argparse)

init_etl("render_report")

parser <- ArgumentParser()
parser$add_argument("script_path", nargs=1, help="The full path of the script to be run")
if (!interactive()) {
  args <- parser$parse_args()
  script_path <- args$script_path
  if(!fs::file_exists(script_path)) {
    stop(sprintf("Specified file, %s, does not exist", script_path))
  }
} else {
  script_path <- "report/sample_report.Rmd"
  if(!fs::file_exists(script_path)) {
    stop(sprintf("Specified file, %s, does not exist", script_path))
  }
}

render_results <- render_report(script_path)

if (render_results$success) {
  email_subject <- paste(render_results$report_name)
  attachment_object <- mime_part(render_results$filepath)
  body <- "Please see the attached report."
  email_body <- list(body, attachment_object)

  send_email(email_body, email_subject)

  # log_job_success(jsonlite::toJSON(basename(script_path)))
} else {
  email_body <- "Report failed to render."
  email_subject <- paste0("Failed | ", here::here(script_path), " | ", format(get_script_run_time(), "%Y-%m-%d"))
  send_email(email_body, email_subject)
}
