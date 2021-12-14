# Writing your own redcapcustodian Rscripts

In its most basic use, redcapcustodian requires the user to define a host, and run one of its predefined Rscripts with a cron file. Yet it allows for extensive customization that builds upon the framework it provides.

## Writing your own Rscripts

You can write your own Rscript to run against one of your hosts.  That script can and generally should load the redcapcustodian library to benefit from the utility of the functions within the library. To make your own script, copy any of the Rscripts from the `etl/` or `reports/` folder to use as a starting point. Copy it into the corresponding folder in the `./site` folder. Perhaps you don't like the rules used in the default `cleanup_bad_email_addresses.R` script and want to tweak them to match your site's rules for account management.

```sh
cd ./site/
mkdir etl
cp ../etl/cleanup_bad_email_addresses.R etl/cleanup_bad_email_addresses.R
```

Because of the layered nature of Docker containers, any same-named script in the `./site/etl/` or `./site/report/` folder will supercede the file from redcapcustodian.

To run your custom `etl/cleanup_bad_email_addresses.R` script regularly on a host you call 'prod', create a cron entry for it:

```sh
cat <<END>> prod/cron/cleanup_bad_email_addresses
# Clean up bad email addresses daily at 6:07 a.m.
7 6 * * * root /usr/bin/docker run --rm --env-file /rcc/prod.env redcapcustodian Rscript redcapcustodian/etl/cleanup_bad_email_addresses.R
END
```

## Using version control

Once you go down this road of writing your own scripts, you should be very concerned about preserving them. One of the best ways to do this is via git version control. Initialize a new software repository at root of the `./site` folder. This will allow you to manage the code for custom RScripts and all of you site's hosts in one repository.


## Adding a site package

If you want to do complex things in your redcapcustodian Rscripts or share custom code between them you might want to add your own R package just for redcapcustodian work. redcapcustodian supports the development of such a package within the `./site/` folder. Follow the RStudio team's [packaging guidelines](https://r-pkgs.org/) to create a package in `./site/`.

To build the lastest version of the package as you build a host container, uncomment these lines in the host's `Dockerfile` and customize them with your package name:

```
# Add, build, and install my group's package
ADD .. /home/rocker/rcc.mygroup
RUN R CMD build rcc.mygroup
RUN R CMD INSTALL rcc.mygroup*.tar.gz
```

Take some care in writing your `.Rbuildignore` file. You'll want to exclude the `etl/*`, `report/*`, and every host folder.


## Rscripts for a single host

If you have a host that has its own specialized needs for RScript code, you can add an `./etl/` and/or a `./report/` folder within the host's folder and reference the new script in a `./cron/` file like any other script. All the same rules apply as with the `./site/` folder.


## Adding a host package

A host with complex script needs can use a host-specific R package to manage functions needed throughout its ETLs. This behaves much like a site package. To build this package within container builds, uncomment these lines in the host's `Dockerfile` and customize them with the host's package name:

```sh
# Add, build, and install this host's package
ADD . /home/rocker/my.host.package
RUN R CMD build my.host.package
RUN R CMD INSTALL my.host.package_*.tar.gz
```
