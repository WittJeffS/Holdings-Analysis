library(dplyr)
library(magrittr)
library(stringr)


dir.files <- 'G:/Axys/BBHoldings/Historical' %>% 
     dir

agg.files <- dir.files  %>%  str_count('\\+')  %>%  as.logical 
     
agg.files <- dir.files[agg.files]

nms <- str_sub(agg.files, 17, 22)
nms <- as.Date(nms, format = '%m%d%y')
nms <- format(nms, format = '%Y%m%d')

agg.files <- paste0('G:/Axys/BBholdings/Historical/', agg.files)

f <- function(x){
     y <- read.csv(x, header = FALSE, stringsAsFactors = FALSE)
     y <- y[,2:4]
     names(y) <- c('date','holding','id')

     return(y)
}

agg.hold        <- lapply(agg.files, FUN = f)
names(agg.hold) <- nms
agg.hold        <- agg.hold[sort(nms)]

agg.hold.df     <- as.data.frame(bind_rows(agg.hold))
agg.hold.df     <- merge(agg.hold.df, sec.info, 
                         by    = 'id', 
                         all.x = TRUE)

agg.hold.df$holding <- as.numeric(gsub(',','',agg.hold.df$holding))

agg.hold.df$date <- as.Date(agg.hold.df$date, format = '%m/%d/%y')
agg.hold.df <- agg.hold.df[order(agg.hold.df$date),]

agg.hold.df$type[which(agg.hold.df$id == 'cash_usd')] <- 'ca'
agg.hold.df$type[is.na(agg.hold.df$type)] <- 'no-type'


agg.hold.tick   <- split(agg.hold.df, agg.hold.df$type)

xx <- agg.hold.tick[['cs']]
xx <- split(xx, xx$id)
agg.hold.tick[['cs']] <- xx

plotHoldings <- function(tick){
     xx <- agg.hold.tick$cs[[tick]]
     
     p <- ggplot(xx, aes(date, holding)) + geom_line()
     
     return (p)
}

