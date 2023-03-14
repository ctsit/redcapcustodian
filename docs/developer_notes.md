# Developer Notes for REDCap Custodian

If you'd like to develop for _redcapcustodian_, these notes might be helpful.

## Testing Vignettes

The _Install and Restart_ and _Check_ buttons in RStudio do not build and install the vignettes even if your configure them explicitly to do that. `R CMD INSTALL --preclean --no-multiarch --with-keep.source .` doesn't do it either. This impedes local testing when writing vignettes. You can build and install your new and revised vignettes by running `devtools::install_local(devtools::build(vignettes = T))` at the console. This will allow you to view your work with `browseVignettes(package="redcapcustodian")`

## Release and Deployment

This project uses the Git Flow workflow for releases. Every release should be versioned and have a ChangeLog entry that describes the new features and bug fixes. Every release should also be accompanied by an updated `VERSION` and a manual revision to the version number in [`DESCRIPTION`](../DESCRIPTION). The latter tells devtools about version number changes. The former allows image builds to be tagged as they are built by the [`build.sh`](../build.sh)

To deploy a new release on the Linux host, execute this series of commands or an equivalent from your home directory on that host:

```bash
git clone git@github.com:ctsit/redcapcustodian.git
cd redcapcustodian
git pull
sudo ./build.sh
```

## Local logging for development work

When doing development work, it's useful to have a local log database. This allows you to initialize logging as you test your scripts without throwing an error and even test the write to the log on success or failure. REDCap Custodian provides an example logging system in the form of a `docker-compose.yml` and a database schema at `./rcc.log.db/`. You can start the logging database with these commands:

```sh
cd ./rcc.log.db/
docker-compose up -d
```

By default, a PHPMyAdmin interface is accessible at http://localhost:9080/. That and other configuration parameters are defined in `./rcc.log.db/.env`. These same parameters are used in 
`./study_template/example.env`. Using those example values in your local environment files will allow all your scripts across all you redcap custodian projects will allow them to share this logging database.
