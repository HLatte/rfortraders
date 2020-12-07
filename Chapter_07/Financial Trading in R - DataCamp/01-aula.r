# Script do curso Financial Trading in R
# 
# https://learn.datacamp.com/courses/financial-trading-in-r
#


#### Understanding initialization settings - I ####
#
# Define boilerplate code
#
# Let's get started with creating our first strategy in quantstrat. In this
# exercise, you will need to fill in three dates:
#
# An initialization date for your backtest. The start of your data. The end of
# your data.
#
# The initialization date must always come before the start of the data,
# otherwise there will be serious errors in the output of your backtest.
#
# You should also specify what time zone and currency you will be working with
# with the functions Sys.setenv() and currency(), respectively. An example is
# here:
#
# Sys.setenv(TZ = "Europe/London") currency("EUR")
#
# For the rest of this course, you'll use UTC (Coordinated Universal Time) and
# USD (United States Dollars) for your portfolio settings.
#
#
# Use the library() command to load the quantstrat package. Set initdate as
# January 1, 1999, from as January 1, 2003, and to as December 31, 2015. Set a
# timezone of "UTC" using Sys.setenv(). Set a currency of "USD" using
# currency().

# Load the quantstrat package
library("quantstrat")

# Create initdate, from, and to strings
initdate <- "1999-01-01"
from <- "2003-01-01"
to <- "2015-12-31"

# Set the timezone to UTC
Sys.setenv(TZ = "UTC")

# Set the currency to USD 
currency("USD")


#### Understanding initialization settings - II ####
#
# Like in the previous chapter, you will use getSymbols() to obtain the SPY data
# from Yahoo! Finance.
#
# After importing the data, use stock() to tell quantstrat what instruments will
# be present for the simulation, and to treat them just as they are, as opposed
# to creating a minimum buy size, as with futures. Furthermore, this command
# specifies which currency to use with the given instruments. Note that whenever
# you use a function to initialize a data set such as GDX or SPY, you must
# enclose it in quotation marks:
#
# stock("GDX", currency = "USD")
#
# The quanstrat package has been loaded into your workspace, as well as the from
# and to date strings that you created in the previous exercise.

# Use the library() command to load the quantmod package. Use getSymbols() to
# get adjusted data from SPY from Yahoo! Finance between the from and to dates.
# Use the stock() command to let quantstrat know you will be using the SPY data
# in your strategy and set its currency to "USD".

# Load the quantmod package
library("quantmod")
source("IKTrading-extract.r")

# Retrieve SPY from yahoo
getSymbols(Symbols = "SPY", 
           src = "yahoo", 
           index.class = "POSIXct",
           from = from, 
           to = to, 
           adjust = TRUE,
           auto.assign = TRUE)

# Use stock() to initialize SPY and set currency to USD
stock("SPY", 
      currency = "USD", 
      multiplier = 1)


#### Understanding initialization settings - III ####
#
# Let's continue the setup of your strategy. First, you will set a trade size of
# 100,000 USD in an object called tradesize which determines the amount you
# wager on each trade. Second, you will set your initial equity to 100,000 USD
# in an object called initeq.
#
# Quantstrat requires three different objects to work: an account, a portfolio,
# and a strategy. An account is comprised of portfolios, and a portfolio is
# comprised of strategies. For your first strategy, there will only be one
# account, one portfolio, and one strategy. Let's call them "firststrat" for
# "first strategy".
#
# Finally, before proceeding, you must remove any existing strategies using the
# strategy removal command rm.strat() which takes in a string of the name of a
# strategy.
#
# The quantstrat and quantmod packages have been loaded for you.

# Define both tradesize and initeq as integer objects representing $100,000. Set
# strategy.st, portfolio.st, and account.st to "firststrat". Remove the existing
# strategy strategy.st using rm.strat().

# Define your trade size and initial equity
tradesize <- 100000
initeq <- 100000

# Define the names of your strategy, portfolio and account
strategy.st <- portfolio.st <- account.st <- "firststrat"

# Remove the existing strategy if it exists
rm.strat(strategy.st)




#### Understanding initialization settings - IV ####
#
# Now that everything has been named, you must initialize the portfolio, the
# account, the orders, and the strategy to produce results.
#
# The portfolio initialization initPortf() needs a portfolio string name, a
# vector for symbols used in the backtest, an initialization date initDate, and
# a currency. The account initialization call initAcct() is identical to the
# portfolio initialization call except it takes an account string name instead
# of a new portfolio name, an existing portfolios name, and an initial equity
# initEq. The orders initialization initOrders() needs a portfolio string
# portfolio and an initialization date initDate. The strategy initialization
# strategy() needs a name of this new strategy and must have store set to TRUE.
#
# The initdate and initeq objects that you created in previous exercises have
# been loaded for you, as well as the quantstrat and quantmod packages.

# Use initPortf() to initialize the portfolio called portfolio.st with "SPY",
# initdate, and "USD" as the arguments. Use initAcct() to initialize the account
# called account.st with portfolio.st, initdate, "USD", and initeq as the
# arguments. Use initOrders() to initialize orders called portfolio.st and
# initdate as the arguments. Use strategy() to store a strategy called
# strategy.st with store = TRUE as the arguments.

# by HH: remove antes de criar de novo. Se não mudar para
rm.strat(portfolio.st) # para evitar o erro: "Portfolio firststrat already exists, use updatePortf() or addPortfInstr() to update it."
rm.strat(account.st) # para evitar o erro: "Account firststrat already exists, use updateAcct() or create a new account."

# Initialize the portfolio
initPortf(portfolio.st, symbols = "SPY", initDate = initdate, currency = "USD")

# Initialize the account
initAcct(account.st, portfolios = portfolio.st, initDate = initdate, currency = "USD", initEq = initeq)

# Initialize the orders
initOrders( portfolio.st, initDate = initdate)

# Store the strategy
strategy( strategy.st, store = TRUE)




