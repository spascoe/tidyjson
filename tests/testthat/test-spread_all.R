context("spread_all")

test_that("works for simple example", {

  expect_identical(
    '{"a": 1, "b": "x", "c": true}' %>% spread_all,
    tbl_json(
      data_frame(
        document.id = 1L,
        a = 1,
        b = "x",
        c = TRUE
      ),
      list(list(a = 1L, b = "x", c = TRUE))
    )
  )

})

test_that("spreads a null column", {

  expect_identical(
    '{"a": null}' %>% spread_all,
    tbl_json(
      data_frame(
        document.id = 1L,
        a = NA
      ),
      list(list(a = NULL))
    )
  )

})

test_that("handles a more complex document", {

  json <- c(
    '{"a": "x",  "b": 1,    "c": true, "d": null}',
    '{"a": null, "b": null, "c": null, "d": null}',
    '{"e": null}'
  )

  expect_identical(
    json %>% spread_all,
    tbl_json(
      data_frame(
        document.id = 1L:3L,
        a = c("x", NA_character_, NA_character_),
        b = c(1, NA_integer_, NA_integer_),
        c = c(TRUE, NA, NA),
        d = rep(NA, 3),
        e = rep(NA, 3)
      ),
      json %>% map(fromJSON, simplifyVector = FALSE)
    )
  )

})

test_that("correctly handles character(0), {}", {

  expect_identical(
    character(0) %>% spread_all,
    character(0) %>% as.tbl_json
  )

  expect_identical(
    '{}' %>% spread_all,
    '{}' %>% as.tbl_json
  )

})

test_that("correct behavior with array input", {

  expect_identical(
    suppressWarnings('[1, 2]' %>% spread_all),
    '[1, 2]' %>% as.tbl_json
  )

  expect_warning('[1, 2]' %>% spread_all,
                 "no JSON records are objects, returning .x")

})

test_that("correct behavior with scalar input", {

  expect_identical(
    suppressWarnings('1' %>% spread_all),
    '1' %>% as.tbl_json
  )

  expect_warning('1' %>% spread_all,
                 "no JSON records are objects, returning .x")

})

test_that("recursive names work", {

  json <- '{"k1": 1, "k2": {"k3": 2, "k4": {"k5": 3}}, "k6": 4}'

  expect_identical(
    json %>% spread_all,
    tbl_json(
      data_frame(
        document.id = 1L,
        k1 = 1,
        k6 = 4,
        k2.k3 = 2,
        k2.k4.k5 = 3
      ),
      json %>% map(fromJSON, simplifyVector = FALSE)
    )
  )

})

test_that("works with real examples", {

  expect_identical(
    worldbank %>% spread_all %>% names,
    c("document.id", "boardapprovaldate", "closingdate", "countryshortname",
      "project_name", "regionname", "totalamt", "_id.$oid")
  )

  expect_identical(
    companies[1:10] %>% spread_all %>% names,
    c("document.id", "name", "permalink", "crunchbase_url", "homepage_url",
      "blog_url", "blog_feed_url", "twitter_username", "category_code",
      "number_of_employees", "founded_year", "founded_month", "founded_day",
      "deadpooled_year", "deadpooled_month", "deadpooled_day", "deadpooled_url",
      "tag_list", "alias_list", "email_address", "phone_number", "description",
      "created_at", "updated_at", "overview", "total_money_raised",
      "acquisition", "ipo", "image", "_id.$oid", "image.attribution",
      "acquisition.price_amount", "acquisition.price_currency_code",
      "acquisition.term_code", "acquisition.source_url",
      "acquisition.source_description", "acquisition.acquired_year",
      "acquisition.acquired_month", "acquisition.acquired_day",
      "acquisition.acquiring_company.name",
      "acquisition.acquiring_company.permalink")
  )

})

test_that("works with multiple duplicated columns", {

  json <- '{"key": "a", "key": "b", "key": "c"}'

  expect_identical(
    suppressWarnings(json %>% spread_all),
    tbl_json(
      data_frame(document.id = 1L, key = "a", key.2 = "b", key.3 = "c"),
      list(fromJSON(json, simplifyVector = FALSE))
    )
  )
  expect_warning(json %>% spread_all)

})

test_that("works when column names are duplicated from data frame", {

  df <- data_frame(key = 1L, json = '{"key": "a", "key": "b"}') %>%
    as.tbl_json(json.column = "json")

  expect_identical(
    suppressWarnings(df %>% spread_all),
    tbl_json(
      data_frame(key = 1L, key.2 = "a", key.3 = "b"),
      attr(df, "JSON")
    )
  )
  expect_warning(df %>% spread_all)

})
