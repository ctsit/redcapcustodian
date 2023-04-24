project_life_cycle_descriptions <- c(
  "Approve production project modifications (automatic)",
  "Approve production project modifications",
  "Archive project",
  "Copy project",
  "Create project (API)",
  "Create project folder",
  "Create project using REDCap XML file",
  "Create project using template",
  "Create project",
  "Delete project bookmark",
  "Delete project",
  "Move project back to development status",
  "Move project to production status",
  "Permanently delete project",
  "Reject production project modifications",
  "Request approval for production project modifications",
  "Reset production project modifications",
  "Restore/undelete project",
  "Return project to production from inactive status",
  "Send request to copy project",
  "Send request to create project",
  "Send request to delete project",
  "Send request to move project to production status",
  "Set project as inactive"
)

# write the data
usethis::use_data(project_life_cycle_descriptions, overwrite = T)
