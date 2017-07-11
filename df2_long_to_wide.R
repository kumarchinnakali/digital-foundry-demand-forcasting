library(reshape)

# Map 1-based optional input ports to variables
allmarketsdata <- maml.mapInputPort(1) # class: data.frame
#allmarketsdata  <- read.delim("D:\\Users\\kamgupta\\Desktop\\R\\AllMarketsData1.csv", header = TRUE, sep=",")

allmarketsdata$WeekendingDate <- as.Date(as.character(allmarketsdata$WeekendingDate),format = "%Y%m%d")
allmarketsdata <- replace(allmarketsdata, is.na(allmarketsdata), 0)

mrktProdTags<-paste0(allmarketsdata$MRKTTAG, "#", allmarketsdata$PRDCTAG)
allmarketsdata$MarketProdTags<-mrktProdTags

Marketsubset <- subset(allmarketsdata, select=c(MarketProdTags,SALESUNITS, WeekendingDate))
wideview <- reshape(Marketsubset, idvar = "MarketProdTags", timevar = "WeekendingDate", direction = "wide")
wideview <- data.frame(wideview)
maml.mapOutputPort("wideview");