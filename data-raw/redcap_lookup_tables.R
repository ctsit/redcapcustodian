project_purpose_labels <- dplyr::tribble(
  ~id, ~project_purpose,
  4, "Operational Support",
  2, "Research",
  3, "Quality Improvement",
  1, "Other",
  0, "Practice / Just for fun"
)
# write the data
usethis::use_data(project_purpose_labels, overwrite = T)

project_status_labels <- dplyr::tribble(
  ~id, ~project_status,
  0, "Development",
  1, "Production",
  2, "Inactive",
  3, "Archived"
)
# write the data
usethis::use_data(project_status_labels, overwrite = T)
