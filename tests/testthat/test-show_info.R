context("Show information about BRENDA")

brenda_txt <- system.file("extdata", "brenda_download_test.txt",
                          package = "brendaDb")
df <- ReadBrenda(brenda_txt)

test_that("Show BRENDA fields and acronyms", {
  expect_error(ShowFields())
  df_fields <- ShowFields(df)

  expect_match(unique(df_fields$field), "^[A-Z_05]+$")
  expect_match(unique(df_fields$acronym), "^[A-Z05]+$")
})

test_that("Printing brenda.query objects", {
  x <- QueryBrenda(df, EC = c("1.1.1.1", "6.3.5.8"),
                   n.core = 1, organisms = "Homo sapiens")
  expect_output(print(x), regexp = "list of 2.+1 regular.+1 transferred")
  expect_output(print(x, verbose = TRUE),
                regexp = "list of 2.+1 regular.+1 transferred.+\\|")

  # There should be NA and "0 rows" in the output; both are colored red
  x$`1.1.1.1`$nomenclature$reaction <- NA

  expect_output(print(x$`1.1.1.1`, full.output = TRUE),
                #regexp = "\x1b\\[31mNA\x1b\\[[0-9;]+m")
                regexp = "reaction: NA")
  expect_output(print(x$`1.1.1.1`, full.output = TRUE),
                #regexp = "\x1b\\[31m0\x1b\\[[0-9;]+m rows")
                regexp = "0 rows")

  # Deprecated entries have different outputs
  expect_output(print(x$`6.3.5.8`), regexp = "^Entry.+msg:.+transferred")
})