# The SMA and RSI functions
#
# Welcome to the chapter on indicators! An indicator is a transformation of
# market data that is used to generate signals or filter noise. Indicators form
# the backbone of many trading systems, and the system you will build in this
# course uses several of them.
#
# The simple moving average (SMA) and relative strength index (RSI) are two
# classic indicators. As you saw in Chapter 1, the SMA is an arithmetic moving
# average of past prices, while the RSI is a bounded oscillating indicator that
# ranges from 0 to 100. Their respective functions SMA() and RSI() both take in
# a series of prices, denoted by x and price respectively, and a lookback period
# n, for example:
#
# SMA(x = Cl(GDX), n = 50) RSI(price = Cl(GDX), n = 50)
#
# In this exercise, you will practice calling the base functions for these
# indicators. The quantmod and TTR packages and SPY data have been loaded for
# you.


# Create a 200-day SMA of the closing price of SPY. Call this spy_sma. Create an
# RSI with a lookback period n of 3 days using the closing price of SPY. Call
# this spy_rsi.

# Create a 200-day SMA
spy_sma <- SMA(x = Cl(SPY), n = 200)

# Create an RSI with a 3-day lookback period
spy_rsi <- RSI(price = Cl(SPY), n = 3)




# Visualize an indicator and guess its purpose - I
#
# Now you will visualize these indicators to understand why you might want to
# use the indicator and what it may represent. Recall that a trend indicator
# attempts to predict whether a price will continue in its current direction,
# whereas a reversion indicator attempts to predict whether an increasing price
# will soon decrease, or the opposite.
#
# In this exercise, you will revisit the 200-day SMA. As a refresher, this
# indicator attempts to smooth out prices, but comes with a tradeoff - a lag.
# You will plot the prices of SPY and plot a 200-day SMA on top of the price
# series. Using this information, you will determine if it is a trend indicator
# or reversion indicator.
#
# The quantmod and TTR packages and price series SPY have been loaded into your
# workspace.


# Plot the closing prices of SPY. Overlay a 200-day SMA of the closing prices
# using the lines() function and color it red. Is the 200-day SMA a trend or a
# reversion indicator? Print your answer as either "trend" or "reversion" in the
# console.

#library("TTR")

# Plot the closing prices of SPY
hh <- plot( Cl(SPY))

# Overlay a 200-day SMA
lines( SMA( Cl(SPY), n = 200), col = "red")

print(hh)

# What kind of indicator?
print("trend")



# Visualize an indicator and guess its purpose - II
#
# The Relative Strength Index (RSI) is another indicator that rises with
# positive price changes and falls with negative price changes. It is equal to
# 100 - 100/(1 + RS), where RS is the average gain over average loss over the
# lookback period. At various lengths, this indicator can range from a reversion
# indicator, to a trend filter, or anywhere in between. There are various ways
# of computing the RSI.
#
# As you already know, RSI() takes in a price series price and a number of
# periods n which has a default value of 14. Some traders believe that the
# 2-period RSI, also known as the RSI 2, has even more important properties than
# the 14-period RSI.
#
# In this exercise, rather than plotting this indicator on the actual price
# series, you'll look at a small, one year subset of SPY and how the RSI
# interacts with the price. The quantmod and TTR packages and SPY price series
# have been loaded into your workspace.


# Plot the closing price of SPY. Plot the RSI 2 of the closing price of SPY. Is
# this a trend or a reversion indicator? Print your answer as either "trend" or
# "reversion" in the console.

# Plot the closing price of SPY
# repeitdo by HH: plot( Cl(SPY))

# Plot the RSI 2
hh <- plot( RSI( Cl(SPY), n = 2))
print(hh)

# What kind of indicator?
print("reversion")




# Implementing an indicator - I
#
# At this point, it's time to start getting into the mechanics of implementing
# an indicator within the scope of the quantstrat library. In this exercise you
# will learn how to add an indicator to your strategy. For this exercise you
# will use the strategy you created in earlier exercises, strategy.st. For your
# first indicator, you will add a 200-day simple moving average.
#
# To add an indicator to your strategy, you will use the add.indicator(). Set
# strategy equal to the name of your strategy, name to the name of a function in
# quotes, and arguments to the arguments of the named function in the form of a
# list. For instance, if your function name was SMA, the arguments argument will
# contain the arguments to the SMA function:
#
# add.indicator(strategy = strategy.st, 
#               name = "SMA", 
#               arguments = list(x =quote(Cl(mktdata)), n = 500),
#               label = "SMA500")
#
# When referencing dynamic market data in your add.indicator() call, include
# mktdata inside the quote() function because it is created inside quantstrat
# and will change depending on whichever instrument the package is using at the
# time. quote() ensures that the data can dynamically change over the course of
# running your strategy.
#
# In this exercise, you will add a 200-day SMA to your existing strategy
# strategy.st. The quantstrat and quantmod packages are also loaded for you.


# Use add.indicator() on your existing strategy strategy.st. Follow the example
# code closely. Provide the SMA function as the name argument. Specify the
# desired arguments of SMA, using the closing price of mktdata and a lookback
# period n of 200 days. Label your indicator "SMA200".

# Add a 200-day SMA indicator to strategy.st
add.indicator(strategy = strategy.st, 
              
              # Add the SMA function
              name = "SMA", 
              
              # Create a lookback period
              arguments = list(x = quote(Cl(mktdata)), n = 200), 
              
              # Label your indicator SMA200
              label = "SMA200")




#Implementing an indicator - II

#Great job implementing your first indicator! Now, you'll make your strategy 
#even more robust by adding a 50-day SMA. A fast moving average with a slower
#moving average is a simple and standard way to predict when prices in an asset 
#are expected to rise in the future. While a single indicator can provide a lot 
#of information, a truly robust trading system requires multiple indicators to 
#operate effectively.

#In this exercise, you'll also add this 50-day SMA to strategy.st. The 
#quantstrat and quantmod packages are also loaded for you.


