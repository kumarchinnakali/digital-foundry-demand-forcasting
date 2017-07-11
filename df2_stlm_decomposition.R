library(plyr)
library(sqldf)
library(data.table)
library(MASS)
library(abind)
library(acepack)
library(leaps)
library(forecast)

allmarketsdata  <- maml.mapInputPort(1)

calculateMASE <- function(y,f) { # f = vector with forecasts, y = vector with actuals
  if(length(f)!=length(y)){ stop("Vector length is not equal") }
  n <- length(f)
  return(mean(abs((y - f) / ((1/(n-1)) * sum(abs(y[2:n]-y[1:n-1]))))))
}

mape <- function(actual,pred){
  mape <- mean(abs((actual - pred)/actual))*100
  return (mape)
}

processMarketProdData<-function(listElmnt)
{
  listTokens<-strsplit(listElmnt, "#")
  marketId<-listTokens[[1]][1]
  productId<-listTokens[[1]][2]
  prdMktLevelModel<- subset(allmarketsdata, PRDCTAG == productId & MRKTTAG == marketId, 
                            select=c(MRKTTAG,PRDCTAG,SALESUNITS,WeekendingDate))
  
  dataset1Tab <- as.data.table(prdMktLevelModel)
  
  #TRAIN DATA 
  rowStrtIdx <- 9
  rowEndIdx<-nrow(prdMktLevelModel)-13 
  prdMktLevelTRAINData <-prdMktLevelModel[rowStrtIdx:rowEndIdx,] 
  #EXTERNAL DATA
  rowStrtIdx<-nrow(prdMktLevelModel)-12
  rowEndIdx<-nrow(prdMktLevelModel) 
  prdMktLevelValDataExt<-prdMktLevelModel[rowStrtIdx:rowEndIdx,] 
  
  #Fitting Train data  
  actualsTrain <- prdMktLevelTRAINData$SALESUNITS
  t <- ts(actualsTrain,frequency=2)
  foo <- stlm(t,"periodic")
  fittedTrain <- foo$fitted
  fittedTrain <- replace(fittedTrain, is.na(fittedTrain), 0)
  
  actualsPredsTrain<-as.data.frame(cbind(actuals=actualsTrain,fittedvals=fittedTrain))
  head(actualsPredsTrain)
  
  trainPreds<-cbind(actualsPredsTrain, prdMktLevelTRAINData[,c("MRKTTAG","PRDCTAG","SALESUNITS","WeekendingDate")])
  #accuracysummary<-accuracy(fcast$mean,actualsTrain)
  trainPreds$MASE_error <- calculateMASE(trainPreds$actuals,trainPreds$fittedvals)
  trainPreds$noofrows<-nrow(trainPreds)
  trainPreds$external1<-FALSE
  print(paste0("b4 actualsPreds.train print.",nrow(trainPreds),"####", ncol(trainPreds)))
  dim(trainPreds)
  #head(trainPreds)
  
  #Fitting External Data
  actualsExt <- prdMktLevelValDataExt$SALESUNITS
  t2 <- ts(actualsExt,frequency=2)
  foo2 <- stlm(t2,"periodic")
  fittedExt <- foo2$fitted
  fittedExt <- replace(fittedExt, is.na(fittedExt), 0)
  actualsPredsExt<-as.data.frame(cbind(actuals=actualsExt,extPredictions=fittedExt))
  head(actualsPredsExt)
  
  
  extPreds<-cbind(actualsPredsExt, prdMktLevelValDataExt[,c("MRKTTAG","PRDCTAG","SALESUNITS","WeekendingDate")])
  extPreds$MASE_error <-calculateMASE(extPreds$actuals,extPreds$extPredictions)
  extPreds$noofrows<-nrow(extPreds)
  extPreds$external1<-TRUE
  
  ##### graphics for external data external predictions
  
  print(paste0("b4 actualsPreds.external print.",nrow(extPreds), "####", ncol(extPreds)))
  dim(extPreds)
  #head(extPreds)
  
  names(extPreds)<-names(trainPreds)
  consolidatedPredictions<-rbind(trainPreds,extPreds)
  return(consolidatedPredictions) 
  
}
#allmarketsdata$WeekendingDate <- as.Date(as.character(allmarketsdata$WeekendingDate),format = "%Y%m%d")
# Derive Market Product Concatenated column.
#mrktProdTags<-paste0(allmarketsdata$MRKTTAG, "#", allmarketsdata$PRDCTAG)
#allmarketsdata$MarketProdTags<-mrktProdTags
uniqMrktProdTags<-unique(allmarketsdata$MarketProdTags)
ldf<-lapply(uniqMrktProdTags,processMarketProdData)
tres_for_prodmarket <- ldply(ldf, data.frame)
tres_for_prodmarket

maml.mapOutputPort("tres_for_prodmarket")