library(readr)
library(tidytext)
library(dplyr)
library(tidyverse)
library(stringr)
library(magrittr)
library(rjson)

inscriptions <- load(file="data/epalln.Rdata")


EDH_inscriptions <- lapply(epalln, function (x) x[c("ID", "language", "material", "type_of_monument", 
                                                    "findpost_ancient", "findspot_modern",
                                                    "country","province_label", "not_after", "not_before", 
                                                    "type_of_inscription", "diplomatic_text", "transcription")] )
EDH_df <-as.data.frame(do.call(rbind, EDH_inscriptions))

head(EDH_df)
colnames(EDH_df)


# Cleaning

cleaning_phi_inscriptions <- function(original_text) {
  clean_text <- gsub(pattern="\\[[— ]+\\]", replacement="", x=original_text, perl=TRUE) # missing text in square brackets replaced by nothing
  clean_text <- gsub(pattern="{[^}]*}[⁰¹²³⁴⁵⁶⁷⁸⁹]+", replacement="", x=clean_text, perl=TRUE) #suggested substituted text in curly braces and with superscript number replaced by nothing
  clean_text <- gsub(pattern="[⁰¹²³⁴⁵⁶⁷⁸⁹]+", replacement="", x=clean_text, perl=TRUE) #getting rid of all superscripts
  clean_text <- gsub(pattern="-\\n", replacement="", x=clean_text, perl=TRUE) #joining words split into two lines
  clean_text <- gsub(pattern="[\\{\\<\\[\\(*\\)\\]\\>\\}]", replacement="", x=clean_text, perl=TRUE) #getting rid of square and round brackets, substituting with nothing
  clean_text <- gsub(pattern="[⏕–⏓〛〚\\|,.#%?!—∙·❦⏑/]", replacement=" ", x=clean_text, perl=TRUE) #getting rid of all sorts of things that I don't need, substituting with space
  clean_text <- gsub(pattern="(vacat|vac|vac.|v.)", replacement=" ", x=clean_text, perl=TRUE) 
  clean_text <- gsub(pattern="\\s+", replacement=" ", x=clean_text, perl=TRUE) # getting rid of more than one white space, substituting with one white space
  clean_text <- gsub(pattern="\\s$", replacement="", x=clean_text, perl=TRUE) # getting rid of extra white space at the end of the line
  return(clean_text)
}


inscriptions_cleaned <- EDH_df %>% 
  mutate(text_clean = cleaning_phi_inscriptions(EDH_df$transcription))
