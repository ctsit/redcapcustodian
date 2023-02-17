testthat::test_that("export_allocation_tables_from_project works", {
  # Create test tables
  conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
  purrr::walk(randomization_test_tables, create_a_table_from_test_data, conn, "randomization")
  fix_randomization_tables(conn)

  project_id_to_export <- 18

  testthat::expect_equal(
    export_allocation_tables_from_project(conn, project_id_to_export),
    readr::read_csv(
      testthat::test_path("randomization", "export_allocation_tables_from_project.csv")) %>%
      dplyr::mutate(randomization = as.character(randomization)
    )
  )
})

testthat::test_that("create_randomization_row works", {
  # Create test tables
  conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
  purrr::walk(randomization_test_tables, create_a_table_from_test_data, conn, "randomization")
  fix_randomization_tables(conn)

  source_project_id <- 18
  target_project_id <- 27

  testthat::expect_equal(
    create_randomization_row(
      source_conn = conn,
      target_conn = conn,
      source_project_id = source_project_id,
      target_project_id = target_project_id
    ),
    readr::read_csv(
      testthat::test_path("randomization", "create_randomization_row.csv")) %>%
      dplyr::mutate(group_by = as.integer(group_by))
  )
})

testthat::test_that("create_allocation_rows works", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
  purrr::walk(randomization_test_tables, create_a_table_from_test_data, conn, "randomization")
  fix_randomization_tables(conn)

  source_project_id <- 18
  target_project_id <- 27

  create_randomization_row(
    source_conn = conn,
    target_conn = conn,
    source_project_id = source_project_id,
    target_project_id = target_project_id
  )

  testthat::expect_equal(
    create_allocation_rows(
      source_conn = conn,
      target_conn = conn,
      source_project_id = source_project_id,
      target_project_id = target_project_id
    ),
    readr::read_csv(
      testthat::test_path("randomization", "create_allocation_rows.csv")) %>%
      dplyr::mutate(group_id = as.integer(group_id)) %>%
      dplyr::mutate(target_field = as.character(target_field))
  )
})

testthat::test_that("update_production_allocation_state works", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
  purrr::walk(randomization_test_tables, create_a_table_from_test_data, conn, "randomization")
  fix_randomization_tables(conn)

  source_project_id <- 18
  target_project_id <- 27

  target_project_randomization_state <- create_randomization_row(
    source_conn = conn,
    target_conn = conn,
    source_project_id = source_project_id,
    target_project_id = target_project_id
  )

  target_project_allocation_state <- create_allocation_rows(
    source_conn = conn,
    target_conn = conn,
    source_project_id = source_project_id,
    target_project_id = target_project_id
  )

  # now set some aids in the source so we can watch them sync
  aids_to_set <- c(seq(91, 95))
  DBI::dbExecute(conn, "update redcap_randomization_allocation set is_used_by = aid where aid in (91,92,93,94,95)")
  target_project_allocation_update <- update_production_allocation_state(
    source_conn = conn,
    target_conn = conn,
    source_project_id = source_project_id,
    target_rid = target_project_randomization_state$rid
  )
  testthat::expect_equal(
    target_project_allocation_update$update_records %>%
      arrange(is_used_by) %>%
      dplyr::pull(is_used_by),
    aids_to_set
  )
})