#Use add.indicator() on your existing strategy strategy.st. Follow the example 
#code in the previous exercise.
#Provide the SMA function as the name argument.
#Specify the desired arguments of SMA, using the closing price of mktdata and a 
#lookback period n of 50 days. Don't forget to use the quote function!
#    Label your new indicator "SMA50".

# Add a 50-day SMA indicator to strategy.st
add.indicator(strategy = strategy.st, 
              
              # Add the SMA function
              name = "SMA", 
              
              # Create a lookback period
              arguments = list(x = quote(Cl(mktdata)), n = 50), 
              
              # Label your indicator SMA200
              label = "SMA50")



#Implementing an indicator - III

#In financial markets, the goal is to buy low and sell high. The RSI can predict
#when a price has sufficiently pulled back, especially with a short period such 
#as 2 or 3.

#Here, you'll create a 3-period RSI, or RSI 3, to give you more practice in
#implementing pre-coded indicators. The quantstrat and quantmod packages are
#loaded for you.


# Use add.indicator() on your existing strategy strategy.st. Follow the example
# code from previous exercises. Provide the RSI function as the name argument.
# Specify the desired arguments of RSI, using the closing price of mktdata and a
# lookback period n of 3 days. Don't forget to use the quote() function! Label
# your new indicator "RSI_3".

# Add an RSI 3 indicator to strategy.st
add.indicator(strategy = strategy.st, 
              
              # Add the RSI 3 function
              name = "RSI", 
              
              # Create a lookback period
              arguments = list(price = quote(Cl(mktdata)), n = 3), 
              
              # Label your indicator RSI_3
              label = "RSI_3")



# Code your own indicator - I
#
# So far, you've used indicators that have been completely pre-written for you
# by using the add.indicator() function. Now it's time for you to write and
# apply your own indicator.
#
# Your indicator function will calculate the average of two different indicators
# to create an RSI of 3.5. Here's how:
#
# Take in a price series. Calculate RSI 3. Calculate RSI 4. Return the average
# of RSI 3 and RSI 4.
#
# This RSI can be thought of as an RSI 3.5, because it's longer than an RSI 3
# and shorter than an RSI 4. By averaging, this indicator takes into account the
# impact of four days ago while still being faster than a simple RSI 4, and also
# removes the noise of both RSI 3 and RSI 4.
#
# In this exercise, you will create a function for this indicator called
# calc_RSI_avg() and add it to your strategy strategy.st. All relevant packages
# are also loaded for you.


# Create and name a function calc_RSI_avg with three arguments price, n1, and
# n2, in that order. Compute an RSI of lookback n1 named RSI_1. Compute an RSI
# of lookback n2 named RSI_2. Calculate the average of RSI_1 and RSI_2. Call
# this RSI_avg. Set the column name of RSI_avg to RSI_avg using colnames(), and
# return RSI_avg. Add this indicator to your strategy using inputs of n1 = 3 and
# n2 = 4. Label this indicator RSI_3_4.


# Write the calc_RSI_avg function
calc_RSI_avg <- function(price, n1, n2) {
  
  # RSI 1 takes an input of the price and n1
  RSI_1 <- RSI(price = price, n = n1)
  
  # RSI 2 takes an input of the price and n2
  RSI_2 <- RSI(price = price, n = n2)
  
  # RSI_avg is the average of RSI_1 and RSI_2
  RSI_avg <- (RSI_1 + RSI_2)/2
  
  # Your output of RSI_avg needs a column name of RSI_avg
  colnames(RSI_avg) <- "RSI_avg"
  return(RSI_avg)
}

# Add this function as RSI_3_4 to your strategy with n1 = 3 and n2 = 4
add.indicator(strategy.st, name = "calc_RSI_avg", 
              arguments = list(price = quote(Cl(mktdata)), n1 = 3, n2 = 4), 
              label = "RSI_3_4")



# Code your own indicator - II
#
# While the RSI is decent, it is somewhat outdated as far as indicators go. In
# this exercise, you will code a simplified version of another indicator from
# scratch. The indicator is called the David Varadi Oscillator (DVO), originated
# by David Varadi, a quantitative research director.
#
# The purpose of this oscillator is similar to something like the RSI in that it
# attempts to find opportunities to buy a temporary dip and sell in a temporary
# uptrend. In addition to obligatory market data, an oscillator function takes
# in two lookback periods.
#
# First, the function computes a ratio between the closing price and average of
# high and low prices. Next, it applies an SMA to that quantity to smooth out
# noise, usually on a very small time frame, such as two days. Finally, it uses
# the runPercentRank() function to take a running percentage rank of this
# average ratio, and multiplies it by 100 to convert it to a 0-100 quantity.
#
# Think about the way that students get percentile scores after taking a
# standardized test (that is, if a student got an 800 on her math section, she
# might be in the 95th percentile nationally). runPercentRank() does the same
# thing, except over time. This indicator provides the rank for the latest
# observation when taken in the context over some past period that the user
# specifies. For example, if something has a runPercentRank value of .90 when
# using a lookback period of 126, it means it's in the 90th percentile when
# compared to itself and the past 125 observations.
#
# Your job is to implement this indicator and save it as DVO. Some of the
# necessary code has been provided, and the quantstrat, TTR, and quantmod
# packages are loaded into your workspace.

# Create and name a function, DVO, for the indicator described above. The three
# arguments for your function will be HLC, navg (default to 2), and
# percentlookback (default to 126). The ratio of the close (Cl()) of HLC divided
# by the average of the high (Hi()) and low (Lo()) prices is computed for you.
# Use SMA() to implement a moving average of this ratio, parameterized by the
# navg argument. Save this as avgratio. Use runPercentRank() to implement a
# percentage ranking system for avgratio.

# Declare the DVO function
DVO <- function(HLC, navg = 2, percentlookback = 126) {
  
  # Compute the ratio between closing prices to the average of high and low
  ratio <- Cl(HLC)/((Hi(HLC) + Lo(HLC))/2)
  
  # Smooth out the ratio outputs using a moving average
  avgratio <- SMA(ratio, n = navg)
  
  # Convert ratio into a 0-100 value using runPercentRank()
  out <- runPercentRank(avgratio, n = percentlookback, exact.multiplier = 1) * 100
  colnames(out) <- "DVO"
  return(out)
}

