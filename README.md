# __Search for Natural History Specimens in idigbio Database__   
##### one paragraph of project description
##### the .Rmd will allow us to download museum specimen information from multiple museum collection database using [idigbio database](https://www.idigbio.org/).
##### Each mus. has its own collection databases
##### The new program will download specimen information of any taxonomic rank and group, and visually let you know   


### __Getting Started__   
________________________________________________________________   
#### __Prerequisites__   
##### This project requires the following three R packages.   
```
ridigbio
knitr
kableExtra
```   


#### __Installing__
##### Please install and library the three packages before using the function below.
```
install.packages("ridigbio")
install.packages("knitr")
install.packages("kableExtra")
library(ridigbio)
library(knitr)
library(kableExtra)
```   


### __Language__   
________________________________________________________________   
##### All procedures from downloading the data to visualizing as a table are done in R.   


### __collection_search: Function Description__  
________________________________________________________________   
##### A new function `collection_search` is created and stored in .R file in the .Rproject directory. Please sorce the function from the file in order to use wit.
```
source("./function_final_project.R")
```   
##### To see examples of usages and their results, please go to .Rmd or html in which the function does demonstrations.
##### - [draft_commands.Rmd](https://github.com/NamikoMachida/Final_Project/blob/Namiko/draft_commands.Rmd) 
##### - [html]() 

#### __Function Usage__   
```
collection_search(rank, Taxon, Path = NULL, Search_Missing_Taxa = FALSE)
```   
##### Arguments   
##### - `rank`: A character string of any taxonomic rank (e.g., "class", "order", "family"). The imput is case sensitive and all must be in lowercases.   
##### - `Taxon`: Any taxonomic name(s) that correspond to the `rank` argument. This can accept multiple taxonomic names as a simple character vector (e.g., c("Acernaspis, Ananaspis", "Barrandeops")). The imput is case insensitive.   
##### - `Path`: A path to a file that contains genus and species names of your interest. The taxon list must comprise two columns, genus and species, delimited by "," and without a header. The file may look like
```
Acernaspis,aspera
Ananaspis,aspera
Barrandeops,ovatus
Boeckops,boecki
Kainops,raymondi
```   
##### - Search_Missing_Taxa: A logical argument about whether you want to find specimens of specific species in your taxon list (FALSE) or you want to find any specimens of species that are missing from your list (TRUE). Default is FALSE.   


### __collection_search: Function Breakdown__   
________________________________________________________________   
##### Here are detailed descriptions of codes in the `collection_search` function. This function is mainly composed of six sections, namely, _1. Production of error messages_, _2. Downloading data from idigbio_, _3. Data subsetting and sorting_, _4. Text value capitalization_, _5. Species comparison_, and _6. Table production_. Full function codes are found in `./function_final_project.R`.   

##### __1. Production of error messages__   
##### This section produces error messages if inappropriate values are entered in the arguments. Since the `rank` and `Taxon` arguments must be in character values and the `Search_Missing_Taxa` must be in logical expression, combinations of "logical NOT operator" `!` and `is.character()` or `is.logical()` functions are used in if statements.   
```   
if (!is.character(rank)){
  stop("rank must be a character string (e.g. rank = \"genus\").")
}
if (!is.character(Taxon)){
  stop("Taxon must be a character string (e.g. Taxon = \"Acernaspis\").")
}
if (!is.logical(Search_Missing_Taxa)){
  stop("Search_Missing_Taxa must be either TRUE/FALSE. Default is FALSE.")
}
```   
##### Since the `rank` argument is case sensitive and must be in lowercases, an additional error message will be provided if any uppercase letters are included in the argument. `strsplit(rank, "")[[1]]` will split the character string by letters and return as a character vector. `toupper()` function will converts any letters into uppercase letters. Thus, `any(strsplit(rank, "")[[1]] == toupper(strsplit(rank, "")[[1]]))` can test whether `rank` argument contains uppercase letters or not.   
```  
if (any(strsplit(rank, "")[[1]] == toupper(strsplit(rank, "")[[1]]))){
  stop("rank must be in lower case characters.")
}
```  

