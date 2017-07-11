# Map 1-based optional input ports to variables
dataset1 <- maml.mapInputPort(1) # class: data.frame
dataset2 <- maml.mapInputPort(2) # class: data.frame

data.set = rbind(dataset1, dataset2);
data.set$error<-data.set$MASE_error
# Select data.frame to be sent to the output Dataset port
maml.mapOutputPort("data.set")