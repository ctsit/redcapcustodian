packages_to_install <- read.csv("https://raw.githubusercontent.com/ljwoodley/redcapcustodian/add_latex_packages/latex_packages.csv")
tinytex::tlmgr_install(packages_to_install$package)
