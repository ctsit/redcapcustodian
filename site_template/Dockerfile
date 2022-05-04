FROM redcapcustodian

WORKDIR /home/rocker

ADD . /home/rocker/redcapcustodian

# Add my group's ETL and report scripts
ADD ../etl /home/rocker/redcapcustodian/etl
ADD ../report /home/rocker/redcapcustodian/report

# Add, build, and install my group's package
# ADD .. /home/rocker/rcc.mygroup
# RUN R CMD build rcc.mygroup
# RUN R CMD INSTALL rcc.mygroup*.tar.gz

# Add, build, and install this host's package
# ADD . /home/rocker/my.host.package
# RUN R CMD build my.host.package
# RUN R CMD INSTALL my.host.package_*.tar.gz

# Note where we are, what is there, and what's in the package dir
CMD pwd && ls -AlhF ./ && echo /home/rocker/redcapcustodian && ls -AlhF ./redcapcustodian
