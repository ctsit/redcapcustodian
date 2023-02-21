# REDCap Custodian

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6828728.svg)](https://doi.org/10.5281/zenodo.6828728)


This package simplifies data management activities on REDCap systems. It provides a framework for automating data extraction, transformation, and loading work (ETL). It supports ETL work within a REDCap, between REDCap projects, between REDCap systems, and with the REDCap database. It provides an extensible set of R functions, a Docker image, and an Rstudio Project template upon which a REDCap team can build ETL tasks that serve their REDCap systems and customers.

## Operating environment

`redcapcustodian` is an R package than can be referenced in any R script that needs to do ETL work against REDCap. To facilitate automation, this repository also provides a Dockerfile with R, redcapcustodian, and its required packages. The `Dockerfile` and `build.sh` can be used to build a Docker image named _redcapcustodian_ that can serve as the foundation for containers that serve your specific tasks.

To build upon that foundation, this repository also provides a folder, [`study_template`](./study_template/) that can be copied to a new folder and used as the starting point for an Rstudio project, R package, and Docker image that address the needs of a single study or data management project. All of these tools are designed to simplify development and reduce the burden of automating data reporting and recurring data management tasks.

In such an automated environment, each ETL job in this system is an Rscript run via Docker. Each report is an RMarkdown file again run via Docker. The design assumes the Docker containers are hosted on a Linux host with API access to one or more REDCap systems, a mail server, a MySQL database, and, optionally, the REDCap database itself.

For sites without container infrastructure, each image can be instantiated into a container via a cron job as documented in the files in [`examples/crons/`](examples/crons/). Each file in that folder runs a single job. To run a job, its cron script must be copied to the `/etc/cron.d/` folder on the Linux host. The `build.sh` script builds the redcapcustodian container upon which containers built by the study template would depend.


# How to use this project

This repository provides three elements that are designed to be used together in manage data on a single study or data-management project. It provides an R package, `redcapcustodian` that provides functions to facilitate credential management, database connections, data comparison, data synchronization, and logging. It provides a Dockerfile which rolls-up the redcapcustodian package, its dependencies and several other recommended R packages typically needed when working with REDCap. The repository also provides a [`study_template`](./study_template/) which can be used as the starting point for repository and Docker container to house and run your study's custom RScript, Rmarkdown, and R package. 

The REDCap Custodian package can be used in your custom RScript simply by installing it and loading the package in RStudio:

```r
install.packages("devtools")
devtools::install_github("ctsit/redcapcustodian")
library(redcapcustodian)
```

To use the Docker container, you'll need to checkout this repository with git and build it from the Dockerfile. If you are on a Mac or Linux computer those steps would look like this:

```sh
git clone git@github.com:ctsit/redcapcustodian.git
cd redcapcustodian
./build.sh
```

The procedure to use the study template is more involved, but it offers the most reward as well. See  [Writing your own redcapcustodian Rscripts](./docs/custom_rscript.md). It might also help to look at the [Developer Notes](./docs/developer_notes.md)

# Areas of REDCap interest

While much of the REDCap Custodian repository and package is about automating workflows, the package includes tools specific to REDCap.

- For API token management, see [Credential Scraping](docs/credential-scraping.html)
- For tools and procedures for moving production projects that use randomization, See [Randomization Management](docs/randomization_management.md)
- For bulk rights expiration, see the function `expire_user_project_rights()` in the package docs
