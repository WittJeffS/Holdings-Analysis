######################################################################
######################################################################

# read in sec.asc, define columns

######################################################################
######################################################################
library(magrittr)

sec  <- readLines(con = 'C:/PORT/INFORM/SEC.INF')
type <- substring(sec,1,2)
id   <- substring(sec,3, 11)  %>%  trimws()

sec.info <- data.frame(type = type, id = id, stringsAsFactors = FALSE)