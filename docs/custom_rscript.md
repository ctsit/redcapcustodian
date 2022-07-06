# Writing your own redcapcustodian Rscripts

In its most basic use, redcapcustodian need only be load as a library in an Rscript. To automate a report or ETL already in redcapcustodian, you need only build the image, write a configuration file and instantiate the container form that image with that config file. Yet it allows for extensive customization that builds upon the framework it provides.

## Writing your own Rscripts

You can write your own Rscript to accomplish a task against one or more REDCap hosts or projects.  That script should load the _redcapcustodian_ package. To make your own script clone the redcap custodian repository, then copy the contents of [`study_template`](./study_template/) to a new folder 

```sh
git clone git@github.com:ctsit/redcapcustodian.git
cd 
cp -r redcapcustodian/site_template my.study
cd my.study
```

Rename the Rstudio project to match your study's name:

```sh
mv example.Rproj my.study.Rproj
```

Then you can open the new project in Rstudio. 

```sh
open my.study.Rproj
```

If this is your first redcapcustodian project, it might help to follow open the [Friday Call Demo](../docs/friday-call-demo.Rmd) in RStudio. That example was created to present REDCap Custodian to the REDCap community. 

If this is not your first REDCap Custodian rodeo, you might remember what you need to do, but we offer this guide to help avoid some mis-steps.

## Configure your interfaces

You'll need to talk to at least a REDCap or a MySQL database. You will probably want both. Rename the `example.env` to `testing.env` and configure it for development on your computer. That file is composed of five sections.

```sh
INSTANCE=Development
TIME_ZONE=America/New_York
```

`INSTANCE` names the REDCap system or _instance_ you'll be talking to. This file assumes you are talking to only one REDCap in your script. There are other tools for multiple-instances.

