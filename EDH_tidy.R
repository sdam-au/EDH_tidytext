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

#confirm it is a list
class(epalln)

#select only certain attributes from the list
EDH_inscriptions <- lapply(epalln, function (x) x[c("ID", "language", "material", "type_of_monument", 
                                                    "findpost_ancient", "findspot_modern",
                                                    "country","province_label", "not_after", "not_before", 
                                                    "type_of_inscription", "diplomatic_text", "transcription")] )
#transform list into a dataframe
EDH_df <-as.data.frame(do.call(rbind, EDH_inscriptions))

# deleting fifth column which had no name and no value (strange residue of Antonio's processing or the EDH itself)
EDH_df <- EDH_df[,-5] 

## there is entry called "findpost_ancient", that is the problem
                        
                           
# confirm the fifth column called 'NA' doe no longer exist
colnames(EDH_df) 


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


# cleaning the dataset
inscriptions_cleaned <- EDH_df %>%
  mutate(text_clean = cleaning_edh_inscriptions(EDH_df$transcription))

# received error: 
# Error in gsub(pattern = "\\[[— ]+\\]", replacement = "", x = original_text,  : 
# input string 45543 is invalid UTF-8 

# failed to create new object with the clean text, 
# inspect where the problem is: inscription 45543, the non-utf symbols \xad\xad\xad or also rendered as ���

print(EDH_df[45543,])
print(EDH_df$transcription[[45543]])

# I assume there are more non-utf characters in the text. I am seeking a permanent solution, how I can identify and get rid of them, so my cleaning script does not break in the middle and cleans the entire dataset.