# Apply your own indicator
#
# Great job! Now you have a better understanding of indicators as functions that
# anyone can write. It's time to apply the indicator you created in the previous
# exercise. To do so, you will make use of the applyIndicators() command.
#
# From debugging to subsetting, knowing how to step inside your strategy is a
# valuable piece of knowledge. Every so often, you might have an error in your
# strategy, and will want to track it down. Knowing how to use the
# applyIndicators() command will help you identify your errors. Furthermore,
# sometimes you may want to look at a small chunk of time in your strategy. This
# exercise will help train you to do this as well.
#
# In order to subset time series data, use brackets with the start date, forward
# slash symbol, and end date. Both dates are in the same format as the from and
# to arguments for getSymbols() that you used in the first chapter. The
# quantstrat, TTR, and quantmod packages have once again been loaded for you.

# Add the DVO indicator designed in the previous exercise with the default
# parameters. Label it DVO_2_126. Using applyIndicators(), create a temporary
# object test containing the indicators that you've already applied. Use the
# open, high, low, and close of SPY as your test market data. Subset your data
# between September 1, 2013 and September 5, 2013.

# Add the DVO indicator to your strategy
add.indicator(strategy = strategy.st, name = "DVO", 
              arguments = list(HLC = quote(HLC(mktdata)), navg = 2, percentlookback = 126),
              label = "DVO_2_126")

# Use applyIndicators to test out your indicators
test <- applyIndicators(strategy = strategy.st, mktdata = OHLC(SPY))

# Subset your data between Sep. 1 and Sep. 5 of 2013
test_subset <- test["2013-09-01/2013-09-05"]
print( test_subset)




###
# Signals
###


# Signal or not? - I
#
# Welcome to the chapter on signals! A signal is an interaction of market data
# with indicators, or indicators with other indicators, which tells you whether
# you may wish to buy or sell an asset. Signals can be triggered for a variety
# of reasons. For example, a signal may be triggered by a shorter lookback
# moving average going from less than to greater than a longer lookback moving
# average. Another signal may be triggered when an oscillator goes from being
# above a certain set quantity (for example, 20) to below, and so on.
#
# In this chapter, you will see various ways in which indicators interact with
# each other. You will focus on the strategy you developed in the previous
# chapter (strategy.st). To keep thing simple, you will remove all of the RSI
# indicators and stick to the DVO (David Varadi's Oscillator) indicator you
# implemented near the end of Chapter 3.
#
# For this exercise the dataset test is preloaded in your workspace. Subset test
# between September 10th, 2010, and October 10th, 2010, using
#
# test["YYYY-MM-DD/YYYY-MM-DD"]

# Is SMA50 greater than or less than SMA200 on September 20?

#test["2010-09-10/2010-10-10"]
#ou
print( test["2010-09-20"])
# resposta é SMA50 < SMA200


# Signal or not? - II
#
# In this exercise, you will manually do a sigThreshold-type evaluation without
# yet calling the signal. Recall from the video that a sigThreshold is a signal
# threshold argument which assesses whether or not a value is above or below a
# certain static quantity. As in the previous exercise, you will be presented
# with a dataset called test that is the application of your simple moving
# averages and the DVO you implemented in Chapter Three.
#
# The dataset test is loaded in your workspace. Subset test between September
# 10th, 2010, and October 10th, 2010, using
#
# test["YYYY-MM-DD/YYYY-MM-DD"]

# Is DVO greater or smaller than 20 on September 30?

#test["2010-09-10/2010-10-10"]
#ou
print( test["2010-09-30"])
# resposta é: nao, DVO < 20




# Using sigComparison
#
# A sigComparison signal is a simple and useful way to compare two (hopefully
# related) quantities, such as two moving averages. Often, a sigComparison
# signal does not create a buy or sell signal by itself (as such a signal would
# involve buying or selling on every such day), but is most often useful as a
# filter for when another buy or sell rule should be followed.
#
# In this exercise, you will use sigComparison() to generate a signal comparison
# that specifies that the 50-day simple moving average (SMA) must be above the
# 200-day simple moving average (SMA). You will label this signal longfilter,
# because it signals that the short-term average is above the long-term average.

# add.signal relationship - by HH:
#   gt = greater than
#   lt = less than
#   eq = equal to
#   lte = less than or equal to
#   gte = greater than or equal to

# Use add.signal() to add a sigComparison specifying that SMA50 must be greater
# than SMA200. Label this signal longfilter.

# Add a sigComparison which specifies that SMA50 must be greater than SMA200, call it longfilter
add.signal(strategy.st, name = "sigComparison", 
           
           # We are interested in the relationship between the SMA50 and the SMA200
           arguments = list(columns = c("SMA50", "SMA200"), 
                            
                            # Particularly, we are interested when the SMA50 is greater than the SMA200
                            relationship = "gt"),
           
           # Label this signal longfilter
           label = "longfilter")



# Using sigCrossover
#
# While having a long filter is necessary, it is not sufficient to put on a
# trade for this strategy. However, the moment the condition does not hold, the
# strategy should not hold any position whatsoever. For this exercise, you will
# implement the opposite of the rule specified above using the sigCrossover()
# function.
#
# As opposed to sigComparison(), which will always state whether or not a
# condition holds, sigCrossover() only gives a positive the moment the signal
# first occurs, and then not again. This is useful for a signal that will be
# used to initiate a transaction, as you only want one transaction in most
# cases, rather than having transactions fire again and again.
#
# In this case, you will implement the sigCrossover() function specifying that
# the SMA50 crosses under the SMA200. You will label this signal filterexit, as
# it will exit your position when the moving average filter states that the
# environment is not conducive for the strategy to hold a position.

# Use add.signal() to add a sigCrossover specifying that the SMA50 crosses under
# the SMA200. Label this signal filterexit.

