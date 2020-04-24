# installation of tools
devtools::install_github("mplex/HASS", subdir="pkg/ddhh")
devtools::install_github("sdam-au/HASS", subdir="pkg/ddhh")


library(ddhh)
library(dplyr)
library(tidyverse)

# loading the already existing dataset EDH - where do I load it from?

data("EDH")

class(EDH)

EDH_inscriptions <- lapply(EDH, function (x) x[c("ID","diplomatic_text", "transcription")])

EDH_df <-as.data.frame(do.call(rbind, EDH_inscriptions))

class(EDH_df)
names(EDH_df)

# testing the cleaning script

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