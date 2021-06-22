FROM rocker/tidyverse:4.1.0

WORKDIR /home/rocker

RUN apt update -y && apt install -y libmariadb-dev libmariadbclient-dev

# install necessary libraries
RUN R -e "install.packages(c('sendmailR', 'dotenv', 'RCurl', 'checkmate', 'janitor', 'sqldf', 'DBI', 'RMariaDB', 'digest','rjson'))"

ADD . /home/rocker/redcapcustodian

# build and install this package
RUN R CMD build redcapcustodian
RUN R CMD INSTALL redcapcustodian_*.tar.gz

# Note where we are, what is there, and what's in the package dir
CMD pwd && ls -AlhF ./ && echo /home/rocker/redcapcustodian && ls -AlhF ./redcapcustodian
