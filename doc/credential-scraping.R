## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(redcapcustodian)

## ---- eval=FALSE--------------------------------------------------------------
#  library(redcapcustodian)
#  library(DBI)
#  library(tidyverse)
#  library(dotenv)
#  
#  # fetching all extant API tokens and adding them to storage #################
#  
#  dir.create("credentials")
#  
#  # creates file if one does not exist
#  file_conn <- DBI::dbConnect(RSQLite::SQLite(), "credentials/credentials.db")
#  
#  # SQLite friendly schema
#  credentials_sql <- "CREATE TABLE IF NOT EXISTS `credentials` (
#    `redcap_uri` TEXT NOT NULL,
#    `server_short_name` varchar(128) NOT NULL,
#    `username` varchar(191) NOT NULL,
#    `project_id` int(10) NOT NULL,
#    `project_display_name` TEXT NOT NULL,
#    `project_short_name` varchar(128) DEFAULT NULL,
#    `token` varchar(64) NOT NULL,
#    `comment` varchar(256) DEFAULT NULL
#  );
#  "
#  
#  dbExecute(file_conn, credentials_sql)

## ---- eval = FALSE------------------------------------------------------------
#  library(redcapcustodian)
#  library(DBI)
#  library(tidyverse)
#  library(dotenv)
#  
#  # fetching all extant API tokens and adding them to storage #################
#  
#  file_conn <- DBI::dbConnect(RSQLite::SQLite(), "credentials/credentials.db")
#  
#  dbExecute(file_conn, credentials_sql)
#  
#  load_dot_env("prod.env")
#  
#  username <- "your_redcap_username"
#  source_conn <- connect_to_redcap_db()
#  source_credentials <- scrape_user_api_tokens(source_conn, username)
#  
#  # alter credentials to match local schema
#  source_credentials_upload <- source_credentials %>%
#    mutate(
#      redcap_uri = Sys.getenv("URI"),
#      server_short_name = tolower(Sys.getenv("INSTANCE"))
#    ) %>%
#    # remove duplicates
#    anti_join(
#      tbl(file_conn, "credentials") %>%
#        collect()
#    )
#  
#  dbAppendTable(file_conn, "credentials", source_credentials_upload)

## ---- eval = FALSE------------------------------------------------------------
#  library(redcapcustodian)
#  library(DBI)
#  library(tidyverse)
#  library(dotenv)
#  
#  file_conn <- DBI::dbConnect(RSQLite::SQLite(), "credentials/credentials.db")
#  
#  load_dot_env("local_1134.env")
#  
#  # note, this will close any other connections
#  target_conn <- connect_to_redcap_db()
#  
#  local_credentials <- scrape_user_api_tokens(target_conn, "admin")
#  
#  # specify a subset of project_ids rather than making tokens for all
#  target_pids <- tbl(target_conn, "redcap_projects") %>%
#    select(project_id) %>%
#    filter(project_id > 15) %>%
#    filter(!project_id %in% local(local_credentials$project_id)) %>%
#    collect() %>%
#    pull(project_id)
#  
#  # create tokens individually
#  for(pid in target_pids) {
#    set_project_api_token(target_conn, "admin", pid)
#  }
#  
#  # gather newly created tokens and insert them into local storage
#  local_credentials <- scrape_user_api_tokens(target_conn, "admin")
#  
#  local_credentials_upload <- local_credentials %>%
#    mutate(
#      redcap_uri = Sys.getenv("URI"),
#      server_short_name = tolower(Sys.getenv("INSTANCE"))
#    ) %>%
#    # remove duplicates
#    anti_join(
#      tbl(file_conn, "credentials") %>%
#        collect()
#    )
#  
#  dbAppendTable(file_conn, "credentials", local_credentials_upload)

## ---- eval = FALSE------------------------------------------------------------
#  library(redcapcustodian)
#  library(tidyverse)
#  
#  file_conn <- DBI::dbConnect(RSQLite::SQLite(), "credentials/credentials.db")
#  
#  source_username <- "your_production_username"
#  
#  source_credentials <- tbl(file_conn, "credentials") %>%
#    filter(source_username) %>%
#    filter(server_short_name == "prod") %>%
#    collect() %>%
#    filter(
#      str_detect(project_display_name, "The big important project")
#    ) %>%
#    unnest()
#  
#  local_credentials <- tbl(file_conn, "credentials") %>%
#    filter(username == "admin") %>%
#    filter(server_short_name == "local_1134") %>%
#    collect() %>%
#    # adjust url to make REDCapR's validation processes happy
#    mutate(redcap_uri = str_replace(redcap_uri, "https", "http")) %>%
#    mutate(redcap_uri = str_replace(redcap_uri, "localhost", "127.0.0.1")) %>%
#    filter(
#      str_detect(project_display_name, "The big important project")
#    ) %>%
#    unnest()
#  
#  sync_metadata(source_credentials, local_credentials, strip_action_tags = TRUE)

