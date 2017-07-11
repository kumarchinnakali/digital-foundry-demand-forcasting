# Map 1-based optional input ports to variables
allmarketsdata <- maml.mapInputPort(1) # class: data.frame

allmarketsdata <- replace(allmarketsdata, is.na(allmarketsdata), 0)
allmarketsdata$WeekendingDate <- as.Date(as.character(allmarketsdata$WeekendingDate),format = "%Y%m%d")
mrktProdTags<-paste0(allmarketsdata$MRKTTAG, "#", allmarketsdata$PRDCTAG)
allmarketsdata$MarketProdTags<-mrktProdTags

# Select data.frame to be sent to the output Dataset port
maml.mapOutputPort("allmarketsdata")