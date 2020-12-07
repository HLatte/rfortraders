# Identifying Changing Market Conditions - Hidden Markov Models
# 
# https://inovancetech.com/hmm-tutorial-1.html
#

#install.packages("depmixS4")
library("depmixS4") #the HMM library we'll use 

#install.packages("quantmod")
library("quantmod") #a great library for technical analysis and working with time series 

# by HH
EURUSD1d <- read.csv("EURUSD1d.csv")

# Load out data set, then turn it into a time series object. 
Date<-as.character(EURUSD1d[,1])
DateTS<- as.POSIXlt(Date, format = "%Y.%m.%d %H:%M:%S") #create date and time objects
TSData<-data.frame(EURUSD1d[,2:5],row.names=DateTS)
TSData<-as.xts(TSData) #build our time series data set 

# some indicators
ATRindicator<-ATR(TSData[,2:4],n=14) #calculate the indicator
ATR<-ATRindicator[,2] #grab just the ATR 
LogReturns <- log(TSData$Close) - log(TSData$Open) #calculate the logarithmic returns

# model
ModelData <- data.frame(LogReturns,ATR) #create the data frame for our HMM model
ModelData <- ModelData[-c(1:14),] #remove the data where the indicators are being calculated
colnames(ModelData)<-c("LogReturns","ATR") #name our columns 

# Build the model
set.seed(1)
# We’re setting the LogReturns and ATR as our response variables, using the data 
#frame we just built, want to set 3 different regimes, and setting the response 
#distributions to be gaussian. 
HMM<-depmix(list(LogReturns~1,ATR~1),data=ModelData,nstates=3,
            family=list(gaussian(),gaussian())) 
#fit our model to the data set 
HMMfit<-fit(HMM, verbose = FALSE) 
#we can compare the log Likelihood as well as the AIC and BIC values to help choose our model 
print(HMMfit) 
summary(HMMfit) 

#find the posterior odds for each state over our data set
HMMpost<-posterior(HMMfit) 
# we can see that we now have the probability for each state for everyday as well
#as the highest probability class. 
head(HMMpost) 

# Plot the returns stream and the posterior
# probabilities of the separate regimes
layout(1:3)
plot(LogReturns, type='l', main='Regime Detection', xlab='', ylab='Log Returns')
plot(ATR, type='l', main='', xlab='', ylab='ATR')
plot(HMMpost$state, type='s', main='', xlab='', ylab='Implied States')
# Alternativa by HH
#matplot(HMMpost$state, type='s', main='', ylab='Implied States')
#legend(x='bottomleft', c('Regime #1','Regime #2', 'Regime #3'), fill=1:3, bty='n')

layout(1:3)
matplot(HMMpost[,2], type='l', main='Regime Posterior Probabilities', ylab='Probability')
legend(x='bottomleft', c('Regime #1'), fill=1, bty='n')
matplot(HMMpost[,3], type='l', main='Regime Posterior Probabilities', ylab='Probability')
legend(x='bottomleft', c('Regime #2'), fill=1, bty='n')
matplot(HMMpost[,4], type='l', main='Regime Posterior Probabilities', ylab='Probability')
legend(x='bottomleft', c('Regime #3'), fill=1, bty='n')



