FROM rocker/verse:4.2.1

WORKDIR /home/rocker

RUN apt update -y && apt install -y libmariadb-dev libmariadbclient-dev
RUN apt install -y --no-install-recommends libxt6

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
  'rjson', \
  'sendmailR', \
  'sqldf', \
  'writexl', \
  'kableExtra' \
))"

RUN R -e "devtools::install_github('allanvc/mRpostman')"
RUN R -e "tinytex::tlmgr_install(c(\
  'amscls', 'amsfonts', 'amsmath', 'babel', 'bibtex', 'booktabs', \
  'caption', 'cm', 'colortbl', 'dehyph', 'dvipdfmx', 'dvips', \
  'ec', 'environ', 'epstopdf-pkg', 'etex', 'etoolbox', 'euenc', \
  'fancyvrb', 'float', 'fontspec', 'framed', 'geometry', 'glyphlist', \
  'graphics', 'graphics-cfg', 'graphics-def', 'gsftopk', 'helvetic', \
  'hyperref', 'hyphen-base', 'ifluatex', 'iftex', 'ifxetex', 'inconsolata', \
  'knuth-lib', 'kpathsea', 'l3kernel', 'l3packages', 'latex', 'latex-bin', \
  'latex-fonts', 'latexconfig', 'latexmk', 'lm', 'lualibs', 'luaotfload', \
  'luatex', 'makecell', 'makeindex', 'mathspec', 'metafont', 'mfware', \
  'multirow', 'natbib', 'oberdiek', 'pdflscape', 'pdftex', 'plain', \
  'scheme-infraonly', 'tabu', 'tetex', 'tex', 'tex-ini-files', 'texlive.infra', \
  'threeparttable', 'threeparttablex', 'times', 'tipa', 'titling', \
  'tools', 'trimspaces', 'ulem', 'unicode-data', 'upquote', 'url', \
  'varwidth', 'wrapfig', 'xcolor', 'xetex', 'xetexconfig', 'xkeyval', \
  'xunicode', 'zapfding' \
))"

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
