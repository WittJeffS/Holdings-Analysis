######################################################################
######################################################################

# Creates a list of historic holdings history organized by holding 
# type and security id.

######################################################################
######################################################################


library(dplyr)
library(magrittr)
library(stringr)

# pull consolidated BBHoldings files
dir.files <- 'G:/Axys/BBHoldings/Historical' %>%  dir
agg.files <- dir.files  %>%  str_count('\\+')  %>%  as.logical 
agg.files <- dir.files[agg.files]

# save dates in yyyymmdd format
nms <- str_sub(agg.files, 17, 22)
nms <- as.Date(nms, format = '%m%d%y')
nms <- format(nms, format = '%Y%m%d')

# read historic holdings data
getData <- function(x){
     y <- read.csv(x, header = FALSE, stringsAsFactors = FALSE)
     y <- y[,2:4]
     names(y) <- c('date','holding','id')

     return(y)
}

agg.files <- paste0('G:/Axys/BBholdings/Historical/', agg.files)

agg.hold        <- lapply(agg.files, FUN = getData)
names(agg.hold) <- nms
agg.hold        <- agg.hold[sort(nms)]

# transform from list to data.frame, add security type info
agg.hold.df     <- as.data.frame(bind_rows(agg.hold))
source('securityInfo.R')
agg.hold.df     <- merge(agg.hold.df, sec.info, 
                         by    = 'id', 
                         all.x = TRUE)

# reorder and format data.frame
agg.hold.df$holding <- as.numeric(gsub(',','',agg.hold.df$holding))
agg.hold.df$date    <- as.Date(agg.hold.df$date, format = '%m/%d/%y')
agg.hold.df         <- agg.hold.df[order(agg.hold.df$date),]

# assign missing security types
agg.hold.df$type[which(agg.hold.df$id == 'cash_usd')] <- 'ca'
agg.hold.df$type[is.na(agg.hold.df$type)] <- 'no-type'

# split data.frame by type
agg.hold.tick   <- split(agg.hold.df, agg.hold.df$type)
 
# split common stock data.frame by issuer
xx <- agg.hold.tick[['cs']]
xx <- split(xx, xx$id)
agg.hold.tick[['cs']] <- xx

# save list to working directory
save(agg.hold.tick, file = 'agg.hold.tick.RData')