# Add a sigCrossover which specifies that the SMA50 is less than the SMA200 and label it filterexit
add.signal(strategy.st, name = "sigCrossover",
           
           # We're interested in the relationship between the SMA50 and the SMA200
           arguments = list(columns = c("SMA50", "SMA200"),
                            
                            # The relationship is that the SMA50 crosses under the SMA200
                            relationship = "lt"),
           
           # Label it filterexit
           label = "filterexit")



# Using sigThreshold - I
#
# In the next two exercises, you will focus on the sigThreshold signal. The
# sigThreshold signal is mainly used for comparing an indicator to a fixed
# number, which usually has applications for bounded oscillators, or perhaps
# rolling statistical scores (for example, for a trading strategy that might
# choose to go long when a ratio of mean to standard deviation is at -2, or vice
# versa). Whereas sigComparison and sigCrossover deal with quantities that are
# usually based off of an indicator that takes values in the same general area
# as prices, sigThreshold exists specifically to cover those situations outside
# the bounds of indicators that take values similar to prices.
#
# Furthermore, the sigThreshold() function takes the cross argument, which
# specifies whether it will function similarly to sigComparison (cross = FALSE)
# or sigCrossover (cross = TRUE), respectively. In this exercise, you will
# implement a variant of sigThreshold that functions similarly to sigComparison.
#
# Your job will be to implement a sigThreshold that checks whether or not
# DVO_2_126 is under 20. This signal will serve as one of the two switches that
# need to be "on" in order to enter into a long position in the strategy.

# add.signal argument "cross" - by HH:
#   cross = TRUE mimic sigCrossover (só qdo cruza)
#   cross = FALSE mimic sigComparisson (enquanto for verdade)

# Use add.signal() to add a sigThreshold signal specifying that the DVO_2_126
# must be under 20. Set cross equal to FALSE. Label this signal longthreshold.

# Implement a sigThreshold which specifies that DVO_2_126 must be less than 20, label it longthreshold
add.signal(strategy.st, name = "sigThreshold", 
           
           # Use the DVO_2_126 column
           arguments = list(column = "DVO_2_126", 
                            
                            # The threshold is 20
                            threshold = 20, 
                            
                            # We want the oscillator to be under this value
                            relationship = "lt", 
                            
                            # We're interested in every instance that the oscillator is less than 20
                            cross = FALSE), 
           
           # Label it longthreshold
           label = "longthreshold")


# Using sigThreshold() - II
#
# In this exercise, you will implement a signal to exit a position given a
# certain threshold value of the DVO. While there are two entry signals that are
# both necessary but neither sufficient on its own, the two exit signals (this
# one and the one you implemented in an earlier exercise) are both sufficient on
# their own (but neither necessary in the existence of the other) to exit a
# position.
#
# In this exercise, you will again use sigThreshold(), this time counting when
# the DVO_2_126 crosses above a threshold of 80. To mimic a sigCrossover signal,
# set cross equal to TRUE Label this signal thresholdexit.

# Use add.signal() to add a sigThreshold signal specifying that the DVO_2_126
# must be above 80. This time, set cross equal to TRUE. Label this signal
# thresholdexit.

# Add a sigThreshold signal to your strategy that specifies that DVO_2_126 must cross above 80 and label it thresholdexit
add.signal(strategy.st, name = "sigThreshold", 
           
           # Reference the column of DVO_2_126
           arguments = list(column = "DVO_2_126", 
                            
                            # Set a threshold of 80
                            threshold = 80, 
                            
                            # The oscillator must be greater than 80
                            relationship = "gt", 
                            
                            # We are interested only in the cross
                            cross = TRUE), 
           
           # Label it thresholdexit
           label = "thresholdexit")



# Using sigFormula()
#
# The last signal function is a bit more open-ended. The sigFormula() function
# uses string evaluation to offer immense flexibility in combining various
# indicators and signals you already added to your strategy in order to create
# composite signals. While such catch-all functionality may seem complicated at
# first, with proper signal implementation and labeling, a sigFormula signal
# turns out to be the simplest of logical programming statements encapsulated in
# some quantstrat syntactical structuring.
#
# In this exercise, you will get a taste of what the sigFormula function can do
# by stepping through the logic manually. You will need to use the
# applyIndicators() and applySignals() functions.


# Use applyIndicators() with the open, high, low, and close of SPY to generate a
# dataset object called test_init. Use applySignals() with test_init to apply
# the signals you wrote in this chapter. Save this new dataset object as test.

# Create your dataset: test
test_init <- applyIndicators(strategy.st, mktdata = OHLC(SPY))
test <- applySignals(strategy = strategy.st, mktdata = test_init)

print(head(test))



# Combining signals - I
#
# In the previous exercise, you created a dataset test containing information
# about whether longfilter is equal to 1 AND longthreshold is equal to 1.
#
# Next, you'll want to create a signal when BOTH longfilter and longthreshold
# are equal to 1. You will learn how to do just this in the next exercise. For
# now, let's inspect the data set test which was created in the previous
# exercise. This data is loaded in your workspace.
#
# Have a look at test on October 8, 2013. Are longfilter and longthreshold both
# equal to 1 on that date?

print( test["2013-10-08"])
# resposta: sim ambos igual a 1



# Combining signals - II
#
# In the previous exercise, you approximated a sigFormula signal by comparing
# the value of two other signals. In this final exercise, you will take this one
# step futher by using the sigFormula() function to generate a sigFormula
# signal.
#
# The goal of this exercise is simple. You want to enter into a position when
# both longfilter and longthreshold become true at the same time. The idea is
# this: You don't want to keep entering into a position for as long as
# conditions hold true, but you do want to hold a position when there's a
# pullback in an uptrending environment.
#
# Writing a sigFormula function is as simple as writing the argument of an "if
# statement" in base R inside the formula() function. In this case, you want to
# create a signal labeled longentry, which is true when both longfilter and
# longthreshold cross over to true at the same time.
#
# Once you complete this exercise, you will have a complete survey of how
# signals work in quantstrat!

