FROM redcapcustodian

WORKDIR /home/rocker

## install additional system libraries not included in redcapcustodian if necessary
# e.g. to add sftp support
# RUN apt update -y && apt install -y openssh-client

## install additional R libraries not included in redcapcustodian if necessary
## e.g. install a package:
# RUN R -e "install.packages(c('redcapAPI'))"

## e.g. private packages
## see: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
# ARG GITHUB_PAT=your_personal_access_token
## Stop using cache to ensure latest private package is always installed
## https://stackoverflow.com/a/49772666/7418735
# ARG TIMESTAMP=1611761435
# RUN R -e "devtools::install_github('ctsit/rcc.billing', auth_token = '$GITHUB_PAT')"

## e.g. pin to a specific version of an R package
# RUN R -e "devtools::install_github('OuhscBbmc/REDCapR', ref='c5bce6a')"

# Add, build, and install this study's package
# ADD .. /home/rocker/my.study
# RUN R CMD build my.study
# RUN R CMD INSTALL my.study*.tar.gz
# RUN rm -rf my.study

# Add non-package things
ADD . /home/rocker
RUN rm -rf .Rbuildignore
RUN rm -rf NAMESPACE
RUN rm -rf R
RUN rm -rf .dockerignore
RUN rm -rf DESCRIPTION
RUN rm -rf .Rhistory
RUN rm -rf Dockerfile

# Note where we are, what is there, and what's in the package dir
CMD pwd && ls -AlhF ./
