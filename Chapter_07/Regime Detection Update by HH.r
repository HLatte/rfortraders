# Regime Detection Update
# último exemplo 
# OBS: gráficos não funcionam
#
# https://systematicinvestor.github.io/Regime-Detection-Update

load.packages('quantmod')
load.packages('depmixS4')
###############################################################################
# Load Systematic Investor Toolbox (SIT)
# https://github.com/systematicinvestor/SIT
# instalação: https://systematicinvestor.github.io/about/
###############################################################################
library(SIT)


#*****************************************************************
# Load historical prices
#****************************************************************** 
data = env()
getSymbols('SPY', src = 'yahoo', from = '1970-01-01', env = data, auto.assign = T)

price = Cl(data$SPY)
open = Op(data$SPY)
ret = diff(log(price))
ret = log(price) - log(open)

atr = ATR(HLC(data$SPY))[,'atr']



#*****************************************************************
# Construct and fit a regime switching model
#****************************************************************** 
load.packages('depmixS4')

index = 14:nrow(price)
temp = data.frame(ret=as.vector(ret), atr=as.vector(atr))
temp = temp[index,]

# We're setting the LogReturns and ATR as our response variables, 
# want to set 4 different regimes, and setting the response distributions to be gaussian.
mod = depmix(list(ret~1, atr~1),data=temp,nstates=4,family=list(gaussian(),gaussian())) 
fm2 = fit(mod, verbose = FALSE)

print(summary(fm2))

probs = posterior(fm2)

print(head(probs))

layout(1:3)
plota(ret, type='h', col='blue')
plota.legend('S&P 500 Daily Log Returns', 'blue')
plota(atr, type='l', col='darkgreen')
plota.legend('Daily ATR(14)', 'darkgreen')

temp = NA * price
temp[index] = probs$state
plota(temp, type='l', col='darkred')
plota.legend('Market Regimes', 'darkred')

layout(1:4)
for(i in 2:5) {
  temp = NA * price
  temp[index] = probs[,i]
  plota(temp, type='l', col=i)
  plota.legend(paste('Market Regime', colnames(probs)[i]), i)
}