##### __2. Downloading data from idigbio__   
##### Main function that downloads museum specimen information from idigbio database is `idig_search_records(rq, fields)`. `rq` is a record query argument in nested list format that takes taxonomic names as list elements and taxonomic rank as the name of the list. In here, the character vector `Taxon` is made into a list called `idiglist` and named as `rank` input. `fields` is set as "all" to download all the available data from the database.
```
idiglist <- list(Taxon)
names(idiglist) <- c(rank)
data <- idig_search_records(rq=idiglist, fields = "all")
```   

#### __3. Data subsetting and sorting__   
##### First, 12 columns that covers information of institutions, specimen IDs, taxonomic classifications, geologic ages, and specimen localities are extracted from the raw data downloaded in the previous section. The newly subsetted data is named as `data_selected`. Column names of the `data_selected` are converted into more user friendly names.
```
col_needed <- c("institutioncode", "catalognumber", "order", "family", "genus", "specificepithet", "earliestperiodorlowestsystem", "latestperiodorhighestsystem", "country", "stateprovince", "county", "formation")
data_selected <- data[, col_needed]
colnames(data_selected) <- c("InstCode", "Col.ID", "Order", "Family", "Genus", "species", "earliest", "latest", "Country", "State", "County", "Fm.")
```   
##### Then, a hierarchical sorting is conducted. `order()` function in row argument rearranges the rows of `data_selected` based on the values in "institutioncode", "genus", and "specificepithet" columns with a hierarchical prioritization. The subsetted data is now named as `data_selected_sorted`. In this way, the specimen data is systematically grouped by institutions, genus, and species names.  
```
data_selected_sorted <- data_selected[order(data_selected$InstCode, data_selected$Genus, data_selected$species),]
```   
##### Finally, all rows with NA values in institutional code are removed.
```
data_selected_sorted <- data_selected_sorted[!is.na(data_selected_sorted$InstCode), ]
```   

#### __4. Text value capitalization__
##### Since all the downloaded data comes in lowercases, case convertion is conducted for certain columns by using two newly created functions, `cap_head` and `cap_head_age` (these are stored in the bottom of .R file). 
##### `cap_head` function works to capitalize the first letters of all words in a character string. In here, `text <- strsplit(string, "")[[1]]` splits `string` object by words and convert them into a character vector called `text`. Then, `substring(text, 1,1)` takes all the first letters from `text` vector, which will be converted into uppercase letters by `toupper()` function. Finally, `paste(text, collapse = " ")` outputs the case converted elements of `text` vector in space separated format. 
```
# cap_head function

cap_head <- function(string) {
  text <- strsplit(string, " ")[[1]]
  substring(text, 1,1) <- toupper(substring(text, 1,1))
  paste(text, collapse = " ")
}
```  
##### `cap_head_age` function has similar structure with `cap_head` function but works specifically for names of geologic periods without capitalizing prefixes of "early", "middle", and "late". All names of geological period are stored in a character vector `periods`. `substring(text[text %in% periods], 1,1)` takes only the first letter of geological period from `text` vector, which will be uppercased by `toupper` function.  
```
# cap_head_age function

cap_head_age <- function(string) {
  text <- strsplit(string, " ")[[1]]
  periods <- c("siderian", "rhyacian", "orosirian", "statherian", "calymmian", "ectasian", "stenian", "tonian", "cryogenian", "ediacaran", "cambrian", "ordovician", "silurian", "devonian", "carboniferous", "permian", "triassic", "jurassic", "cretaceous", "paleogene", "neogene", "tertiary", "quaternary")
  substring(text[text %in% periods], 1,1) <- toupper(substring(text[text %in% periods], 1,1))
  paste(text, collapse = " ")
}
```  
##### In section 4 of the `collection_search` function, `head_cap` is applied to columns regarding biologic classifications down to genus level and columns of locality information. `head_cap_age` is applied to columns of the earliest and latest geologic period.
```
# Section 4 of collection_search function.

col_to_cap <- c("Order", "Family", "Genus", "Country", "State", "County", "Fm.")
data_selected_sorted[,col_to_cap] <- apply(data_selected_sorted[,col_to_cap], c(1,2), cap_head)

col_to_cap_age <- c("earliest", "latest")
data_selected_sorted[,col_to_cap_age] <- apply(data_selected_sorted[,col_to_cap_age], c(1,2), cap_head_age)
```   

