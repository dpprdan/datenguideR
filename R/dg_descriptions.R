##' dg_descriptions.R
##'
##' Gets all available meta data on statistics, sub-statistics, and parameters.
##'
##' @return Data frame containing all available meta data
##'
##' @examples
##' dg_descriptions <- get_descriptions()
##' dg_descriptions
##'
##' @export

get_descriptions <- function() {
  meta_query <-
    '{ __type(name: "Region") {
     fields {
     name
     description
     args {
       name
       type {
         name
         ofType {
           name
           description
           enumValues {
             name
             description
           }
         }
       }
     }
   }
 }}'

  meta_results <- httr::POST(
    url = "https://api-next.datengui.de/graphql",
    body = list(query = meta_query),
    encode = "json",
    httr::add_headers(.headers = c("Content-Type" = "application/json"))
  )

  result_dat <- httr::content(meta_results, as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()

  final <- result_dat[["data"]][["__type"]][["fields"]] %>% tibble::as_tibble()

  return(final)
}


# dg_descriptions <- get_descriptions() %>%
#   dplyr::select(name, description, args) %>%
#   dplyr::mutate(stat_description_full = description %>%
#     stringr::str_trim()) %>%
#   dplyr::mutate(description = stringr::str_extract(description, '(?<=\\*\\*)[^*]*(?=\\*\\*)')) %>%
#   utils::tail(-2) %>%
#   dplyr::rename_all(dplyr::recode, name = "stat_name", description = "stat_description") %>%
#   tidyr::unnest(args) %>%
#   dplyr::filter(name != "year", name != "filter") %>%
#   dplyr::mutate(substat_description = type$ofType$description) %>%
#   dplyr::rename(substat_name = "name") %>%
#   dplyr::mutate(substat_name = stringr::str_replace(substat_name, "statistics", "")) %>%
#   dplyr::mutate_at(
#     .vars = c("substat_name", "substat_description"),
#     .funs = list(~ ifelse(. == "", NA, as.character(.)))
#   ) %>%
#   dplyr::mutate(parameter = type$ofType$enumValues) %>%
#   dplyr::select(stat_name, stat_description, stat_description_full, substat_name, substat_description, parameter) %>%
#   tidyr::unnest(parameter) %>%
#   dplyr::rename(param_name = "name", param_description = "description") %>%
#   dplyr::mutate_at(
#     .vars = c("param_name", "param_description"),
#     .funs = list(~ ifelse(substat_name == "", NA, as.character(.)))
#   )

# usethis::use_data(dg_descriptions, overwrite = TRUE)



##' dg_search
##'
##' Search for a string in dg_descriptions
##' @param string String that you want to search for (accepts regex)
##' @return Data frame containing meta data only containing the search string
##'
##' @examples
##' dg_descriptions <- dg_search("vote")
##' dg_descriptions
##'
##' @export
dg_search <- function(string) {
  string <- stringr::str_to_lower(string)

  final <- dg_descriptions %>%
    dplyr::filter_all(
      .vars_predicate = dplyr::any_vars(
        stringr::str_detect(
          stringr::str_to_lower(.), string
        )
      )
    )

  return(final)
}
