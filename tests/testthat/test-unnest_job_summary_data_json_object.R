testthat::test_that("unnest_job_summary_data_json_object works", {
  test_data_dir <- "unnest_job_summary_data_json_object"
  log_data <- readRDS(testthat::test_path(test_data_dir, "log_data.rds"))

  ncols_in_unnested_data <- 5

  output <- unnest_job_summary_data_json_object(log_data, objects_to_include = "iris")

  testthat::expect_equal(
    output %>%
      dplyr::distinct(id) %>%
      nrow(),
    1
    )

  testthat::expect_equal(
    output %>%
      dplyr::select(-dplyr::any_of(names(log_data))) %>%
      pull(iris) %>%
      ncol(),
    ncols_in_unnested_data
  )
})
