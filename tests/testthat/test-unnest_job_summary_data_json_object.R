testthat::test_that("unnest_job_summary_data_json_object works", {
  test_data_dir <- "unnest_job_summary_data_json_object"
  log_data <- readRDS(testthat::test_path(test_data_dir, "log_data.rds"))

  sample_size <- 3
  ncols_in_unnested_data <- 3

  output <- unnest_job_summary_data_json_object(log_data)

  testthat::expect_equal(
    output %>%
      dplyr::distinct(id) %>%
      nrow(),
    sample_size
    )

  testthat::expect_equal(
    output %>%
      dplyr::select(-dplyr::any_of(names(log_data))) %>%
      ncol(),
    ncols_in_unnested_data
  )
})
