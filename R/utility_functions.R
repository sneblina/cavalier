# Return directory name that ends in "/" (for pasting strings)
endslash_dirname <- function(dirname)
{
    if (!endsWith(dirname, "/")) {
        dirname <- paste0(dirname, "/")
    }
    return(dirname)
}

# Insert a newline every N characters (e.g., for long genome changes)
newline_every_n_chars <- function(x, n)
{
    if (nchar(x) > n) {
        x0 <- substr(x, 1, n)
        x1 <- substr(x, n+1, nchar(x))
        return(paste0(x0, "\n", newline_every_n_chars(x1, n)))
    } else {
        return(x)
    }
}

#' @importFrom stringr str_sub
#' @importFrom purrr pmap_chr
#' @importFrom digest digest
digest_df <- function(x, nchar = 12) 
{
    x %>% 
        pmap_chr(function(...) {
            dots <- dots_list(...)
            unlist(dots[sort(names(dots))]) %>% 
                digest::digest() 
        }) %>% 
        sort() %>% 
        digest::digest() %>% 
        str_sub(1, nchar)
}

#' @importFrom rlang is_double is_integer
is_number <- function(x) { (is_double(x) | is_integer(x)) & !any(is.na(x)) }


# Convert to numeric replacing NA with zero
as_numeric_na_zero <- function(x) {
    y <- as.numeric(x)
    y[is.na(y)] <- 0
    return(y)
}

# read png with png::readPNG to get dimensions
# create external_image with officer
#' @importFrom officer external_img
read_png <- function(filename, dpi = 300) {
    png_dim <- dim(readPNG(filename))[1:2] / dpi
    external_img(filename, width = png_dim[2], height = png_dim[1])
}

remove_child_dirs <- function(dirs) {
    map(dirs, ~ which(str_detect(dirs, str_c('^', .)) &
                          ! str_detect(dirs, str_c('^', ., '$')))) %>%
        unlist() %>% 
        { dirs[-.] }
}

# predicates for checking arguments

is_null_or_file <- function(x) { is.null(x) | (is_scalar_character(x) && file.exists(x)) }

is_null_or_files <- function(x, named = FALSE) { 
    is.null(x) | (is_character(x) && all(file.exists(x))) && (!named | is_named(x))
}

assert_create_dir <- function(dirname, recursive = TRUE) {
    if (!dir.exists(dirname)) {
        assert_that(dir.create(dirname, recursive = recursive))
    }
}

pad_df <- function(df, n) {
    full_join(
        mutate(df, .id = row_number()),
        tibble(.id = seq_len(n)),
        by = '.id') %>% 
        select(-.id)
}

#' @importFrom purrr map_df
#' @importFrom progress progress_bar
map_df_prog <- function(.x, .f, ...) {
    pb <- progress_bar$new(total = length(.x))
    f2 <- function(...) { pb$tick(); .f(...) }
    map_df(.x, f2, ...)
}

