
# test_dataset_diff_components is a function to test the 3 components of the
# dataset_diff result separately
test_dataset_diff_components <- function(df, df_name) {
  testthat::test_that(paste("dataset_diff updates match for", df_name), {
    testthat::expect_true(dplyr::all_equal(
      dataset_diff(
        source = df$source,
        source_pk = df$source_pk,
        target = df$target,
        target_pk = df$target_pk
      )$update_records,
      df$result$update_records
    ))
  })

  testthat::test_that(paste("dataset_diff updates match for", df_name), {
    testthat::expect_true(dplyr::all_equal(
      dataset_diff(
        source = df$source,
        source_pk = df$source_pk,
        target = df$target,
        target_pk = df$target_pk
      )$insert_records,
      df$result$insert_records
    ))
  })

  testthat::test_that(paste("dataset_diff updates match for", df_name), {
    testthat::expect_true(dplyr::all_equal(
      dataset_diff(
        source = df$source,
        source_pk = df$source_pk,
        target = df$target,
        target_pk = df$target_pk
      )$delete_records,
      df$result$delete_records
    ))
  })
}

test_dataset_diff_components(dataset_diff_test_bar_bang, "bar_bang")
test_dataset_diff_components(dataset_diff_test_user_data, "user_data")
