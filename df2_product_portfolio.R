# Map 1-based optional input ports to variables
inputShpmtData <- maml.mapInputPort(1) # class: data.frame
Summary <- maml.mapInputPort(2)

sparsed<-function(idx,dataSetC){
  record<-dataSetC[idx,2:ncol(dataSetC)]
  zeros<-rowSums(record==0)
  return((zeros/ncol(record))*100)
}

inputShpmtData$sparsity<-sapply(1:nrow(inputShpmtData),sparsed,dataSetC=inputShpmtData)

inputShpmtData$std_deviation<-Summary[,15]

#if std_deviation>100 -------->1 high variance data
#std_deviation<100------------>low variance ----- check for sparsity
#sparsity>25------------------>2 high sparsity
#sparsity<25------------------>0 low sparsity & low variance

inputShpmtData$ProductPortfolio <- ifelse(inputShpmtData$std_deviation>100,1,ifelse(inputShpmtData$sparsity>25,2,0))

inputShpmtData<-data.frame(inputShpmtData)


# Select data.frame to be sent to the output Dataset port
maml.mapOutputPort("inputShpmtData")