# Use add.signal() to create a sigFormula signal is true when both longfilter
# and longthreshold are true. Set cross equal to TRUE. Label this new signal as
# longentry.

# Add a sigFormula signal to your code specifying that both longfilter and longthreshold must be TRUE, label it longentry
add.signal(strategy.st, name = "sigFormula",
           
           # Specify that longfilter and longthreshold must be TRUE
           arguments = list(formula = "longfilter & longthreshold", 
                            
                            # Specify that cross must be TRUE
                            cross = TRUE),
           
           # Label it longentry
           label = "longentry")



###
# Rules
###

# Using add.rule() to implement an exit rule
#
# Welcome to the chapter on rules! While rules in quantstrat can become very
# complex, this chapter will fill in many of the details for you to help you
# develop an understanding of the actual mechanics of rules. Rules are the final
# mechanic in the trinity of quantstrat mechanics -- indicators, signals, and
# rules. Rules are a way for you to specify exactly how you will shape your
# transaction once you decide you wish to execute on a signal.
#
# Throughout this chapter, you will continue working the strategy developed in
# earlier chapters (strategy.st). Given that there are three rules to the
# strategy (two exit rules and one entry rule), there will be a handful of
# exercises to build up some intuition of the mechanics of rules.
#
# This exercise will introduce you to the add.rule() function, which allows you
# to add customized rules to your strategy. Your strategy from earlier chapters
# (strategy.st) is preloaded in your workspace.

# Take a look at the add.rule() call in your workspace. For now, don't worry
# about the numerous arguments. Generate an exit rule using add.rule() by
# setting the type argument to exit.

# Fill in the rule's type as exit
add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "filterexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")


# Specifying sigcol in add.rule()
#
# Great job! Although the add.rule() command looks complex, each argument is
# quite simple. To understand this command, you will explore each argument
# individually.
#
# First, add.rule() takes the argument sigcol, which specifies the signal column
# in your strategy. Like signals and indicators, all rules reference a column
# already present in your strategy. Rules relies on signals, and must therefore
# reference the signal columns in your strategy.
#
# In this exercise, you will supply the add.rule() call with the sigcol value,
# which will be set to filterexit (to reference the filterexit signal you
# created in the previous chapter). Specifically, the filterexit signal refers
# to the condition that the 50 day SMA has crossed under the 200 day SMA in your
# strategy. By creating a rule for this signal, you will be indicating that you
# wish to exit in this condition, as the market environment is no longer
# conducive to your position.
#
# As before, strategy.st is preloaded in your workspace.

# Once again, take a look at the add.rule() command in your workspace. Create an
# exit rule based on filterexit by specifying sigcol.

# Fill in the sigcol argument in add.rule()
add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "filterexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")


# Specifying sigval in add.rule()
#
# Now that you've specified the column containing the relevant signal in your
# strategy, the next argument to specify in add.rule() is sigval, or the value
# that your signal should take to trigger the rule.
#
# Remember that all signal outputs are either 1s or 0s. Effectively, a signal is
# either "on" or "off" at any given time. For our purposes, this is equivalent
# to two possible logical values: TRUE or FALSE. When specifying sigval in your
# add.rule() command, you need to indicate whether the rule is triggered when
# the signal value is TRUE or FALSE.
#
# To proceed with the new exit rule in your strategy, you will want to specify
# that a transaction should occcur when filterexit is equal to TRUE. The
# add.rule() command from your previous exercise is available in your workspace.

#Set the sigval argument in add.rule() equal to TRUE.

# Fill in the sigval argument in add.rule()
add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "filterexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")


# Specifying orderqty in add.rule()
#
# Now that you have a grasp of the first set of arguments in the add.rule()
# function, it's time to move on to the more important arguments: the actual
# order being bought or sold! The orderqty argument in the ruleSignal specifies
# exactly how much of an asset you want to buy or sell, in numbers of shares.
#
# However, one salient feature of the exit rule type is that you can reduce your
# position to zero instantly with the all argument (hence, exiting). This is the
# mechanism we will implement in this exercise.

# The add.rule() command from the previous exercise has been loaded into your
# workspace. Specify that you'd like to reduce your position to zero by filling
# in the orderqty argument.

# Fill in the orderqty argument in add.rule()
add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "filterexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")


# Specifying ordertype in add.rule()
#
# To this point you've specified the signal column, signal value, and order
# quantity associated with your rule. Next you will specify the type of order
# you will execute (ordertype).
#
# While there are multiple types of orders in quantstrat, for the scope of this
# course you will stick to market orders (ordertype = "market"). A market order
# is an order that states that you will buy or sell the asset at the prevailing
# price, regardless of the conditions in the market. An alternative type of
# orders is a limit order, which specifies that the transaction will only take
# place if certain price conditions are met (namely, if the price falls below a
# certain further threshold on the day of the order). The mechanics of limit
# orders are outside the scope of this course.

# The add.rule() command from the previous exercise has been loaded into your
# workspace. Define your order as a market order by specifying the ordertype
# argument.

# Fill in the ordertype argument in add.rule()
add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "filterexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")

# Specifying orderside in add.rule()
#
# The next critical argument to specify in your order is orderside, which can
# take two values: either long or short. In quantstrat, long and short side
# trades are siloed off separately so that quantstrat knows whether a trade is a
# long trade or a short trade. A long trade is one that profits by buying an
# asset in the hopes that the asset's price will rise. A short trade is one that
# sells an asset before owning it, hoping to buy it back later at a lower price.
#
# For your strategy, you will want to take only long orders.

# The add.rule() command from the previous exercise has been loaded into your
# workspace. Define your order side as long by specifying the orderside
# argument.

# Fill in the orderside argument in add.rule()
add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "filterexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")



