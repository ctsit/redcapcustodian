FROM rocker/tidyverse:4.2.1

WORKDIR /home/rocker

RUN apt update -y && apt install -y libmariadb-dev libmariadbclient-dev

# install necessary libraries
RUN R -e "install.packages(c( \
  'DBI', \
  'RCurl', \
  'REDCapR', \
  'RMariaDB', \
  'checkmate', \
  'dbx', \
  'digest', \
  'dotenv', \
  'here', \
  'janitor', \
  'mRpostman', \
  'rjson', \
  'sendmailR', \
  'sqldf', \
  'writexl' \
))"

RUN R -e "devtools::install_github('allanvc/mRpostman')"

RUN apt install -y --no-install-recommends libxt6

# build and install this package
ADD . /home/rocker/redcapcustodian
RUN R CMD build redcapcustodian
RUN R CMD INSTALL redcapcustodian_*.tar.gz
RUN rm -rf redcapcustodian

# Add non-package things
ADD . /home/rocker
RUN rm -rf .Rbuildignore
RUN rm -rf NAMESPACE
RUN rm -rf R
RUN rm -rf .dockerignore
RUN rm -rf DESCRIPTION
RUN rm -rf hosts
RUN rm -rf host_template
RUN rm -rf make_host.sh
RUN rm -rf .Rhistory
RUN rm -rf Dockerfile

# Note where we are, what is there, and what's in the package dir
CMD pwd && ls -AlhF ./
