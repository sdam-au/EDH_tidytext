# installation of tools
devtools::install_github("sdam-au/sdam", auth_token="51f84dceaf4d74b32c3aff161f213f492b0ce8b2")

library(ddhh)

# using blogpost https://sdam-au.github.io/sdam-au/short-reports/epigraphy/2019/11/26/Epigraphic_Database_Heidelberg_using_R.html
# for instructions

# getting the data from EDH API via R, divided into categories

# lists all the arguments
formals('get.edh')


# access 1 inscription with specified hd_nr
insc_2564 <-get.edh(hd_nr="2564") # gets 1 inscription

# access 100 inscriptions - no success
sample10 <- get.edhw(HD_nr=1:10)
# Error: Error in get.edhw(HD_nr = 1:10) : could not find function "get.edhw"


# access inscriptions from 1 place
Sofia <- get.edh(findspot_modern="Sofia") # produces list of 1, empty, not really an output I wanted

# access inscriptions from 1 country
Bulgaria <-get.edh(country="Bulgaria") # produces list of 1, empty, not really an output I wanted

# trying examples from Antonio's blogpost 

marble <-get.edh(search = c("inscriptions", "geography"), 
                 url = "https://edh-www.adw.uni-heidelberg.de/data/api", material = "marmor")

savehistory(file = ".Rhistory")