`TIME_ZONE` should be the local timezone of your REDCap instance. Note that REDCap time facts in local time. The MariaDB driver and the Lubridate library default to UTC. That can get complicated. Be careful with time. For more details see [`stupid_date_tricks.R`](https://gist.github.com/pbchase/ed55ab5dacbcc5d8a702a9cb935cccb5)

```sh
# Email config
EMAIL_TO=you@example.org
EMAIL_CC=
EMAIL_FROM=please-do-not-reply@example.org
SMTP_SERVER=smtp.example.org
```

Many script will need to send emails to the developers, the REDCap Admin or a study coordinator. Set the email values appropriately for your site and study needs.


```sh
# REDCap DB Credentials
REDCAP_DB_NAME=DB_NAME
REDCAP_DB_HOST=DB_HOST
REDCAP_DB_USER=DB_USER
REDCAP_DB_PASSWORD=DB_PASSWORD
REDCAP_DB_PORT=3306
```

If you need to talk directly to your REDCap database, you'll need to provide the credentials to that database. If you are doing development work, enter the credentials for your local MySQL Database. 

```r
# ETL DB Credentials
ETL_DB_NAME=
ETL_DB_HOST=
ETL_DB_USER=
ETL_DB_PASSWORD=
ETL_DB_SCHEMA=
ETL_DB_PORT=
```

The task or study you are working on might need its own database tables. They might hold data that does not need to be in REDCap or data that does not fit well in the REDCap data model. If your REDCap projects are very large (think 30K records or more) you might want to mirror some or all of your REDCap project into MySQL to run more performant queries. If any of that describes your need, its best to not mix those tables with the REDCap tables. That second MySQL table will have its own credentials and you scripts will need accessto those secrets. The "ETL" prefix is nothing special, it means "Extract, Transform, and Load"--a common term in databae management. You can use any prefix you like, but you _will_ want to use a prefix. The database connection functions depend on it.

```sh
# Log DB Credentials
LOG_DB_NAME=
LOG_DB_HOST=
LOG_DB_USER=
LOG_DB_PASSWORD=
LOG_DB_SCHEMA=
LOG_DB_PORT=
```

REDCap Custodian provides a rich framework for logging both success and failure of automated processes. By default, it logs activity to a MySQL databse of your choosing. This should _not_ be your REDCap database. It's completely reasonable to log a study's activity into your study database, but if you don't have a study database, a shared logging database is a good thing. Make sure to set `LOG_DB_` values.

## Create your scripts in the right folder

Create scripts that will move or clean data in the `etl` folder. Create reports in the `reports` folder. These aren't rules, but they are useful conventions. Each of these has been excluded from the package build process so _if_ you make a package the code in these folders won't cause warnings in the build.

## Logging

REDCap Custodian provides valuable logging that reduce the stress of running unattended jobs writing data to important things. TO use the logging you need to create a MySQL/Maria DB, put its credentials in your environment file as described above, load the redcapcustodian package in your script, and initialize the logging. You can and should also log success at the end of the script and log warnings or failure where your script can detect them.  Here's an actual script that makes some changes in the redcap backend and logs what is did:

```r
library(tidyverse)
library(redcapcustodian)
library(rcc.billing)
library(DBI)
library(dotenv)

init_etl("update_project_billable_attribute")

conn <- connect_to_redcap_db()

diff_output <- update_billable_by_ownership(conn)

sync_activity <- redcapcustodian::sync_table(
  conn = conn,
  table_name = "redcap_entity_project_ownership",
  primary_key = "id",
  data_diff_output = diff_output,
  insert = F,
  update = T,
  delete = F
)

activity_log <- diff_output$update_records %>%
  select(pid, billable, updated)

log_job_success(jsonlite::toJSON(activity_log))
```

That script generated this log record in the log database:

```sql
INSERT INTO `rcc_job_log` (`job_duration`, `job_summary_data`, `level`, `log_date`, `script_name`, `script_run_time`) VALUES
(80.16091799736023, '[{\"pid\":15,\"billable\":1,\"updated\":1657139254},{\"pid\":16,\"billable\":1,\"updated\":1657139254},{\"pid\":22,\"billable\":1,\"updated\":1657139254}]', 'SUCCESS', '2022-07-06 20:28:54.494426', 'update_project_billable_attribute', '2022-07-06 20:27:34.322926');
```

`job_summary_data` is a JSON object of all of the data updated. It's hard for humans to read but 100% machine parsable.


## Cron entries

To run your custom `etl/cleanup_bad_email_addresses.R` script regularly on a host you call 'prod', create a cron entry for it:

```sh
cat <<END>> prod/cron/cleanup_bad_email_addresses
# Clean up bad email addresses daily at 6:07 a.m.
7 6 * * * root /usr/bin/docker run --rm --env-file /rcc/prod.env rcc.site Rscript redcapcustodian/etl/cleanup_bad_email_addresses.R
END
```

## Using version control

Once you go down this road of writing your own scripts, you should be very concerned about preserving them. One of the best ways to do this is via git version control. Initialize a new software repository in your `./my.study` folder. Then add a remote pointin at a new empty repository at GitHub, GitLab, BitBucket or your favorite Git repository hosting service, and push to that new repo.


## Adding a custom package

If you want to do complex things in your redcapcustodian Rscripts or share custom code between them, you might want to add your own R package just for redcapcustodian work. redcapcustodian supports the development of such a package within the `./my.study/` folder. 

The RStudio team's [packaging guidelines](https://r-pkgs.org/) are an excellent guide for package development. They might seem lke a lot to take in, but they solve common problems. They will help you write better code. You don't need to submit a package to CRAN to get value from the packaging guidelines.

To build the latest version of the package as you build a task container, uncomment these lines in the task's `Dockerfile` and customize them with your package name:

```
# Add, build, and install this study's package
ADD .. /home/rocker/my.study
RUN R CMD build my.study
RUN R CMD INSTALL my.study*.tar.gz
RUN rm -rf my.study
```
