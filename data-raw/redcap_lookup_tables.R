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

project_purpose_other_research_labels <- dplyr::tribble(
  ~id, ~project_purpose_other_research,
  0, "Basic or bench research",
  1, "Clinical research study or trial",
  2, "Translational research 1 (applying discoveries to the development of trials and studies in humans)",
  3, "Translational research 2 (enhancing adoption of research findings and best practices into the community)",
  4, "Behavioral or psychosocial research study",
  5, "Epidemiology",
  6, "Repository (developing a data or specimen repository for future use by investigators)",
  7, "Other"
)
usethis::use_data(project_purpose_other_research_labels, overwrite = T)

project_status_labels <- dplyr::tribble(
  ~id, ~project_status,
  0, "Development",
  1, "Production",
  2, "Inactive",
  3, "Archived"
)
# write the data
usethis::use_data(project_status_labels, overwrite = T)