# Specifying replace in add.rule()
#
# In quantstrat, the replace argument specifies whether or not to ignore all
# other signals on the same date when the strategy acts upon one signal. This is
# generally not a desired quality in a well-crafted trading system. Therefore,
# for your exit rule, you should set replace to FALSE.
#
# Furthermore, you will be working with a new rule. Previously, the exit rule
# you worked with was when the market environment was no longer conducive to a
# trade. In this case, you will be working with a rule that sells when the DVO
# has crossed a certain threshold. In particular, you will be working with the
# thresholdexit rule now.

#Set the replace input inside the arguments input to FALSE.

# Fill in the replace argument in add.rule()
add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "thresholdexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")


# Specifying prefer in add.rule()
#
# Lastly, of the basic rule arguments, there is the aspect of the prefer
# argument. In quantstrat, orders have a "next-bar" mechanism. That is, if you
# would gain a signal on Tuesday, the earliest that a position would actually
# fulfil itself would be on the Wednesday after. However, this can be solved by
# placing orders to execute on the next possible opening price, rather than wait
# for an entire day to pass before being able to actually purchase/sell the
# asset.

#Set the prefer argument to "Open".

# Fill in the prefer argument in add.rule()
add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "thresholdexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")


# Using add.rule() to implement an entry rule
#
# Excellent! You've mastered every element of the rule building process in
# quantstrat. While thus far you've added rules step-by-step, now it's time to
# put it all together and see how well you've been able to absorb the material
# in this chapter.
#
# The opposite of an exit rule is an enter rule. On enter rules, orderqty cannot
# be set to "all" because there is no initial position on which to act. In this
# exercise, you will implement an enter rule that references the longentry
# signal in your strategy and will buy one share of an asset.

# Specify the arguments in add.rule() to implement your new enter rule.
# Your rule should be triggered when the longentry signal is equal to TRUE.
# Your rule should buy 1 share of an asset as a "market" order.
# Your rule side should be long and replace should be FALSE.
# Your rule should buy on the next day's Open after observing a signal.

# Create an entry rule of 1 share when all conditions line up to enter into a position
add.rule(strategy.st, name = "ruleSignal", 
         # Use the longentry column as the sigcol
         arguments=list(sigcol = "longentry", 
                        # Set sigval to TRUE
                        sigval = TRUE, 
                        # Set orderqty to 1
                        orderqty = 1,
                        # Use a market type of order
                        ordertype = "market",
                        # Take the long orderside
                        orderside = "long",
                        # Do not replace other signals
                        replace = FALSE, 
                        # Buy at the next day's opening price
                        prefer = "Open"),
         # This is an enter type rule, not an exit
         type = "enter")



# Implementing a rule with an order sizing function
#
# In quantstrat, the amount of an asset transacted may not always be a fixed
# quantity in regards to the actual shares. The constructs that allow quantstrat
# to vary the amount of shares bought or sold are called order sizing functions.
# Due to the extensive additional syntax in creating a proper order sizing
# function, coding your own order sizing function from scratch is outside the
# scope of this course.
#
# However, using a pre-coded order sizing function is straightforward. The first
# thing to know is that when using an order sizing function, the orderqty
# argument is no longer relevant, as the order quantity is determined by the
# order sizing function. Calling an order sizing function with your add.rule()
# call is fairly straightforward. The inputs for the order sizing function are
# mixed in with the rest of the inputs inside the arguments that you have been
# working with throughout this chapter.
#
# In this exercise, you will use the osFUN argument to specify a function called
# osMaxDollar. This is not passed in as a string, but rather as an object. The
# only difference is that the name of the order sizing function is not encased
# in quotes.
#
# The additional arguments to this function are tradeSize and maxSize, both of
# which should take tradesize, which you defined several chapters earlier. This
# has been made available in your workspace.

# The add.rule() command used in previous exercises is printed in your workspace.
# Add an order sizing function to this rule by specifying osFUN, tradeSize, and 
#maxSize.

# by HH
#osMaxDollar vem do pacote IKTrading que não tem mais no CRAN
# então a funcao esta copianda no arquivo IKTrading-extract.r



# Add a rule that uses an osFUN to size an entry position
add.rule(strategy = strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "longentry", sigval = TRUE, ordertype = "market",
                          orderside = "long", replace = FALSE, prefer = "Open",
                          
                          # Use the osFUN called osMaxDollar
                          osFUN = osMaxDollar,
                          
                          # The tradeSize argument should be equal to tradesize (defined earlier)
                          tradeSize = tradesize,
                          
                          # The maxSize argument should be equal to tradesize as well
                          maxSize = tradesize),
         type = "enter")




#### 
#
####
# Running your strategy ####
#
# Congratulations on creating a strategy in quantstrat! To review, your strategy
# uses three separate indicators and five separate signals. The strategy
# requires both the threshold of the DVO_2_126 indicator to be under 20 and the
# SMA50 to be greater than the SMA200. The strategy sells when the DVO_2_126
# crosses above 80, or the SMA50 crosses under the SMA200.
#
# For this strategy to work properly, you specified five separate signals:
#
# sigComparison for SMA50 being greater than SMA200; sigThreshold with cross set
# to FALSE for DVO_2_126 less than 20; sigFormula to tie them together and set
# cross to TRUE; sigCrossover with SMA50 less than SMA200; and sigThreshold with
# cross set to TRUE for DVO_2_126 greater than 80.
#
# The strategy invests $100,000 (your initeq) into each trade, and may have some
# small dollar cost averaging if the DVO_2_126 oscillates around 20 (though the
# effect is mostly negligible compared to the initial allocation).
#
# In this final chapter, you will learn how to view the actual results of your
# portfolio. But first, in order to generate the results, you need to run your
# strategy and fill in some more boilerplate code to make sure quantstrat
# records everything. The code in this exercise is code you will have to copy
# and paste in the future.

# Use applyStrategy() to apply your strategy (strategy.st) to your portfolio 
#(portfolio.st). Save this to the object out.
# Run necessary functions to record the results of your strategy, including 
#updatePortf() and setting the daterange as well as updateAcct() and updateEndEq().
# Based on this information, see if you can find the date of the last trade.

