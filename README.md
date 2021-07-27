# REDCap Custodian

This project automates data grooming activities that support the business of running a REDCap service. It detects, corrects, and reports on data issues with scheduled processes. It provides an extensible set of R functions and an automation framework upon which a REDCap team can build data grooming tasks that serve their REDCap system.

## Operating environment

Each ETL job in this system is an Rscript run via Docker. The design assumes the Docker containers are hosted on a Linux host with access to the REDCap's MySQL server and a mail server. 

A shared Docker image, _redcapcustodian_, is the foundation for host-specific Docker images used to run the scripts. Each container is instantiated via a cron job as documented in the files in [`examples/crons/`](examples/crons/). Each file in that folder runs a single job. To run a job, its cron script must be copied to the `/etc/cron.d/` folder on the Linux host. The `build.sh` script builds the containers and optionally deploys the environment files and cron scripts.


## Release and Deployment

This project uses the Git Flow workflow for releases. Every release should be versioned and have a ChangeLog entry that describes the new features and bug fixes. Every release should also be accompanied by an updated `VERSION` and a manual revision to the version number in [`DESCRIPTION`](./DESCRIPTION). The latter tells devtools about version number changes. The former allows image builds to be tagged as they are built by the `build.sh`

To deploy a new release on the Linux host, execute this series of commands or an equivalent from your home directory on that host:

```bash
git clone git@github.com:ctsit/redcapcustodian.git
cd redcapcustodian
git pull
sudo ./build.sh -d <hostname>
```


# Testing in Docker

To build an updated `redcapcustodian` image for an _example_ host, create a host folder from the template:

```bash
./make_host.sh example
```

Build `redcapcustodian` and the `example` host image:

```bash
./build.sh example
```

This will build two images: `redcapcustodian` and `rcc_example`. The latter is built on top of the former.

To see the working directory and the contents of the `redcapcustodian` directory run

```bash
docker run --rm rcc_example
```

To run the shared `hello.R` report within the shared container, run 

```bash
# run the script inside the container
docker run --env-file .env --rm redcapcustodian Rscript redcapcustodian/report/hello.R
```

To run the localized `hello-local.R` report from the _example_ host within the container, run 

```bash
# run the script inside the container
docker run --env-file .env --rm rcc_example Rscript redcapcustodian/report/hello-local.R
```
