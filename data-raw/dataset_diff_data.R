## code to prepare dataset for testing dataset_diff goes here
library(dplyr)

target <- dplyr::tribble(
  ~id, ~pk, ~bar, ~bang,
  1,1,1,1,
  2,2,2,1,
  3,3,3,1,
  4,4,4,1,
  6,6,6,1
)

source <- dplyr::tribble(
  ~pk, ~bar,
  1,1,
  2,2,
  3,1,
  4,1,
  5,5
)

result <-
  list(
    update_records = tribble(
      ~id, ~pk, ~bar,
      3, 3, 1,
      4, 4, 1
    ),
    insert_records = tribble(
      ~pk,   ~bar,
      5,     5
    ),
    delete_records = tribble(
      ~id, ~pk, ~bar, ~bang,
      6, 6, 6, 1
    )
  )

# result <- dataset_diff(source = source,
#              source_pk = "pk",
#              target = target,
#              target_pk = "id"
# )

dataset_diff_test_bar_bang <- list(
  source = source,
  source_pk = "pk",
  target = target,
  target_pk = "id",
  result = result
)

usethis::use_data(dataset_diff_test_bar_bang, overwrite = TRUE)

# user_data is a test that should return two  records for email address update
target <- dplyr::tribble(
  ~ui_id, ~username, ~user_email,
  1,"alice","alice@example.org",
  2,"bob","robert@example.org",
  3,"carol","carol@example.org",
  4,"dan","daniel@example.org"
)

source <- dplyr::tribble(
  ~username, ~user_email,
  "alice","alice@example.org",
  "bob","bob@example.org",
  "carol","carol@example.org",
  "dan","dan@example.org"
)

# result <-
#   dataset_diff(source = source,
#                        source_pk = "username",
#                        target = target,
#                        target_pk = "ui_id"
# )

result <-
  list(
    update_records = tribble(
      ~ui_id, ~username, ~user_email,
      2,"bob","bob@example.org",
      4,"dan","dan@example.org"
    ),
    insert_records = tribble(
      ~username, ~user_email
    ) %>%
      mutate(
        dplyr::across(c("username", "user_email"), as.character)
      ),
    delete_records = tribble(
      ~ui_id, ~username, ~user_email
    ) %>%
      mutate(
        dplyr::across(c("ui_id"), as.numeric),
        dplyr::across(c("username", "user_email"), as.character)
      )
  )

dataset_diff_test_user_data <- list(
  source = source,
  source_pk = "username",
  target = target,
  target_pk = "ui_id",
  result = result
)

usethis::use_data(dataset_diff_test_user_data, overwrite = TRUE)

# create sync_table test data for user data
sync_table_test_user_data_result <- target %>%
  left_join(source, by = c("username")) %>%
  mutate(user_email = coalesce(user_email.y, user_email.x)) %>%
  select(-ends_with(c(".x", ".y")))

usethis::use_data(sync_table_test_user_data_result, overwrite = TRUE)
