<!-- README.md is generated from README.Rmd. Please edit that file -->
tidyjson
========

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/tidyjson)](https://cran.r-project.org/package=tidyjson) [![Build Status](https://travis-ci.org/jeremystan/tidyjson.svg?branch=master)](https://travis-ci.org/jeremystan/tidyjson) [![Coverage Status](https://img.shields.io/codecov/c/github/jeremystan/tidyjson/master.svg)](https://codecov.io/github/jeremystan/tidyjson?branch=master)

![tidyjson graphs](https://cloud.githubusercontent.com/assets/2284427/18217882/1b3b2db4-7114-11e6-8ba3-07938f1db9af.png)

tidyjson provides tools for turning complex [json](http://www.json.org/) into [tidy](https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html) data.

Installation
------------

Get the released version from CRAN:

``` r
install.packages("tidyjson")
```

or the development version from github:

``` r
devtools::install_github("jeremystan/tidyjson")
```

Examples
--------

The following example takes a character vector of 500 documents in the `worldbank` dataset and spreads out all objects into new columns

``` r
library(tidyjson)
suppressMessages(library(dplyr))

worldbank %>% spread_all
#> # A tbl_json: 500 x 8 tibble with a "JSON" attribute
#>     `attr(., "JSON")` document.id    boardapprovaldate
#>                 <chr>       <int>                <chr>
#> 1  {"_id":{"$oid":...           1 2013-11-12T00:00:00Z
#> 2  {"_id":{"$oid":...           2 2013-11-04T00:00:00Z
#> 3  {"_id":{"$oid":...           3 2013-11-01T00:00:00Z
#> 4  {"_id":{"$oid":...           4 2013-10-31T00:00:00Z
#> 5  {"_id":{"$oid":...           5 2013-10-31T00:00:00Z
#> 6  {"_id":{"$oid":...           6 2013-10-31T00:00:00Z
#> 7  {"_id":{"$oid":...           7 2013-10-29T00:00:00Z
#> 8  {"_id":{"$oid":...           8 2013-10-29T00:00:00Z
#> 9  {"_id":{"$oid":...           9 2013-10-29T00:00:00Z
#> 10 {"_id":{"$oid":...          10 2013-10-29T00:00:00Z
#> # ... with 490 more rows, and 6 more variables: closingdate <chr>,
#> #   countryshortname <chr>, project_name <chr>, regionname <chr>,
#> #   totalamt <dbl>, `_id.$oid` <chr>
```

However, some objects in `worldbank` are arrays, this example shows how to quickly summarize the top level structure of a JSON collection

``` r
worldbank %>% gather_object %>% json_types %>% count(name, type)
#> Source: local data frame [8 x 3]
#> Groups: name [?]
#> 
#>                  name   type     n
#>                 <chr> <fctr> <int>
#> 1                 _id object   500
#> 2   boardapprovaldate string   500
#> 3         closingdate string   370
#> 4    countryshortname string   500
#> 5 majorsector_percent  array   500
#> 6        project_name string   500
#> 7          regionname string   500
#> 8            totalamt number   500
```

In order to capture the data in `majorsector_percent` we can use `enter_object` to enter into that object, `gather_array` to stack the array and `spread_all` to capture the object names under the array.

``` r
worldbank %>%
  enter_object(majorsector_percent) %>%
  gather_array %>%
  spread_all %>%
  select(-document.id, -array.index)
#> # A tbl_json: 1,405 x 2 tibble with a "JSON" attribute
#>     `attr(., "JSON")`                                    Name Percent
#>                 <chr>                                   <chr>   <dbl>
#> 1  {"Name":"Educat...                               Education      46
#> 2  {"Name":"Educat...                               Education      26
#> 3  {"Name":"Public... Public Administration, Law, and Justice      16
#> 4  {"Name":"Educat...                               Education      12
#> 5  {"Name":"Public... Public Administration, Law, and Justice      70
#> 6  {"Name":"Public... Public Administration, Law, and Justice      30
#> 7  {"Name":"Transp...                          Transportation     100
#> 8  {"Name":"Health...        Health and other social services     100
#> 9  {"Name":"Indust...                      Industry and trade      50
#> 10 {"Name":"Indust...                      Industry and trade      40
#> # ... with 1,395 more rows
```

API
---

### Spreading objects into columns

-   `spread_all()` for spreading all object values into new columns, with nested objects having concatenated names

-   `spread_values()` for specifying a subset of object values to spread into new columns using the `jstring()`, `jnumber()` and `jlogical()` functions

### Object navigation

-   `enter_object()` for entering into an object by name, discarding all other JSON (and rows without the corresponding object name) and allowing further operations on the object value

-   `gather_object()` for stacking all object name-value pairs by name, expanding the rows of the `tbl_json` object accordingly

### Array navigation

-   `gather_array()` for stacking all array values by index, expanding the rows of the `tbl_json` object accordingly

### JSON inspection

-   `json_types()` for identifying JSON data types

-   `json_length()` for computing the length of JSON data (can be larger than `1` for objects and arrays)

-   `json_complexity()` for computing the length of the unnested JSON, i.e., how many terminal leaves there are in a complex JSON structure

-   `is_json` family of functions for testing the type of JSON data

### JSON summarization

-   `json_structure()` for creating a single fixed column data.frame that recursively structures arbitrary JSON data

-   `json_schema()` for representing the schema of complex JSON, unioned across disparate JSON documents, and collapsing arrays to their most complex type representation

### Creating tbl\_json objects

-   `as.tbl_json()` for converting a string or character vector into a `tbl_json` object, or for converting a `data.frame` with a JSON column using the `json.column` argument

-   `tbl_json()` for combining a `data.frame` and associated `list` derived from JSON data into a `tbl_json` object

-   `read_json()` for reading JSON data from a file

### Converting tbl\_json objects

-   `as.character.tbl_json` for converting the JSON attribute of a `tbl_json` object back into a JSON character string

### Included JSON data

-   `commits`: commit data for the dplyr repo from github API

-   `issues`: issue data for the dplyr repo from github API

-   `worldbank`: world bank funded projects from [jsonstudio](http://jsonstudio.com/resources/)

-   `companies`: startup company data from [jsonstudio](http://jsonstudio.com/resources/)

Philosophy
----------

The goal is to turn complex JSON data, which is often represented as nested lists, into tidy data frames that can be more easily manipulated.

-   Work on a single JSON document, or on a collection of related documents

-   Create pipelines with `%>%`, producing code that can be read from left to right

-   Guarantee the structure of the data produced, even if the input JSON structure changes (with the exception of `spread_all`)

-   Work with arbitrarily nested arrays or objects

-   Handle 'ragged' arrays and / or objects (varying lengths by document)

-   Allow for extraction of data in values or object names

-   Ensure edge cases are handled correctly (especially empty data)

-   Integrate seamlessly with `dplyr`, allowing `tbl_json` objects to pipe in and out of `dplyr` verbs where reasonable

Related Work
------------

Tidyjson depends upon

-   [magrritr](https://github.com/smbache/magrittr) for the `%>%` pipe operator
-   [jsonlite](https://github.com/jeroenooms/jsonlite) for converting JSON strings into nested lists
-   [purrr](https://github.com/hadley/purrr) for list operators
-   [tidyr](https://github.com/hadley/tidyr) for unnesting and spreading

Further, there are other R packages that can be used to better understand JSON data

-   [listviewer](https://github.com/timelyportfolio/listviewer) for viewing JSON data interactively
