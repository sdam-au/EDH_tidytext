library(readr)
library(tidytext)
library(dplyr)
library(tidyverse)
library(stringr)
library(magrittr)
library(rjson)
library(utf8)
library(jsonlite)


# Cleaning of the epigraphic texts function

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



# load json data from Vojtech
inscriptionsJSON <- fromJSON(file = "data/inscriptions_short.json")

# load sample json for testing and debugging
sample_json <- fromJSON(txt = "data/inscriptions_sample.json")
# confirm it is a list
class(sample_json)
# list column names
names(sample_json)

# transforming nested list into dataframe
sample_df <- do.call(rbind, sample_json) %>% 
  as.data.frame

# second way how to transform list into dataframe
sample_df <-as.data.frame(do.call(rbind, sample_json))

# confirm it is a dataframe
class(sample_df)


# ideally this cleaning script should work, but it does not work on the list
inscriptions_cleaned_sample <- sample_df %>% 
  mutate(text_clean = cleaning_edh_inscriptions(sample_df$transcription))

# unlisting json sample and running cleaning only on text transcription only, to make sure the cleaning script works
sample_transcription <- as.data.frame(unlist(sample_json$transcription, recursive = TRUE, use.names = TRUE))
head(sample_transcription)

inscriptions_cleaned_sample <- sample_transcription %>% 
  mutate(text_clean = cleaning_edh_inscriptions(sample_transcription$`unlist(sample_json$transcription, recursive = TRUE, use.names = TRUE)`))
# I would like to run the cleaning script on the json file, but in order to have it in the right structure, I need to transpose the observations and attributes 
# (so it has the longer rather than wider format), but I don't know how to do it with lists.

