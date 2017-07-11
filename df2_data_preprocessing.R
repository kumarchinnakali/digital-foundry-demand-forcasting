# Map 1-based optional input ports to variables
inputShpmtData <- maml.mapInputPort(1)
# Contents of optional Zip port are in ./src/
# source("src/yourfile.R");
# load("src/yourData.rdata");
len <- colSums( sapply( inputShpmtData , grepl , pattern = "^\\s*$" ) )    
inputShpmtData[ , len > 0 ] <- rep( 0 , nrow(inputShpmtData) )

inputShpmtData <- replace(inputShpmtData, is.na(inputShpmtData), 0)
maml.mapOutputPort("inputShpmtData")