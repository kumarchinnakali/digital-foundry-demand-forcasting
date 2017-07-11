# Map 1-based optional input ports to variables
allmarketdata <- maml.mapInputPort(1)
tmp <- data.frame(t(allmarketdata[,-1]))
colnames(tmp) <- allmarketdata$MarketProdTags
# Select data.frame to be sent to the output Dataset port
maml.mapOutputPort("tmp");