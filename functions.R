# Function: collection_search
# Downloads specimen information of natural history museums/institutions from idigbio database and visualize the data as a formatted table.
# A species-level comparison with a user-specified taxonomic list can also be conducted.

collection_search <- function (rank, Taxon, Path = NULL, Search_Missing_Taxa = FALSE) {
  # 1. Production of error messages: Output error messages if inappropriate values are entered in the arguments.
  if (!is.character(rank)){
    stop("rank must be a character string (e.g. rank = \"genus\").")
  }
  if (!is.character(Taxon)){
    stop("Taxon must be a character string (e.g. Taxon = \"Acernaspis\").")
  }
  if (any(strsplit(rank, "")[[1]] == toupper(strsplit(rank, "")[[1]]))){
    stop("rank must be in lower case characters.")
  }
  if (!is.logical(Search_Missing_Taxa)){
    stop("Search_Missing_Taxa must be either TRUE/FALSE. Default is FALSE.")
  }
  
  # 2. Downloading data from idigbio  
  idiglist <- list(Taxon)
  names(idiglist) <- c(rank)
  data <- idig_search_records(rq=idiglist, fields = "all")
  
  # 3. Data subsetting and sorting
  # Extract necessary columns.
  col_needed <- c("institutioncode", "catalognumber", "order", "family", "genus", "specificepithet", "earliestperiodorlowestsystem", "latestperiodorhighestsystem", "country", "stateprovince", "county", "formation")
  data_selected <- data[, col_needed]
  # Name the columns with user-friendly names.
  colnames(data_selected) <- c("InstCode", "Col.ID", "Order", "Family", "Genus", "species", "earliest", "latest", "Country", "State", "County", "Fm.")
  # Conduct hierarchical sorting by institutional code, genus, and species.
  data_selected_sorted <- data_selected[order(data_selected$InstCode, data_selected$Genus, data_selected$species),]
  # Remove rows whose institutional code is NA.
  data_selected_sorted <- data_selected_sorted[!is.na(data_selected_sorted$InstCode), ]
  
  # 4. Text value capitalization
  # Capitalise the first letters of certain columns (i.e. Order, Family, Genus, Country, County, Fm.).
  col_to_cap <- c("Order", "Family", "Genus", "Country", "State", "County", "Fm.")
  data_selected_sorted[,col_to_cap] <- apply(data_selected_sorted[,col_to_cap], c(1,2), cap_head)
  # Capitalize names of geologic ages.
  col_to_cap_age <- c("earliest", "latest")
  data_selected_sorted[,col_to_cap_age] <- apply(data_selected_sorted[,col_to_cap_age], c(1,2), cap_head_age)
  
  # 5. Species comparison
  # Conduct species comparison if intended by the user.
  position <- c()
  if (!is.null(Path)){
    # Read the user's taxon list.
    MyTaxa <- read.delim(file = Path, header = FALSE, sep = ",", col.names = c("Genus", "species"))
    # Get row numbers from data_selected_sorted that have the same genus and species combination as in MyTaxa.
    position <- which(data_selected_sorted[, "Genus"] %in% MyTaxa[, "Genus"] & data_selected_sorted[, "species"] %in% MyTaxa[, "species"])
    # If Search_Missing_Taxa = TRUE, reverse the position vector to produce row numbers of taxa that are missing from MyTaxa.
    if (Search_Missing_Taxa == TRUE){
      all_rows <- 1:nrow(data_selected_sorted)
      position <- all_rows[!all_rows %in% position]
    }
  }
  
  # 6. Table production
  # Make a table. If any row needs to be highlighted, table_SpComparison function is used. If not, simple_table function is used. 
  if (length(position) >= 1){
    table_SpComparison(data = data_selected_sorted, Position = position)
  }else{
    simple_table(data = data_selected_sorted)
  }
}




# Function:cap_head
# Capitalizes all the first letters multiple words. 
cap_head <- function(string) {
  text <- strsplit(string, " ")[[1]]
  substring(text, 1,1) <- toupper(substring(text, 1,1))
  paste(text, collapse = " ")
}



# Function: cap_head_age
# Capitalizes the first letter of any names of geologic periods. Prefixes, such as "early", "middle", and "late", will not be modified.
cap_head_age <- function(string) {
  text <- strsplit(string, " ")[[1]]
  periods <- c("siderian", "rhyacian", "orosirian", "statherian", "calymmian", "ectasian", "stenian", "tonian", "cryogenian", "ediacaran", "cambrian", "ordovician", "silurian", "devonian", "carboniferous", "permian", "triassic", "jurassic", "cretaceous", "paleogene", "neogene", "tertiary", "quaternary")
  substring(text[text %in% periods], 1,1) <- toupper(substring(text[text %in% periods], 1,1))
  paste(text, collapse = " ")
}



# Function: simple_table
# Visualize data in table format without highliting rows.
simple_table <- function(data){
  kable(data, format = "html", align = "l", row.names = FALSE, table.attr = "style = \"color: black;\"") %>%
    kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 12, fixed_thead = T)%>%
    # Header arrangement
    add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
    # Group rows with institutional categories.
    collapse_rows(columns = 1, valign = "top")
}



# Function: table_SpComparison
# Visualize data in table format with highlighting certain rows.
table_SpComparison <- function(data, Position){
  kable(data, format = "html", align = "l", row.names = FALSE, table.attr = "style = \"color: black;\"") %>%
    kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 12, fixed_thead = T)%>%
    # Header arrangement.
    add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
    # Highlight the rows specified by Position argument.
    row_spec(Position, color = "red")%>%
    # Group rows with institutional categories.
    collapse_rows(columns = 1, valign = "top")
}
