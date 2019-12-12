# not recommended due to large data size.
# How about using a loop to search in multiple order levels?
# List of order names for specified class needed. (May be available from PBDB??)

#capitalize function
cap_head <- function(text) {
  substr(text, 1, 1) <- toupper(substr(text, 1, 1))
  text
}


# All rank search!
collection <- function (Rank, Taxon) {
  # get data from idigbio
  listname <- c(Rank)
  idiglist <- list(Taxon)
  names(idiglist) <- listname
  data <- idig_search_records(rq=idiglist, fields = "all")
  
  # extract neccessary columns.
  col_needed <- c("institutioncode", "catalognumber", "order", "family", "genus", "specificepithet", "earliestperiodorlowestsystem", "latestperiodorhighestsystem", "country", "stateprovince", "county", "formation")
  data_selected <- select(data, col_needed)
  #sort by institutional code, genus, species.
  data_selected_sorted <- data_selected[order(data_selected$institutioncode, data_selected$genus, data_selected$specificepithet),]
  # delete rows if institutional code is NA.
  data_selected_sorted <- data_selected_sorted[!is.na(data_selected_sorted$institutioncode), ]
  

  # Capitalise certain columns (Order, Family, Genus, Country, County, Fm.)  
  col_to_cap <- c("order","family","genus","country","stateprovince","county","formation")
  data_selected_sorted[,col_to_cap] <- apply(data_selected_sorted[,col_to_cap], 2, cap_head)
  
  # Make a table
  data_selected_sorted$institutioncode <- NULL
  kable(data_selected_sorted, format = "html", col.names = c("InstCode", "Col.ID", "Order", "Family", "Genus", "species", "earliest", "latest", "Country", "State", "County", "Fm."), align = "l", row.names = FALSE) %>%
    kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 12, fixed_thead = T)%>%
    # Header arrangement
    add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
    # Group rows with institutional categories.
    collapse_rows(columns = 1, valign = "top")
}




# General taxon search and Species list comparison
# Path can be a path to a taxon file of .CSV or comma delimited text file.
compare_taxa <- function (Rank, Taxon, Path, Search_Missing_Taxa) {  
  # get data from idigbio
  listname <- c(Rank)
  idiglist <- list(Taxon)
  names(idiglist) <- listname
  data <- idig_search_records(rq=idiglist, fields = "all")
  
  # extract neccessary columns.
  col_needed <- c("institutioncode", "catalognumber", "order", "family", "genus", "specificepithet", "earliestperiodorlowestsystem", "latestperiodorhighestsystem", "country", "stateprovince", "county", "formation")
  data_selected <- select(data, col_needed)
  #sort by institutional code, genus, species.
  data_selected_sorted <- data_selected[order(data_selected$institutioncode, data_selected$genus, data_selected$specificepithet),]
  # delete rows if institutional code is NA.
  data_selected_sorted <- data_selected_sorted[!is.na(data_selected_sorted$institutioncode), ]
  
  
  # Capitalise certain columns (Order, Family, Genus, Country, County, Fm.)
  col_to_cap <- c("order","family","genus","country","stateprovince","county","formation")
  data_selected_sorted[,col_to_cap] <- apply(data_selected_sorted[,col_to_cap], 2, cap_head)
  
  # Read my taxon list file using function argument PATH.
  MyTaxa <- read.delim(file = Path, header = FALSE, sep = ",", col.names = c("Genus", "species"))
  # Conduct get row numbers of taxa from data_selected_sorted that can be found within MyTaxa.
  position <- which(data_selected_sorted[, "genus"] %in% MyTaxa[, "Genus"] & data_selected_sorted[, "specificepithet"] %in% MyTaxa[, "species"])
  # If Search_Missing_Taxa argument is TRUE, reverse the previous search and produce row numbers of taxa that are missing from MyTaxa.
  if (Search_Missing_Taxa == TRUE){
    all_rows <- 1:nrow(data_selected_sorted)
    position <- all_rows[!all_rows %in% position]
  }
  

  # Make a table.
  kable(data_selected_sorted, format = "html", col.names = c("InstCode", "Col.ID", "Order", "Family", "Genus", "species", "earliest", "latest", "Country", "State", "County", "Fm."), align = "l", row.names = FALSE) %>%
    kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 12, fixed_thead = T)%>%
    # Header arrangement
    add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
    # Highlight the rows specified by position.
    row_spec(position, color = "red")%>%
    # Group rows with institutional categories.
    collapse_rows(columns = 1, valign = "top")
}