# installation of tools
devtools::install_github("mplex/HASS", subdir="pkg/ddhh")
devtools::install_github("sdam-au/HASS", subdir="pkg/ddhh")

library(ddhh)
library(dplyr)
library(tidyverse)


# using blogpost https://sdam-au.github.io/sdam-au/short-reports/epigraphy/2019/11/26/Epigraphic_Database_Heidelberg_using_R.html
# for instructions

# getting the data from EDH API via R, divided into categories - ERROR, does not work
EDH_all <- get.edh(search = c("inscriptions", "geography"), 
        url = "https://edh-www.adw.uni-heidelberg.de/data/api", 
        ID, hd_nr, uri, tm_nr, trismegistos_uri, pleiades_id, geonames_id, addID, last_update, responsible_individual, work_status,
        country, modern_region, findspot_modern, province_label, findspot_ancient, bbox, edh_geography_uri,
        year_not_before, year_not_after, 
        type_of_monument,  
        material, depth, height, width, letter_size,
        type_of_inscription,
        language, diplomatic_text, transcription, 
        people,
        commentary, literature
)

# access 1 inscription with specified hd_nr
insc_2564 <-get.edh(hd_nr="2564") # gets 1 inscription

# access 100 inscriptions - no success
sample100 <- c(1:100)
insc_1_to_100 <-get.edh(hd_nr=sample100) 

# access inscriptions from 1 place
Sofia <- get.edh(findspot_modern="Sofia") # produces list of 1, empty, not really an output I wanted

# access inscriptions from 1 country
Bulgaria <-get.edh(country="Bulgaria") # produces list of 1, empty, not really an output I wanted

# trying examples from Antonio's blogpost -ERROR

marble <-get.edh(search = c("inscriptions", "geography"), 
                 url = "https://edh-www.adw.uni-heidelberg.de/data/api", material = "marmor")

# loading the already existing dataset EDH - where do I load it from?

data("EDH")

class(EDH)

# select all the categories that interest me 

#EDH_inscriptions <- lapply(EDH, function (x) x[c("ID", "id", "uri", "tm_nr", "trismegistos_uri", "pleiades_id", "geonames_id", "addID", "last_update", "responsible_individual", "work_status",
#"country", "modern_region", "province_label", "findspot", "year_of_find", "coordinates", "findspot_modern", "findspot_ancient", "edh_geography_uri","present_location",
#"not_before", "not_after", "type_of_monument","material", "depth", "height", "width", "letter_size",
#"type_of_inscription", "language", "origdate_text", "diplomatic_text", "transcription", 
#"people", "religion","geography", "military", "social_economic_legal_history","objecttype", "commentary", "literature", "fotos", "external_image_uris")] )


EDH_inscriptions <- lapply(EDH, function (x) x[c("ID","diplomatic_text", "transcription")])

EDH_df <-as.data.frame(do.call(rbind, EDH_inscriptions))

class(EDH_df)
names(EDH_df)

# I am getting a lot of NA's but I am using categories from vojtech's JSON that exist in the API,, but probably the get.edh() function does not grab them.

# testing the clenaing script

cleaning_edh_inscriptions <- function(original_text) {
  clean_text <- gsub(pattern="\\[[— ]+\\]", replacement="", x=original_text, perl=TRUE) # missing text in square brackets replaced by nothing
  clean_text <- gsub(pattern="\\[[-]+\\]", replacement="", x=clean_text, perl=TRUE)
  clean_text <- gsub(pattern="{[^}]*}[⁰¹²³⁴⁵⁶⁷⁸⁹]+", replacement="", x=clean_text, perl=TRUE) #suggested substituted text in curly braces and with superscript number replaced by nothing
  clean_text <- gsub(pattern="[⁰¹²³⁴⁵⁶⁷⁸⁹]+", replacement="", x=clean_text, perl=TRUE) #getting rid of all superscripts
  clean_text <- gsub(pattern="-\\n", replacement="", x=clean_text, perl=TRUE) #joining words split into two lines
  clean_text <- gsub(pattern="[\\{\\<\\[\\(*\\)\\]\\>\\}]", replacement="", x=clean_text, perl=TRUE) #getting rid of square and round brackets, substituting with nothing
  clean_text <- gsub(pattern="[⏕–⏓〛〚\\|,.#%?!—∙·❦⏑/]", replacement=" ", x=clean_text, perl=TRUE) #getting rid of all sorts of things that I don't need, substituting with space
  clean_text <- gsub(pattern="(vacat|vac|vac.|v.)", replacement=" ", x=clean_text, perl=TRUE) 
  clean_text <- gsub(pattern="\\s+", replacement=" ", x=clean_text, perl=TRUE) # getting rid of more than one white space, substituting with one white space
  clean_text <- gsub(pattern="^\\s", replacement="", x=clean_text, perl=TRUE) # getting rid of extra white space at the beginning of the line
  clean_text <- gsub(pattern="\\s$", replacement="", x=clean_text, perl=TRUE) # getting rid of extra white space at the end of the line
  return(clean_text)
}


# cleaning the dataset
inscriptions_cleaned <- EDH_df %>%
  mutate(text_clean = cleaning_edh_inscriptions(EDH_df$transcription))
