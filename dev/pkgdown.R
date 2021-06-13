# Run once to configure your package to use pkgdown
usethis::use_pkgdown()

pkgdown::build_favicons(pkg = ".", overwrite = FALSE)
pkgdown::build_site()
