library(redcapcustodian)
library(dotenv)
library(callr)
library(argparse)

set_script_run_time()

parser <- ArgumentParser()
parser$add_argument("script_name", nargs=1, help="Script to be run")

if (!interactive()) {
  args <- parser$parse_args()
  script_name <- args$script_name
  if(!fs::file_exists(script_name)) {
    stop(sprintf("Specified file, %s, does not exist", script_name))
  }
} else {
  script_name <- "etl/dummy_script.R"
  if(!fs::file_exists(script_name)) {
    stop(sprintf("Specified file, %s, does not exist", script_name))
  }
}

tryCatch({
  callr::rscript(script_name, stderr = "log.txt")
}, error = function(e) {
  email_body <- "See the attached log for error details."
  script_path <- paste(basename(getwd()), script_name, sep = "/")
  email_subject <- paste0("Failed | ", script_path, " | ", format(get_script_run_time(), "%Y-%m-%d"))
  file_name = "log.txt"

  send_email(email_body = email_body, email_subject = email_subject, file_name = file_name)
})



