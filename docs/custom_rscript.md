# Writing your own redcapcustodian Rscripts

In its most basic use, redcapcustodian need only be load is a library in an Rscript. To automate a report or ETL already in redcapcustodian, you need only buid the image, write a configuration file and instantiate the container form that image with that config file. Yet it allows for extensive customization that builds upon the framework it provides.

## Writing your own Rscripts

You can write your own Rscript to accomplish a task against one or more REDCap hosts or projects.  That script should load the _redcapcustodian_ package. To make your own script, first copy the contents of [`site_template`](../site_template/) to the `site` folder.

To guide you in your first script, copy any of the Rscripts from the `etl/` or `reports/` folder to use as a starting point. Copy it into the corresponding folder in the `./site` folder. Perhaps you don't like the rules used in the default `cleanup_bad_email_addresses.R` script and want to tweak them to match your site's rules for account management.

```sh
cp -r site_template/* site/
cd ./site/
mkdir etl
cp ../etl/cleanup_bad_email_addresses.R etl/cleanup_bad_email_addresses.R
```

Because of the layered nature of Docker images, any same-named script in the `./site/etl/` or `./site/report/` folder will supercede the file from the `redcapcustodian` image.

To run your custom `etl/cleanup_bad_email_addresses.R` script regularly on a host you call 'prod', create a cron entry for it:

```sh
cat <<END>> prod/cron/cleanup_bad_email_addresses
# Clean up bad email addresses daily at 6:07 a.m.
7 6 * * * root /usr/bin/docker run --rm --env-file /rcc/prod.env rcc.site Rscript redcapcustodian/etl/cleanup_bad_email_addresses.R
END
```

## Using version control

Once you go down this road of writing your own scripts, you should be very concerned about preserving them. One of the best ways to do this is via git version control. Initialize a new software repository at root of the `./site` folder. This will allow you to manage the code for custom RScripts and all of you site's hosts in one repository.


## Adding a custom package

If you want to do complex things in your redcapcustodian Rscripts or share custom code between them, you might want to add your own R package just for redcapcustodian work. redcapcustodian supports the development of such a package within the `./site/` folder. Follow the RStudio team's [packaging guidelines](https://r-pkgs.org/) to create a package in `./site/`.

To build the latest version of the package as you build a task container, uncomment these lines in the task's `Dockerfile` and customize them with your package name:

```
# Add, build, and install my group's package
ADD .. /home/rocker/rcc.mygroup
RUN R CMD build rcc.mygroup
RUN R CMD INSTALL rcc.mygroup*.tar.gz
```

Take some care in writing your `.Rbuildignore` file. You'll want to exclude `etl/*` and `report/*`.


## Rscripts for arbitrary tasks

The `./site` concept is a convenience managed but _redcapcustodian's_ [build.sh](../build.sh). Yet if you like _redcapcustodian_, you will likely outgrow it. At CTS-IT at UF we create a new git repository for each task. That task could be a collection of reports that run against one REDCap project, a collection of ETLs that run between two REDCap projects in a study, or billing process that runs against one REDCap host's MySQL Database. 

Each such repository gets its on RStudio project, its own R package, Dockerfile, some ETLs or reports, example env files, cron files, and Docker image build script. Use the [`site_template`](../site_template/) folder as a template for any such task-specific work. Steal other components from REDCap custodian as needed.
