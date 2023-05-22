# Title     : large_data_files.R
# Objective : Split files with a size exceeding the max. size of Github
# Created by: jhnnsjkbk
# Created on: 02.08.21
library(dplyr)
#setwd(paste0(getwd(), "/code"))

# Combine multiple small data files to original data file

get_small_files <- function () {
  small_files <- list.files("../data/small_size")
}

rda2list <- function(file) {
  e <- new.env()
  load(file, envir = e)
  as.list(e)
}

load_data <- function (name) {
  file_names <- get_small_files()
  files <- file_names[as.vector(unlist(purrr::map(file_names, ~startsWith(.,name))))]
  file_paths <- paste0("../data/small_size/", files)
  print(paste("Load the following files", file_paths))
  data <- Map(rda2list, file.path(file_paths))
  data <- data %>% purrr::flatten() %>% do.call("rbind", .)
}

load_parleys_est <- function () {
  parleys_est <- load_data("parleys_est")
}

load_parler_data_10_days <- function () {
  parleys_est <- load_data("parler_data_10_days")
}

load_parler_data_est <- function () {
  parler_data_est <- load_data("parler_data_est")
}

load_parler_data <- function () {
  parler_data <- load_data("parler_data")
}

load_robustness_check_emotions <- function () {
  nrc_emotions <- load_data("robustness_check_emotions")
}

load_sentences_per_body <- function () {
  sentences_per_body <- load_data("sentences_per_body")
}


