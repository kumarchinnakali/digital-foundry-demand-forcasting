library(plyr)
library(sqldf)
library(data.table)
library(MASS)
library(abind)
library(acepack)
library(leaps)

allmarketsdata  <- maml.mapInputPort(1)
n2<-maml.mapInputPort(2) 

mape <- function(actual,pred){
  mape <- mean(abs((actual - pred)/actual))*100
  return (mape)
}

processMarketProdData<-function(listElmnt)
{
  listTokens<-strsplit(listElmnt, "#")
  marketId<-listTokens[[1]][1]
  productId<-listTokens[[1]][2]
  prdMktLevelModelDataWithDatMas <- subset(allmarketsdata, PRDCTAG == productId & MRKTTAG == marketId & SALESUNITS != 0, 
                                           select=c(ANYFEATUREpcACV,ANYDISPLAYpcACV,ANYFETandDSPpcACV,MRKTTAG,PRDCTAG,
                                                    SALESUNITS,SALESUNITS192OZEQUCASEBASIS,
                                                    SALESUNITS192OZEQUCASEBASIS,AVERAGERETAILPRICE,pcACV,
                                                    TOTALBASELINEUNITS,TOTALBASELINEdollars,NOPROMOPRICE,ANYFETWODSPpcACV,ANYDSPWOFETpcACV,ANYFETandDSPpcACV,
                                                    PRICEDECRUNITS,PRICEDECRPRICE,PRICEDECRpcACV,ANYFTDISCUMpcAC,PreSuperBowl,SuperBowl,PreMemorialDay,
                                                    MemorialDay,PreLabour,LabourDay,PreThanksGiving,ThanksGiving,PreEaster,Easter,seasindex,
                                                    independence_prev_wk_sp,independence_curr_wk_sp,christmas_prev_wk_sp,christmas_curr_wk_sp,newyear_curr_wk_sp,
                                                    WeekendingDate,WeekNumber))
  
  dataset1Tab <- as.data.table(prdMktLevelModelDataWithDatMas)
  #Calculating Discount
  n2<-c(n2)
  lags <- dataset1Tab[, shift(AVERAGERETAILPRICE, n = n2)]
  prdMktLevelModelDataWithDatMas$RegularPrice <- apply(lags, 1, max, na.rm=TRUE)
  prdMktLevelModelDataWithDatMas$Discount <- ((prdMktLevelModelDataWithDatMas$RegularPrice-prdMktLevelModelDataWithDatMas$AVERAGERETAILPRICE)/prdMktLevelModelDataWithDatMas$RegularPrice)* 100
  prdMktLevelModelDataWithDatMas$Discount[prdMktLevelModelDataWithDatMas$Discount <= 5] <- 0 
  prdMktLevelModelDataWithDatMas$Discount[prdMktLevelModelDataWithDatMas$Discount == 'NA'] <- 0
  
  modelAttribsList<-c("ANYFEATUREpcACV","ANYDISPLAYpcACV","ANYFETandDSPpcACV","Discount","RegularPrice",
                      "PreSuperBowl","SuperBowl","PreMemorialDay","MemorialDay","PreLabour","LabourDay",
                      "PreThanksGiving","ThanksGiving","PreEaster","Easter","seasindex","independence_prev_wk_sp",
                      "independence_curr_wk_sp","christmas_prev_wk_sp","christmas_curr_wk_sp","newyear_curr_wk_sp") 
  
  respVarName<-c("SALESUNITS")
  frmla <- as.formula(paste(respVarName, paste(modelAttribsList, sep = "", collapse = " + "), sep = " ~ ")) 
  
  
  attribsListForExp<-c("PRDCTAG","MRKTTAG","WeekendingDate","ANYFEATUREpcACV","ANYDISPLAYpcACV","ANYFETandDSPpcACV","Discount","RegularPrice",
                       "PreSuperBowl","SuperBowl","PreMemorialDay","MemorialDay","PreLabour","LabourDay",
                       "PreThanksGiving","ThanksGiving","PreEaster","Easter","seasindex","independence_prev_wk_sp",
                       "independence_curr_wk_sp","christmas_prev_wk_sp","christmas_curr_wk_sp","newyear_curr_wk_sp")
  
  #TRAIN DATA 
  rowStrtIdx <- 9
  rowEndIdx<-nrow(prdMktLevelModelDataWithDatMas)-13 
  prdMktLevelTRAINData <-prdMktLevelModelDataWithDatMas[rowStrtIdx:rowEndIdx,] 
  #EXTERNAL DATA
  rowStrtIdx<-nrow(prdMktLevelModelDataWithDatMas)-12
  rowEndIdx<-nrow(prdMktLevelModelDataWithDatMas) 
  prdMktLevelValDataExt<-prdMktLevelModelDataWithDatMas[rowStrtIdx:rowEndIdx,] 
  
  #Fitting Train data        
  fitmod <- lm(frmla, prdMktLevelTRAINData)
  summary(fitmod)
  
  actualsTrain <- prdMktLevelTRAINData$SALESUNITS
  fittedTrain <- fitted(fitmod)
  actualsPredsTrain<-as.data.frame(cbind(actuals=actualsTrain,fittedvals=fittedTrain))
  head(actualsPredsTrain)
  
  trainPreds<-cbind(actualsPredsTrain, prdMktLevelTRAINData[,attribsListForExp])
  trainPreds$MAPE_error <- mape(trainPreds$actuals,trainPreds$fittedvals)
  trainPreds$noofrows<-nrow(trainPreds)
  trainPreds$external1<-FALSE
  print(paste0("b4 actualsPreds.train print.",nrow(trainPreds),"####", ncol(trainPreds)))
  dim(trainPreds)
  #head(trainPreds)
  
  #Fitting External Data
  actualsExt <- prdMktLevelValDataExt$SALESUNITS
  predsExt<-predict(fitmod, prdMktLevelValDataExt, se.fit = TRUE) 
  actualsPredsExt<-as.data.frame(cbind(actuals=actualsExt,extPredictions=predsExt$fit))
  
  # head(actualsPredsExt)
  extPreds<-cbind(actualsPredsExt, prdMktLevelValDataExt[,attribsListForExp])
  extPreds$Mean_error <-mape(extPreds$actuals,extPreds$extPredictions)
  extPreds$noofrows<-nrow(extPreds)
  extPreds$external1<-TRUE
  
  
  ##### graphics for external data external predictions
  
  print(paste0("b4 actualsPreds.external print.",nrow(extPreds), "####", ncol(extPreds)))
  dim(extPreds)
  #head(extPreds)
  
  #./src/AllMarketsData_0322.csv
  trainFileName<-paste0("./src/",marketId,"_",productId,"_train",".csv")
  extFileName<-paste0("./src/",marketId,"_",productId,"_external",".csv")
  write.csv(trainPreds, file = trainFileName, fileEncoding = "UTF-16LE")
  write.csv(extPreds, file = extFileName, fileEncoding = "UTF-16LE")
  
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