# Use applyStrategy() to apply your strategy. Save this to out
out <- applyStrategy(strategy = strategy.st, portfolios = portfolio.st)

# Update your portfolio (portfolio.st)
updatePortf(portfolio.st)
daterange <- time(getPortfolio(portfolio.st)$summary)[-1]

# Update your account (account.st)
updateAcct(account.st, daterange)
updateEndEq(account.st)



# Profit factor
#
# One of the most vital statistics of any systematic trading strategy is the
# profit factor. The profit factor is how many dollars you make for each dollar
# you lose. A profit factor above 1 means your strategy is profitable. A profit
# factor below 1 means you should head back to the drawing board.
#
# In this exercise, you will explore the profit factor in your strategy by
# creating an object called tstats that displays the trade statistics for your
# system. In general, trade statistics are generated by using the tradeStats()
# command.

# Use tradeStats() to create an object containing the trade statistics in your
# portfolio. Save this as tstats.
#
# Use the object tstats object along with $ and Profit.Factor to report the
# profit factor for SPY. Is your strategy profitable?
  
# Get the tradeStats for your portfolio
tstats <- tradeStats(Portfolios = portfolio.st)

# Print the profit factor
print( tstats$Profit.Factor)


# Percent positive
#
# While profit factor is one important statistic, it may be heavily influenced
# by only a few good trades. The percent positive statistic lets you know how
# many of your trades were winners. A trading system based on oscillation
# trading (such as yours!) will likely have a high percentage of winners. This
# is certainly a statistic you should look for in your own trade statistics.
#
# The trading statistics object you created in the last exercise (tstats) has
# been preloaded into your workspace. Examine it. What is the percent positive
# statistic?
print( tstats$Percent.Positive)
# resposta 70.9



###
# Using chart.Posn() ####
#
# One of the most enlightening things about a trading system is exploring what
# positions it took over the course of the trading simulation, as well as when
# it had its profits and drawdowns. Looking at a picture of the performance can
# deliver a great deal of insight in terms of refining similar trading systems
# in the future.
#
# In this exercise, you will use the chart.Posn() function. This generates a
# crisp and informative visualization of the performance of your trading system
# over the course of the simulation.
#
# Your portfolio strategy (portfolio.st) is preloaded into your environment.

# Use chart.Posn() to view your trading system's performance over the course of
# the simulation for SPY.

# Use chart.Posn to view your system's performance on SPY
hh<-chart.Posn(Portfolio = portfolio.st, Symbol = "SPY")
print(hh)


# Adding an indicator to a chart.Posn() chart
#
# One of the more interesting things you can do with the chart.Posn() function
# is to superimpose indicators on top of it. This can help show what the
# strategy has actually been doing and why. However, in order to do this, you
# will need to recalculate the indicators outside the scope of your strategy.
# Once this is done, you simply add them to the chart.Posn plot.
#
# In this exercise, you will add the three indicators from your strategy to the
# chart.Posn plot you just created. The two moving averages (SMA50 and SMA200)
# will be superimposed on the price series, while the DVO_2_126 will have its
# own window.


# Begin by reproducing your SMA50, SMA200, and DVO_2_126 indicators for SPY 
#outside of the strategy.
# Recreate the chart from the previous exercise using chart.Posn().
# Use add_TA() to overlay the SMA50 as a blue line on top of the price plot.
# Use add_TA() to overlay the SMA200 as a red line on top of the price plot.
# Use add_TA() to add the DVO_2_126 to your plot as a new window.

# Compute the SMA50
sma50 <- SMA(x = Cl(SPY), n = 50)

# Compute the SMA200
sma200 <- SMA(x = Cl(SPY), n = 200)

# Compute the DVO_2_126 with an navg of 2 and a percentlookback of 126
dvo <- DVO(HLC = HLC(SPY), navg = 2, percentlookback = 126)

# Recreate the chart.Posn of the strategy from the previous exercise
chart.Posn(Portfolio = portfolio.st, Symbol = "SPY")

# Overlay the SMA50 on your plot as a blue line
add_TA(sma50, on = 1, col = "blue")

# Overlay the SMA200 on your plot as a red line
add_TA(sma200, on = 1, col = "red")

# Add the DVO_2_126 to the plot in a new window
hh <- add_TA(dvo)

print(hh)






# Cash Sharpe ratio
#
# When working with cash profit and loss statistics, quantstrat offers a way to
# compute a Sharpe ratio not just from returns, but from the actual profit and
# loss statistics themselves. A Sharpe ratio is a metric that compares the
# average reward to the average risk taken. Generally, a Sharpe ratio above 1 is
# a marker of a strong strategy.
#
# In this exercise, you will see that because of trading P&L (profit and loss),
# one can compute a Sharpe ratio based on these metrics. The code below can be
# used to compute the Sharpe ratio based off of P&L. Copy the code in the
# console. In what range is the Sharpe ratio you obtain?
#
# portpl <- .blotter$portfolio.firststrat$summary$Net.Trading.PL
# SharpeRatio.annualized(portpl, geometric=FALSE)

portpl <- .blotter$portfolio.firststrat$summary$Net.Trading.PL
print( SharpeRatio.annualized(portpl, geometric=FALSE))


# Returns Sharpe ratio in quantstrat
#
# One of the main reasons to include an initial equity (in this case, initeq,
# which is set to 100,000) in your strategy is to be able to work with returns,
# which are based off of your profit and loss over your initial equity.
#
# While you just computed a cash Sharpe ratio in the previous exercise, you will
# see in this exercise that quantstrat can also compute the standard
# returns-based Sharpe ratio as well.

# Use PortfReturns() on our portfolio strategy portfolio.st to get the
#instrument returns. 
# Compute the annualized Sharpe ratio using the instrument returns computed in
#the previous step.

# Get instrument returns
instrets <- PortfReturns(portfolio.st)

# Compute Sharpe ratio from returns
print( SharpeRatio.annualized(instrets, geometric = FALSE))