#### __5. Species comparison__
##### If the user enters a file path into the `Path` argument, which means `!is.null(Path)` is TURE, a species comparison between the downloaded data and user's own species list will be conducted. The user's species list is read and set as a data.frame called `MyTaxa` with column names of "Genus" and "species". Then, row numbers of certain genus and species combinations in `data_selected_sorted`, that match those of `MyTaxa`, are identified and stored in a vector called `position`. If the user defines `Search_Missing_Taxa` argument as "TRUE", the row numbers in the `position` vector will be reversed so that the `position` vector has row numbers of genus and species combinations that are missing from `MyTaxa` list.
##### With a nested structure of the above two if statements, the user can look up specific taxa in his/her species list or serach for any specimens that are missing from his/her list.
```
position <- c()
if (!is.null(Path)){
  MyTaxa <- read.delim(file = Path, header = FALSE, sep = ",", col.names = c("Genus", "species"))
  position <- which(data_selected_sorted[, "Genus"] %in% MyTaxa[, "Genus"] & data_selected_sorted[, "species"] %in% MyTaxa[, "species"])
  if (Search_Missing_Taxa == TRUE){
    all_rows <- 1:nrow(data_selected_sorted)
    position <- all_rows[!all_rows %in% position]
  }
}
```   

#### __6. Table production__  
##### As a final step of the function, `data_selected_sorted` is expressed in a table format by using either one of newly created table producing functions, `table_SpComparison` or `simple_table` (these are stored in the bottom of .R file). The choice of table producing function is dependent on `length(position) >= 1` is TRUE or not, meaning whether one or more rows need to be highlighted or not.
```
# Section 6 of collection_search funciton.

if (length(position) >= 1){
  table_SpComparison(data = data_selected_sorted, Position = position)
  }else{
  simple_table(data = data_selected_sorted)
  }
```   
##### `simple_table` function uses functions of `kniter` and `kableExtra` packages. In arguments of `kable()` function, a data.frame is taken as an imput data, table format is set as "html" (`format = "html"`), values are aligned on the left (`align = "l"`), the column of row names is hidden (`row.names = FALSE`), and whole text color in the table is set as black (`table.attr = "style = \"color: black;\""`). In the `kable_styling()` argument, the rows are color alternated and slightly shortened in length (`bootstrap_options = ("striped", "condensed")`), laterally made into compact (`full_width = F`), outout position of the whole table as left side (`position = "left"`), font size of the text as 12 point (`font_size = 12`), and the headder row are freazed at the top of the table when scrolled (`fixed_thead = T`). Categories of columns are displayed over the column names by using `add_header_above = c()`. To clearly show the institutional groupings of the specimen information, cells with repeated values in "InstCode" column is merged and the content is aligned at the top of the cell (`collapse_rows(columns = 1, valign = "top")`).   
```
# simple_table function

simple_table <- function(data){
  kable(data, format = "html", align = "l", row.names = FALSE, table.attr = "style = \"color: black;\"") %>%
    kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 12, fixed_thead = T)%>%
    add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
    collapse_rows(columns = 1, valign = "top")
}
``` 
##### `table_SpComparison` function has the exactly same lines as those of `simple_table` function except having a line of `row_spec(Position, color = "red")`. With this additional formatting, in which the `Position` is a numeric vector of row numbers, specified rows can be highlited in red in the output table.
```
# table_SpComparison function

table_SpComparison <- function(data, Position){
  kable(data, format = "html", align = "l", row.names = FALSE, table.attr = "style = \"color: black;\"") %>%
    kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 12, fixed_thead = T)%>%
    add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
    row_spec(Position, color = "red")%>%
    collapse_rows(columns = 1, valign = "top")
}
```  


### __Deployment__   
________________________________________________________________________________   
### __Built with?__
### __Versioning__   
