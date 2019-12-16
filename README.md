# __Specimen Search within Natural History Museums__   
##### one paragraph of project description
##### the .Rmd will allow us to download museum specimen information from multiple museum collection database (using idigbio database).
##### Each mus. has its own collection databases
##### The new program will download specimen information of any taxonomic rank and group, and visually let you know   


### __Getting started__   
________________________________________________________________   
#### __Prerequisites__   
##### This project requires the following three r packages.   
```
ridigbio
knitr
kableExtra
```   
#### __Installing__
##### Please install and library them before using this program.
```
install.packages("ridigbio")
install.packages("knitr")
install.packages("kableExtra")
library(ridigbio)
library(knitr)
library(kableExtra)
```   
##### Languages
##### R
   
   
   
### __collection_search (function)__  
________________________________________________________________   
##### The above function is stored in .R file in this .Rproject directory. Please sorce from the file to use it.
```
source("./function_final_project.R")
```   
##### To see examples of usages and results, please go to .Rmd that demonstrates the function.
##### LINK TO THE .Rmd
##### LINK TO THE html

#### __Function Usage__   
```
collection_search(Rank, Taxon, Path = NULL, Search_Missing_Taxa = FALSE)
```   
##### Arguments   
##### Rank: taxonomic rank, all lowercases.   
##### Taxon: taxonomic name(s). Can accept multiple values as a vector (e.g. c("Acernaspis, Ananaspis"))   
##### Path: A path to your own taxon list file. Taxon list must comprise two columns, genus and species, with "," as delimiter and without header. The file format can be either .CSV or .txt.
##### Taxon file may look like
```
Acernaspis,aspera
Ananaspis,aspera
Barrandeops,ovatus
Boeckops,boecki
Kainops,raymondi
```   
##### Search_Missing_Taxa: A logical argument whether you want to search for specimens of taxa that are missing from your taxon list, or those in your list. If it is TRUE, the function will search for the specimens of missing taxa. Default is FALSE. 



#### __Function Breakdown__   
##### Here are detailed descriptions of codes in the `collection_search` function. This function is mainly composed of six sections, namely, _1. Production of error messages_, _2. Downloading data from idigbio_, _3. Data subsetting and sorting_, _4. Text value capitalization_, _5. Species comparison_, and _6. Table production_. Full function codes are found in `./function_final_project.R`.   

##### __1. Production of error messages__   
##### This section produces error messages if inappropriate values are entered in the arguments. Since the `Rank` and `Taxon` arguments must be in character values and the `Search_Missing_Taxa` must be in logical expression, combinations of "logical NOT operator" `!` and `is.character()` or `is.logical()` functions are used in if statements.   
```   
if (!is.character(Rank)){
  stop("Rank must be a character string (e.g. Rank = \"genus\").")
}
if (!is.character(Taxon)){
  stop("Taxon must be a character string (e.g. Taxon = \"Acernaspis\").")
}
if (!is.logical(Search_Missing_Taxa)){
  stop("Search_Missing_Taxa must be either TRUE/FALSE. Default is FALSE.")
}
```   
##### Since the `Rank` argument is case sensitive and must be in lowercases, an additional error message will be provided if any uppercase letters are included in the argument. `strsplit(Rank, "")[[1]]` will split the character string by letters and return as a character vector. `toupper()` function will converts any letters into uppercase letters. Thus, `any(strsplit(Rank, "")[[1]] == toupper(strsplit(Rank, "")[[1]]))` can test whether `Rank` argument contains uppercase letters or not.   
```  
if (any(strsplit(Rank, "")[[1]] == toupper(strsplit(Rank, "")[[1]]))){
  stop("Rank must be in lower case characters.")
}
```  

##### __2. Downloading data from idigbio__   
##### Main function that downloads museum specimen information from idigbio database is `idig_search_records(rq, fields)`. `rq` is a record query argument in nested list format that takes taxonomic names as list elements and taxonomic rank as the name of the list. In here, the character vector `Taxon` is made into a list called `idiglist` and named as `Rank` input. `fields` is set as "all" to download all the available data from the database.
```
idiglist <- list(Taxon)
names(idiglist) <- c(Rank)
data <- idig_search_records(rq=idiglist, fields = "all")
```   

