#capitalize function
cap_head <- function(string) {
  text <- strsplit(string, " ")[[1]]
  substring(text, 1,1) <- toupper(substring(text, 1,1))
  paste(text, sep = "", collapse = " ")
}

# capitalize function for age columns
cap_head_age <- function(string) {
  text <- strsplit(string, " ")[[1]]
  periods <- c("siderian", "rhyacian", "orosirian", "statherian", "calymmian", "ectasian", "stenian", "tonian", "cryogenian", "ediacaran", "cambrian", "ordovician", "silurian", "devonian", "carboniferous", "permian", "triassic", "jurassic", "cretaceous", "paleogene", "neogene", "tertiary", "quaternary")
  substring(text[text %in% periods], 1,1) <- toupper(substring(text[text %in% periods], 1,1))
  paste(text, sep = "", collapse = " ")
}




# General taxon search and Species list comparison
# Path can be a path to a taxon file of .CSV or comma delimited text file.
# Taxon argument accept multiple taxa as vector.
collection_search <- function (Rank, Taxon, Path = NULL, Search_Missing_Taxa = FALSE) {
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
  
  # get data from idigbio
  idiglist <- list(Taxon)
  names(idiglist) <- c(Rank)
  data <- idig_search_records(rq=idiglist, fields = "all")
  
  # extract neccessary columns.
  col_needed <- c("institutioncode", "catalognumber", "order", "family", "genus", "specificepithet", "earliestperiodorlowestsystem", "latestperiodorhighestsystem", "country", "stateprovince", "county", "formation")
  data_selected <- data[, col_needed]
  #sort by institutional code, genus, species.
  data_selected_sorted <- data_selected[order(data_selected$institutioncode, data_selected$genus, data_selected$specificepithet),]
  # delete rows if institutional code is NA.
  data_selected_sorted <- data_selected_sorted[!is.na(data_selected_sorted$institutioncode), ]

  
  
  # Capitalise certain columns (Order, Family, Genus, Country, County, Fm.)
  col_to_cap <- c("order","family","genus","country","stateprovince","county","formation")
  data_selected_sorted[,col_to_cap] <- apply(data_selected_sorted[,col_to_cap], c(1,2), cap_head)
  # Capitalize age columns
  col_to_cap_age <- c("earliestperiodorlowestsystem", "latestperiodorhighestsystem")
  data_selected_sorted[,col_to_cap_age] <- apply(data_selected_sorted[,col_to_cap_age], c(1,2), cap_head_age)
  
  
  position <- c()
  if (!is.null(Path)){
    # Read my taxon list file using function argument PATH.
    MyTaxa <- read.delim(file = Path, header = FALSE, sep = ",", col.names = c("Genus", "species"))
    # Conduct get row numbers of taxa from data_selected_sorted that can be found within MyTaxa.
    position <- which(data_selected_sorted[, "genus"] %in% MyTaxa[, "Genus"] & data_selected_sorted[, "specificepithet"] %in% MyTaxa[, "species"])
      # If Search_Missing_Taxa argument is TRUE, reverse the previous search and produce row numbers of taxa that are missing from MyTaxa.
      if (Search_Missing_Taxa == TRUE){
        all_rows <- 1:nrow(data_selected_sorted)
        position <- all_rows[!all_rows %in% position]
      }
  }

  # Make a table.
  if (length(position) >= 1){
    kable(data_selected_sorted, format = "html", col.names = c("InstCode", "Col.ID", "Order", "Family", "Genus", "species", "earliest", "latest", "Country", "State", "County", "Fm."), align = "l", row.names = FALSE, table.attr = "style = \"color: black;\"") %>%
      kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 12, fixed_thead = T)%>%
      # Header arrangement
      add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
      # Highlight the rows specified by position.
      row_spec(position, color = "red")%>%
      # Group rows with institutional categories.
      collapse_rows(columns = 1, valign = "top")
  }else{
    kable(data_selected_sorted, format = "html", col.names = c("InstCode", "Col.ID", "Order", "Family", "Genus", "species", "earliest", "latest", "Country", "State", "County", "Fm."), align = "l", row.names = FALSE, table.attr = "style = \"color: black;\"") %>%
      kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 12, fixed_thead = T)%>%
      # Header arrangement
      add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
      # Group rows with institutional categories.
      collapse_rows(columns = 1, valign = "top")%>%
      scroll_box(width = "100%", height = "500px")
  }
}