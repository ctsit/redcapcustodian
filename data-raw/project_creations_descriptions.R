project_creation_descriptions <- c(
  "Copy project",
  "Copy project as",
  "Copy project from",
  "Create project",
  "Create project using REDCap XML file",
  "Create project using template",
  # Not returned by get_project_creations() since API-driven creation does
  # not hit ProjectGeneral/create_project.php, but listed here for completeness
  "Create project (API)"
) %>%
  unique()

# write the data
usethis::use_data(project_creation_descriptions, overwrite = T)