#### __3. Data subsetting and sorting__   
##### First, neccessary 12 columns that covers information of institutions, specimen IDs, taxonomic classifications, geologic ages, and specimen localities are extracted from the downloaded raw data in the previous section. The newly subsetted data is named as `data_selected`.
```
col_needed <- c("institutioncode", "catalognumber", "order", "family", "genus", "specificepithet", "earliestperiodorlowestsystem", "latestperiodorhighestsystem", "country", "stateprovince", "county", "formation")
data_selected <- data[, col_needed]
```   
##### Then, a hierarchical sorting is conducted based on the values of institutional code, genus, and species. `order()` function in the row argument rearranges the rows with a hierarchy of institutioncode > genus > specificepithet columns.  
```
data_selected_sorted <- data_selected[order(data_selected$institutioncode, data_selected$genus, data_selected$specificepithet),]
```   


```
# Remove rows whose institutional code is NA.
data_selected_sorted <- data_selected_sorted[!is.na(data_selected_sorted$institutioncode), ]
```   

#### __4. Text value capitalization__
  # Capitalise first letter of specific columns (i.e. Order, Family, Genus, Country, County, Fm.).
  col_to_cap <- c("order","family","genus","country","stateprovince","county","formation")
  data_selected_sorted[,col_to_cap] <- apply(data_selected_sorted[,col_to_cap], c(1,2), cap_head)
  # Capitalize names of geologic ages.
  col_to_cap_age <- c("earliestperiodorlowestsystem", "latestperiodorhighestsystem")
  data_selected_sorted[,col_to_cap_age] <- apply(data_selected_sorted[,col_to_cap_age], c(1,2), cap_head_age)

#### __5. Species comparison__
  # Conduct species comparison if required by the user.
  position <- c()
  if (!is.null(Path)){
    # Read my taxon list file using function argument PATH.
    MyTaxa <- read.delim(file = Path, header = FALSE, sep = ",", col.names = c("Genus", "species"))
    # Get row numbers of taxa from data_selected_sorted that can be found within MyTaxa.
    position <- which(data_selected_sorted[, "genus"] %in% MyTaxa[, "Genus"] & data_selected_sorted[, "specificepithet"] %in% MyTaxa[, "species"])
    # If Search_Missing_Taxa argument is TRUE, reverse the previous search and produce row numbers of taxa that are missing from MyTaxa.
    if (Search_Missing_Taxa == TRUE){
      all_rows <- 1:nrow(data_selected_sorted)
      position <- all_rows[!all_rows %in% position]
    }
  }

#### __6. Table production__  
  # Make a table. If the species comparison was conducted above, use table_SpComparison function to highlight rows specifed by `position` vector. 
  if (length(position) >= 1){
    table_SpComparison(data = data_selected_sorted, Position = position)
  }else{
    simple_table(data = data_selected_sorted)
  }
}




#capitalize function
cap_head <- function(string) {
  text <- strsplit(string, " ")[[1]]
  substring(text, 1,1) <- toupper(substring(text, 1,1))
  paste(text, sep = "", collapse = " ")
}

# capitalize function for age columns. Only geologic periods will be capitalised and prefixes of "early", "middle", "late" will remain in lower case.
cap_head_age <- function(string) {
  text <- strsplit(string, " ")[[1]]
  periods <- c("siderian", "rhyacian", "orosirian", "statherian", "calymmian", "ectasian", "stenian", "tonian", "cryogenian", "ediacaran", "cambrian", "ordovician", "silurian", "devonian", "carboniferous", "permian", "triassic", "jurassic", "cretaceous", "paleogene", "neogene", "tertiary", "quaternary")
  substring(text[text %in% periods], 1,1) <- toupper(substring(text[text %in% periods], 1,1))
  paste(text, sep = "", collapse = " ")
}


simple_table <- function(data){
  kable(data, format = "html", col.names = c("InstCode", "Col.ID", "Order", "Family", "Genus", "species", "earliest", "latest", "Country", "State", "County", "Fm."), align = "l", row.names = FALSE, table.attr = "style = \"color: black;\"") %>%
    kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 12, fixed_thead = T)%>%
    # Header arrangement
    add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
    # Group rows with institutional categories.
    collapse_rows(columns = 1, valign = "top")%>%
    scroll_box(width = "100%", height = "500px")
}


table_SpComparison <- function(data, Position){
  kable(data, format = "html", col.names = c("InstCode", "Col.ID", "Order", "Family", "Genus", "species", "earliest", "latest", "Country", "State", "County", "Fm."), align = "l", row.names = FALSE, table.attr = "style = \"color: black;\"") %>%
    kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 12, fixed_thead = T)%>%
    # Header arrangement
    add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
    # Highlight the rows specified by position.
    row_spec(Position, color = "red")%>%
    # Group rows with institutional categories.
    collapse_rows(columns = 1, valign = "top")%>%
    scroll_box(width = "100%", height = "500px")
}



















### __Deployment__   
________________________________________________________________________________   
### __Built with?__
### __Versioning__   
