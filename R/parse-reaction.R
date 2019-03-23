#' @title Parser for the description strings of certain reaction-related fields.
#'
#' @description This parser works for the fields `substrate.product` and
#' `natural.substrate.product`.
#'
#' @param description A description string from one of the entries.
#' @param acronym The acronym of the field. Can be found with `ShowFields()`.
#'
#' @details The reversibility of the reactions are wrapped in {}; substrates
#' and products are separated by "="; commentaries on substrates are wrapped in
#' "()", and commentaries on products are wrapped in "||".
#'
#' @return A `tibble` with columns: proteinID, substrate, product,
#' commentarySubstrate, commentaryProduct, fieldInfo and refID
#'
#' @import stringr
#' @importFrom tibble tibble
#' @importFrom dplyr distinct
#' @importFrom purrr map_chr
ParseReaction <- function(description, acronym) {
  if (missing(description)) {
    stop("Parameter description missing. Should be a string.")
  }
  if (length(description) == 0) {
    return(NA)
  }
  des.list <- SeparateSubentries(description, acronym = acronym)
  protein.id <- str_extract(des.list, "^#[0-9, ]+#")
  protein.id <- lapply(protein.id, function(x)
    ParseProteinNum(x, type = "protein"))

  ref.id <- str_extract(des.list, "<[0-9, ]+>$")
  ref.id <- lapply(ref.id, function(x)
    ParseProteinNum(x, type = "reference"))

  reversibility <- des.list %>%
    str_extract("(\\{i?r\\})|(\\{\\??\\})") %>%  # {r}, {ir}, {?}, {}
    str_sub(2, -2)

  description <- des.list %>%
    str_remove("^#[0-9, ]+#") %>%
    str_remove("<[0-9, ]+>$") %>%
    str_remove("(\\{i?r\\})|(\\{\\??\\})")

  commentary.substrate <- description %>%
    str_extract("\\(#.*>\\)") %>%
    str_sub(2, -2)
  commentary.product <- description %>%
    str_extract("\\|#.*>\\|") %>%
    str_sub(2, -2)

  description <- description %>%
    str_remove("\\(#.*>\\)") %>%
    str_remove("\\|#.*>\\|") %>%
    str_trim() %>%
    str_split(" = ")  # separate substrate and product

  res <- tibble(
    proteinID = protein.id,
    substrate = map_chr(description, function(x) x[1]),
    product = map_chr(description, function(x) x[2]),
    commentarySubstrate = commentary.substrate,
    commentaryProduct = commentary.product,
    reversibility = reversibility,
    refID = ref.id
  ) %>%
    distinct(substrate, product, commentarySubstrate,
             commentaryProduct, reversibility, .keep_all = T)
  return(res)
}