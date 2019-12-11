# not recommended due to large data size.
# How about using a loop to search in multiple order levels?
# List of order names for specified class needed. (May be available from PBDB??)

# All rank search!
collection <- function (Rank, Taxon) {
  # get data from idigbio
  listname <- c(Rank)
  idiglist <- list(Taxon)
  names(idiglist) <- listname
  data <- idig_search_records(rq=idiglist, fields = "all")
  
  # extract neccessary columns.
  col_needed <- c("institutioncode", "catalognumber", "order", "family", "genus", "specificepithet", "earliestperiodorlowestsystem", "latestperiodorhighestsystem", "country", "county", "stateprovince", "formation")
  data_selected <- select(data, col_needed)
  #sort by institutional code, genus, species.
  data_selected_sorted <- data_selected[order(data_selected$institutioncode, data_selected$genus, data_selected$specificepithet),]
  # delete rows if institutional code is NA.
  data_selected_sorted <- data_selected_sorted[!is.na(data_selected_sorted$institutioncode), ]
  
  # make a list of institution codes.
  # remove na value
  inst_code_list <- unique(data_selected_sorted$institutioncode)
  inst_code_list <- na.omit(inst_code_list)
  
  # make empty vectors
  start_row <- c()
  end_row <- c(0)
  # fill the vectors with starting and ending # of rows for each institution.
  for (i in 1:length(inst_code_list)){
    start_row <- c(start_row, end_row[i]+1)
    row_by_inst <- nrow(data_selected_sorted[data_selected_sorted$institutioncode==inst_code_list[i],])
    end_row <- c(end_row, start_row[i]+row_by_inst-1)
  }
  # delete the first element of end_row: value 0  
  end_row <- end_row[-1]
  # create a matrix that contain start row and end row of each institution
  row_range_inst <- rbind(inst_code_list, start_row, end_row)
  
  # Capitalise certain columns (Order, Family, Genus, Country, County, Fm.)  
  
  
  # Still need to pack-rows!
  data_selected_sorted$institutioncode <- NULL
  kable(data_selected_sorted, format = "html", col.names = c("Col.ID", "Order", "Fam", "Gen", "sp.", "earliest", "latest", "Country", "County", "State", "Fm."), align = "l") %>%
    kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 11, fixed_thead = T)%>%
    # Header arrangement
    add_header_above(c(" " = 2, "Classification" = 4, "Age" = 2, "Locality" = 4))%>%
    # Italize Genus and species names.
    column_spec(column = c(5,6), italic = TRUE)
}




# Genus level search (NULL)
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
  # If the table is output as PDF, fixed_thead = T is not needed.
  print(kable(dataframe_list, format = "html", col.names = c("ColID", "Order", "Fam", "Gen", "Sp.", "eAge", "lAge", "Country", "County", "State", "Fm."), align = "l") %>%
          kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, position = "left", font_size = 11, fixed_thead = T))
  cat("\n")
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















