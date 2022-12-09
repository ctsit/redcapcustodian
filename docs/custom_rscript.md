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

If this is your first redcapcustodian project, it might help to follow the [Friday Call Demo](../docs/friday-call-demo.Rmd) in RStudio. That example was created to present REDCap Custodian to the REDCap community. 

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

The task or study you are working on might need its own database tables. They might hold data that does not need to be in REDCap or data that does not fit well in the REDCap data model. If your REDCap projects are very large (think 30K records or more) you might want to mirror some or all of your REDCap project into MySQL to run more performant queries. If any of that describes your need, its best to not mix those tables with the REDCap tables. That second MySQL table will have its own credentials and you scripts will need accessto those secrets. The "ETL" prefix is nothing special, it means "Extract, Transform, and Load"--a common term in database management. You can use any prefix you like, but you _will_ want to use a prefix. The database connection functions depend on it.

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

## REDCap API credential management

It's possible to do credential management with environment variables, but it quickly gets tedious. It get's very tedious if you have to manage multiple API tokens. To address that, REDCap custodian provides a few credential management functions to help you make an use a local dataset of REDCAp API credentials.  See [Credential Scraping](./credential-scraping.html) for an example of how to do it. Read down through _Scraping a server’s API tokens and putting them in a local sqlite DB_ 

## Create your scripts in the right folder

Create scripts that will move or clean data in the `etl` folder. Create reports in the `reports` folder. These aren't rules, but they are useful conventions. Each of these has been excluded from the package build process so _if_ you make a package the code in these folders won't cause warnings in the build.

## Tiny script example

REDCap custodian includes an example report script to describe your REDCap users at [REDCap User Lifecycle](../report/redcap_user_lifecycle.Rmd). It provides an example of a report you could run against your own REDCap system. We also have an example of the [report output](./redcap_user_lifecycle.pdf) from the University of Florida CTSI REDCap system with annotations that explain what it tells you about the history and activity of the UF system.

## Logging

REDCap Custodian provides valuable logging that reduce the stress of running unattended jobs writing data to important things. To use the logging you need to create a MySQL/Maria DB, put its credentials in your environment file as described above, load the redcapcustodian package in your script, and initialize the logging. You can and should also log success at the end of the script and log warnings or failure where your script can detect them.  Here's an actual script that makes some changes in the redcap backend and logs what is did:

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

To query the job log, use your favorite DB client. If you are a Tidyverse developer, dplyr::tbl() is a fantastic DB client.

## Writing good data management code

This is too big a topic to cover here but it is central to the entire effort so it can't entirely be ignored. The best favor you can do for yourself and your customers, is to use good tools. At CTS-IT, we have identified a toolset that allows us to be efficient in our programming. We strongly recommend these tools:

* R for 99% of our data programming.
* RStudio as the easiest possible integrated development environment for R programming.
* Tidyverse as the most effective dialect of R to code in.
* REDCapR for 99% of REDCap API access.
* DBI and dplyr::tbl() for access to SQL tables.

It's also wise to have a good software development workflow. At CTS-IT we use these tools and rules:

* Use version control for all code.
* If you have more than one developer, do code review of _everything_.
* If you have more than one developer, use the Github workflow of pull requests, review, and merges to manage code review.
* Never put secrets in your code. Put secrets environment variables, datasets, or other systems.
* Never put secrets in version control.
* Don't put configuration in code. Instead put it in the environment variables or datasets.

Stop and think about architecture and study lifecycle.

* Don't mix two studies in on git repository.
* Don't be afraid to make an R package just for one study. 
* Think about names of things. Pick good names. Don't be afraid to rename poorly named things.


## Automation with container infrastructure

If you need something to run periodically, you need to make it easy to run with all of its dependencies packaged up and you need to schedule it. The modern way to package dependencies is to put them all into a container, add your application and run the container. REDCap Custodian supports containerization with Docker. The [`./study_template/Dockerfile`](./study_template/Dockerfile) is template you can use to containerize your RScript and RMarkdown. Adapt it to your needs and build the container with [./build.sh](./build.sh). If you have good container infrastructure, use it to build and deploy your containers. 

Running automated R Markdown reports from docker requires the use of an Rmd renderer.
[render_report.R](/study_template/report/render_report.R) contains functionality to knit an Rmd, email it and then log the job run. The Rmd script name is passed as a command line argument to [render_report.R](/study_template/report/render_report.R) via cron. Refer to [sample_report](/study_template/cron/sample_report) for an example cron job.
 
## Automation with Linux and cron

If you have no container management infrastructure available to you, but your IT support provides Linux hosts, have them build one for you, install Docker on it, and give you `sudo su` access. That will allow you to build and run docker images on the host. 

Login, git clone redcapcustodian's git repository, cd into the repository and build the image:

```sh
git clone git@github.com:ctsit/redcapcustodian.git
cd redcapcustodian
sudo ./build.sh
```

Do the same for your own study repository:

```sh
git clone git@github.com:ctsit/rcc.billing.git
cd rcc.billing
sudo ./build.sh
```

To clone a private repository, you'll need a deployment key.  See [Deploy Keys](https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys) for instructions.


Once you've built the study container on your Docker host, create a cron entry to run it with the right parameters and secrets. To run the above script, `etl/update_project_billable_attribute.R` regularly on a host you call 'prod', create a cron entry for it:

```sh
sudo su
cat <<END>> prod/cron/update_project_billable_attribute
# run update_project_billable_attribute at 6:07 a.m.
7 6 * * * root /usr/bin/docker run --rm --env-file /rcc/rcc.billing/prod.env rcc.billing Rscript rcc.billing/etl/update_project_billable_attribute.R
END
```

The build script has a `-d` option to automatically deploy the cron file and build time. If you place your cron file in the `./cron/` folder at the root of the repository, and build with `./build.sh -d`, the build script will copy the file to `/etc/cron.d` and give it a guaranteed unique name.


## Using version control

Once you go down this road of writing your own scripts, you should be very concerned about preserving them. One of the best ways to do this is via git version control. Initialize a new software repository in your `./my.study` folder. Then add a remote pointing at a new empty repository at GitHub, GitLab, BitBucket or your favorite Git repository hosting service, and push to that new repo.


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
