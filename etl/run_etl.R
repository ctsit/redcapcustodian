library(redcapcustodian)
library(dotenv)
library(callr)
library(argparse)

set_script_run_time()

parser <- ArgumentParser()
parser$add_argument("script_name", help="Script to be run")
parser$add_argument("--optional_args", nargs='*', help="Zero or more optional arguments of any type")

if (!interactive()) {
  args <- parser$parse_args()
} else {
  args <- parser$parse_args(
    c(
      "study_template/etl/test_failure_alert.R",
      "--optional_args",
      "test",
      "another test"
    )
  )
}

script_name <- args$script_name
optional_args <- args$optional_args

if(!fs::file_exists(script_name)) {
  stop(sprintf("Specified file, %s, does not exist", script_name))
}

tryCatch({
  if (length(optional_args) == 0) {
    rscript(script = script_name, stderr = "log.txt")
  } else {
    rscript(script = script_name, cmdargs = optional_args, stderr = "log.txt")
  }
}, error = function(e) {
  email_body <- "See the attached log for error details."
  script_path <- paste(basename(getwd()), script_name, sep = "/")
  email_subject <- paste0("Failed | ", script_path, " | ", format(get_script_run_time(), "%Y-%m-%d"))
  file_name = "log.txt"

  send_email(email_body = email_body, email_subject = email_subject, file_name = file_name)
})



