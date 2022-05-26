# REDCap Custodian

This package simplifies data management activities on REDCap systems. It provides a framework for automating data extraction, transformation, and loading work (ETL). It supports ETL work within a REDCap, between REDCap projects, between REDCap systems, and against the REDCap own database. It provides an extensible set of R functions upon which a REDCap team can build ETL tasks that serve their REDCap systems and customers.

## Operating environment

`redcapcustodian` is an R package than can be referenced in any R script that needs to do ETL work against REDCap. To facilitate automation, this repository also provides a Dockerfile with R, redcapcustodian, and its required packages. The `Dockerfile` and `build.sh` can be used to build a Docker image named _redcapcustodian_ that can serve as the foundation for containers that serve your specific tasks.

In such an automated environment, each ETL job in this system is an Rscript run via Docker. The design assumes the Docker containers are hosted on a Linux host with API access to open or more REDCap systems, a mail server, a MySQL database, and, optionally, the REDCap database itself.

For sites without container infrastructure, each image can be instantiated into a container via a cron job as documented in the files in [`examples/crons/`](examples/crons/). Each file in that folder runs a single job. To run a job, its cron script must be copied to the `/etc/cron.d/` folder on the Linux host. The `build.sh` script builds the containers and optionally deploys the environment files and cron scripts.

# Testing in Docker

First setup a `./site` folder by copying the contents of [`site_template`](../site_template/) to the `site` folder.

```sh
cp -r site_template/* site/
```

Build `redcapcustodian` and the `rcc.site` image:

```bash
./build.sh
```

This will build two images: `redcapcustodian` and `rcc.site`. The latter is built on top of the former.

To see the working directory contents run

```bash
docker run --rm rcc.site
```

To run the shared `hello.R` report within the shared container, run 

```bash
# run the script inside the container
docker run --env-file .env --rm redcapcustodian Rscript report/hello.R
```


## Writing your own redcapcustodian Rscripts

redcapcustodian supports custom code to address the specific needs of REDCap teams and projects. For details see [Writing your own redcapcustodian Rscripts](./docs/custom_rscript.md). It might also help to look at the [Developer Notes](./docs/developer_notes.md)
