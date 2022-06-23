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

