# Developer Notes for REDCap Custodian

If you'd like to develop for _redcapcustodian_, these notes might be helpful.

## Release and Deployment

This project uses the Git Flow workflow for releases. Every release should be versioned and have a ChangeLog entry that describes the new features and bug fixes. Every release should also be accompanied by an updated `VERSION` and a manual revision to the version number in [`DESCRIPTION`](../DESCRIPTION). The latter tells devtools about version number changes. The former allows image builds to be tagged as they are built by the [`build.sh`](../build.sh)

To deploy a new release on the Linux host, execute this series of commands or an equivalent from your home directory on that host:

```bash
git clone git@github.com:ctsit/redcapcustodian.git
cd redcapcustodian
git pull
sudo ./build.sh
```

