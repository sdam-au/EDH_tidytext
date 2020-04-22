library(readr)
library(tidytext)
library(dplyr)
library(tidyverse)
library(stringr)
library(magrittr)
library(rjson)
library(utf8)
library(jsonlite)

# load data from Antonio's repo https://github.com/sdam-au/R-code, the next steps copied from  
inscriptions <- load(file="data/epalln.Rdata")
class(epalln)

EDH_inscriptions <- lapply(epalln, function (x) x[c("ID", "language", "material", "type_of_monument", 
                                                    "findpost_ancient", "findspot_modern",
                                                    "country","province_label", "not_after", "not_before", 
                                                    "type_of_inscription", "diplomatic_text", "transcription")] )
EDH_df <-as.data.frame(do.call(rbind, EDH_inscriptions))
EDH_df <- EDH_df[,-5] # deleting fifth column which had no name and no value (strange residue of Antonio's processing)

headEDH <-head(EDH_df)
colnames(EDH_df) 



# Cleaning

cleaning_edh_inscriptions <- function(original_text) {
  clean_text <- gsub(pattern="\\[[— ]+\\]", replacement="", x=original_text, perl=TRUE) # missing text in square brackets replaced by nothing
  #clean_text <- gsub(pattern="[�]", replacement="", x=original_text, perl=TRUE)
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

####################################################### JSON file


# load json data from Vojtech
inscriptionsJSON <- fromJSON(file = "data/inscriptions_short.json")
inscriptionsJSON <- fromJSON(txt = "data/EDH_inscriptions_rich.json")

# sample json for testing
sample_json <- fromJSON(txt = "data/inscriptions_sample.json")
class(sample_json)
names(sample_json)

# transforming nested list into dataframe

sample_df_new <- as.data.frame(sample_json)

sample_df <- do.call(rbind, sample_json) %>% 
  as.data.frame
class(sample_df)


sample_list <- lapply(sample_json, function (x) x[c("diplomatic_text","literature","trismegistos_uri","id","findspot_ancient","not_before","type_of_inscription","work_status","edh_geography_uri","not_after","country","province_label","transcription","material","height","width","findspot_modern","depth","commentary","uri","responsible_individual","last_update","language","modern_region","letter_size","type_of_monument","people","year_of_find","findspot","present_location","external_image_uris","religion","fotos","geography","military","social_economic_legal_history","coordinates","text_cleaned","origdate_text","objecttype")] )

sample_df <-as.data.frame(do.call(rbind, sample_json)) # tranforming list into df
class(sample_df)


inscriptions_cleaned_sample <- sample_df %>% 
  mutate(text_clean = cleaning_edh_inscriptions(sample_df$transcription))

# unlisting json sample and running cleaning only on text transcription
sample_transcription <- as.data.frame(unlist(sample_json$transcription, recursive = TRUE, use.names = TRUE))
head(sample_transcription)

inscriptions_cleaned_sample <- sample_transcription %>% 
  mutate(text_clean = cleaning_edh_inscriptions(sample_transcription$`unlist(sample_json$transcription, recursive = TRUE, use.names = TRUE)`))


# unlisting full json and running cleaning on transcription
inscriptionsJSON_transcription <- as.data.frame(unlist(inscriptionsJSON$transcription, recursive = TRUE, use.names = TRUE))
head(inscriptionsJSON_transcription)

inscriptionsJSON_cleaned <- inscriptionsJSON_transcription %>% 
  mutate(text_clean = cleaning_edh_inscriptions(inscriptionsJSON_transcription$`unlist(inscriptionsJSON$transcription, recursive = TRUE, use.names = TRUE)`))
