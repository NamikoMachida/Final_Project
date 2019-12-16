# __Specimen Search within Natural History Museums__   
________________________________________________________________   

#### [one paragraph of project description]
#### - the .Rmd will allow us to download museum specimen information from multiple museum collection database (using idigbio database).
#### - Each mus. has its own collection databases
#### - The new program will download specimen information of any taxonomic rank and group, and visually let you know   


### __Getting started__   
________________________________________________________________   
#### __Prerequisites__   
#### This project requires the following three r packages.   
```
ridigbio
knitr
kableExtra
```   
#### __Installing__
#### Please install and library them before using this program.
```
install.packages("ridigbio")
install.packages("knitr")
install.packages("kableExtra")
library(ridigbio)
library(knitr)
library(kableExtra)
```   
#### Languages
#### R
   
   
   
### __collection_search (function)__  
________________________________________________________________   
#### The above function is stored in .R file in this .Rproject directory. Please sorce from the file to use it.
```
source("./function_final_project.R")
```   
#### To see examples of usages and results, please go to .Rmd that demonstrates the function.
#### LINK TO THE .Rmd
#### LINK TO THE html

#### __Function Usage__   
```
collection_search(Rank, Taxon, Path = NULL, Search_Missing_Taxa = FALSE)
```   
Arguments   
Rank: taxonomic rank, all lowercases.   
Taxon: taxonomic name(s). Can accept multiple values as a vector (e.g. c("Acernaspis, Ananaspis"))   
Path: A path to your own taxon list file. Taxon list must comprise two columns, genus and species, with "," as delimiter and without header. The file format can be either .CSV or .txt.
Taxon file may look like
```
Acernaspis,aspera
Ananaspis,aspera
Barrandeops,ovatus
Boeckops,boecki
Kainops,raymondi
```   
Search_Missing_Taxa: A logical argument whether you want to search for specimens of taxa that are missing from your taxon list, or those in your list. If it is TRUE, the function will search for the specimens of missing taxa. Default is FALSE. 



### __Function Breakdown__   
# collection_search: function
# Downloads biologic museum specimen information from idigbio database and displays the result as a table.
# A comparison with user's species list can also be conducted.
collection_search <- function (Rank, Taxon, Path = NULL, Search_Missing_Taxa = FALSE) {
  # Produce error messages if inappropriate values are entered as arguments.
  if (!is.character(Rank)){
    stop("Rank must be a character string (e.g. Rank = \"genus\").")
  }
  if (!is.character(Taxon)){
    stop("Taxon must be a character string (e.g. Taxon = \"Acernaspis\").")
  }
  if (any(strsplit(Rank, "")[[1]] == toupper(strsplit(Rank, "")[[1]]))){
    stop("Rank must be in lower case characters.")
  }
  if (!is.logical(Search_Missing_Taxa)){
    stop("Search_Missing_Taxa must be either TRUE/FALSE. Default is FALSE.")
  }
  
  # Get data from idigbio database.
  idiglist <- list(Taxon)
  names(idiglist) <- c(Rank)
  data <- idig_search_records(rq=idiglist, fields = "all")
  
  # Extract neccessary columns.
  col_needed <- c("institutioncode", "catalognumber", "order", "family", "genus", "specificepithet", "earliestperiodorlowestsystem", "latestperiodorhighestsystem", "country", "stateprovince", "county", "formation")
  data_selected <- data[, col_needed]
  # Conduct hierarchical sorting by institutional code, genus, and species.
  data_selected_sorted <- data_selected[order(data_selected$institutioncode, data_selected$genus, data_selected$specificepithet),]
  # Remove rows whose institutional code is NA.
  data_selected_sorted <- data_selected_sorted[!is.na(data_selected_sorted$institutioncode), ]
  
  # Capitalise first letter of specific columns (i.e. Order, Family, Genus, Country, County, Fm.).
  col_to_cap <- c("order","family","genus","country","stateprovince","county","formation")
  data_selected_sorted[,col_to_cap] <- apply(data_selected_sorted[,col_to_cap], c(1,2), cap_head)
  # Capitalize names of geologic ages.
  col_to_cap_age <- c("earliestperiodorlowestsystem", "latestperiodorhighestsystem")
  data_selected_sorted[,col_to_cap_age] <- apply(data_selected_sorted[,col_to_cap_age], c(1,2), cap_head_age)
  
  
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
