FROM --platform=linux/amd64 rocker/verse:4.4.1

WORKDIR /home/rocker

RUN apt update -y && apt install -y libmariadb-dev libmariadb-dev-compat
RUN apt install -y --no-install-recommends libxt6

# returns an error but tlmgr is updated to 2024 regardless
RUN wget ${CTAN_REPO}/update-tlmgr-latest.sh && bash update-tlmgr-latest.sh; exit 0

# install necessary libraries
RUN R -e "install.packages(c( \
  'DBI', \
  'RCurl', \
  'REDCapR', \
  'RMariaDB', \
  'argparse', \
  'checkmate', \
  'dbx', \
  'digest', \
  'dotenv', \
  'here', \
  'janitor', \
  'quarto', \
  'rjson', \
  'sendmailR', \
  'sqldf', \
  'writexl', \
  'openxlsx', \
  'kableExtra', \
  'getip' \
))"

RUN R -e "devtools::install_github('allanvc/mRpostman')"
RUN R -e "tinytex::tlmgr_install(c(\
  'amscls', 'amsmath', \
  'bookmark', \
  'booktabs', \
  'caption','colortbl', 'dvips', \
  'ec', 'environ', 'epstopdf-pkg', \
  'etoolbox', 'euenc', \
  'fancyvrb', 'float', 'fontspec', \
  'framed', 'geometry', \
  'gsftopk', 'helvetic', \
  'hyperref', 'iftex', \
  'koma-script', \
  'latexmk', \
  'makecell', 'mathspec', \
  'mdwtools', 'multirow', \
  'natbib', 'oberdiek', \
  'pdfcol', \
  'pdflscape', \
  'pgf', \
  'tabu', \
  'tcolorbox', \
  'threeparttable', 'threeparttablex', \
  'times', 'tipa', 'titling', \
  'trimspaces', 'ulem', \
  'unicode-math', \
  'upquote', \
  'varwidth', 'wrapfig', 'xcolor', \
  'xunicode', 'zapfding' \
))"

# build and install this package
ADD . /home/rocker/redcapcustodian
RUN R CMD build --no-build-vignettes redcapcustodian
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
