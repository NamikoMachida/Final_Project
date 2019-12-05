# not recommended due to large data size.
# How about using a loop to search in multiple order levels?
# List of order names for specified class needed. (May be available from PBDB??)
collection_class <- function (Taxon) {
  data <- idig_search_records(rq=list(class=Taxon), fields = "all")
  head(data, n=10)
}

# Order level serach
# (Use If statement to report errors if inappropriate rank is provided (order, family, genus))
collection_order <- function (Taxon) {
  data <- idig_search_records(rq=list(order=Taxon), fields = "all")
  head(data, n=10)
}

# Family level search
collection_family <- function (Taxon) {
  data <- idig_search_records(rq=list(family=Taxon), fields = "all")
  head(data, n=10)
}


# Genus level search
collection_genus <- function (Taxon) {
  data <- idig_search_records(rq=list(genus=Taxon), fields = "all")
  # extract neccessarycolumns.
  col_needed <- c("institutioncode", "catalognumber", "order", "family", "genus", "specificepithet", "earliestperiodorlowestsystem", "latestperiodorhighestsystem", "country", "county", "stateprovince", "formation")
  data_selected <- select(data, col_needed)
  # make a list of institution codes.
  # convert it into a vector
  inst_code_list <- unique(data_selected$institutioncode)
  as.vector(inst_code_list)
  
  # for loop to make a table for each institution
  # delete the column of institution code
  # make tables (Huge!!)
  dataframe_list <- list()
  for (i in 1:length(inst_code_list)){
    data_fortab <- data_selected
    inst_code <- inst_code_list[i]
  
    data_fortab <- data_selected[data_selected$institutioncode==inst_code, ]
    data_fortab$institutioncode <- NULL
    dataframe_list <- append(dataframe_list, list(data_fortab))
    names(dataframe_list)[i] <- paste0("data_fortab",i)
  }
  kable(dataframe_list, format = "html", col.names = c("ColID", "Order", "Fam", "Gen", "Sp.", "eAge", "lAge", "Country", "County", "State", "Fm."), align = "l") %>%
    kable_styling(bootstrap_options = "striped", full_width = F)
}



# Species level serach
collection_species <- function (Taxon) {
  data <- idig_search_records(rq=list(species=Taxon), fields = "all")
  head(data, n=10)
}





# Species list comparison
compare_taxa_genus <- function (Taxon, Path) {
  data <- idig_search_records(rq=list(genus=Taxon), fields = "all")
  col_needed <- c("institutioncode", "catalognumber", "order", "family", "genus", "specificepithet", "earliestperiodorlowestsystem", "latestperiodorhighestsystem", "country", "county", "stateprovince", "formation")
  data_selected <- select(data, col_needed)
  
  inst_code_list <- unique(data_selected$institutioncode)
  as.vector(inst_code_list)
  
  data_selected_vector <- c()
  for (code in 1:length(inst_code_list)){
    data_fortab <- data_selected
    inst_code <- inst_code_list[code]
    
    data_fortab <- data_selected[data_selected$institutioncode==inst_code, ]
    data_fortab$institutioncode <- NULL
    data_selected_vector <- c(data_selected_vector, list(data_fortab))
  }
  
  MyTaxa <- read.delim(file = Path, header = FALSE, sep = "", col.names = c("Genus", "species"))
  
  for (obj in 1:length(data_selected_vector)){
    UnCodedSp_vector <- data_selected_vector[[obj]][["specificepithet"]] %in% MyTaxa$species
    UnCodedSp_row <- which(UnCodedSp_vector==FALSE)
    print(kable(data_selected_vector[[obj]], format = "html", col.names = c("ColID", "Order", "Fam", "Gen", "Sp.", "eAge", "lAge", "Country", "County", "State", "Fm."), align = "l") %>%
            kable_styling(bootstrap_options = "striped", full_width = F) %>%
            row_spec(UnCodedSp_row, color = "red"))
    cat("\n")
    # What does the cat("\n") mean? (https://stackoverflow.com/questions/39650166/r-why-kable-doesnt-print-inside-a-for-loop)
  }
}















