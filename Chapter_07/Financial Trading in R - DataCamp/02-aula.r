# Script do curso Introduction to Portfolio Analysis in R
#  que usa o pacote PortfolioAnalistics
#
# https://learn.datacamp.com/courses/introduction-to-portfolio-analysis-in-r
#

#by HH
require("PerformanceAnalytics")
library("quantmod")
# pegar os dados de pepsi e coca-cola entre January 2003 until the end of August 2016
# e calcular os retornos diários
from <- "2003-01-01"
to <- "2016-08-31"
ko1 <- getSymbols( Symbols = "ko", src = "yahoo", index.class = "POSIXct",
                  from = from, to = to, adjust = TRUE, auto.assign = FALSE )
ko <- dailyReturn( ko1$KO.Adjusted, type = "log") + 1
names(ko) <- "Adjusted.ko"
pep1 <- getSymbols( Symbols = "pep", src = "yahoo", index.class = "POSIXct",
                  from = from, to = to, adjust = TRUE, auto.assign = FALSE )
pep <- dailyReturn( pep1$PEP.Adjusted, type = "log") + 1 
names(pep) <- "Adjusted.pep"
# reset to default chart
par(mfrow = c(1, 1), mar=c(5, 4, 4, 2) + 0.1)


# Get a feel for the data
#
# The choice of investment matters even when the underlying risky assets are
# similar. As a first example, let us consider the stock price of the Coca Cola
# Company and the PepsiCo company from January 2003 until the end of August
# 2016.
#
# The time series plot shows you the value evolution of one dollar invested in
# each company. As an exercise, plot the time series showing the relative value
# of an investment in the Coca Cola company, compared to the value of an
# investment in PepsiCo. To do this exercise, you can use the corresponding
# price series, available as the variables ko and pep in your workspace.
#
# Three important packages that you will use in this course are the xts and zoo
# packages (these are popular when working with time series data), and the
# PerformanceAnalytics package.


# Define ko_pep as the ratio expressing the value of the share price of the Coca
# Cola company in terms of the share price of PepsiCo.
#
# Use plot.zoo() to visualize the variation in this ratio over time. Note that
# when the value of the ratio is larger than 1, the performance of ko since
# January 2003 is higher than that of pep.
#
# As a reference line, use abline() to include a horizontal line at h=1. Note
# that where the value of the ratio is larger than one, the Coca Cola Company
# outperforms Pepsico and vice versa.

# Define ko_pep 
ko_pep <- ko/pep

# Make a time series plot of ko_pep
hh <- plot.zoo(ko_pep)

# Add as a reference, a horizontal line at 1
hh <- abline( h=1, col="Red")



# Calculating portfolio weights when component values are given
#
# In the video, it was shown that you can easily compute portfolio weights if
# you have a given amount of money invested in certain assets. If you want to
# start investing in a portfolio, but you have budget restraints, you can also
# impose weights yourself. Depending on what these are, you will invest a
# certain amount of money in each of the assets based on their weight.
#
# When given asset values, calculating the weights is quite simple. Recall from
# the video that weights are calculated by taking the value of an asset divided
# by the sum of values from all assets.
#
# In this exercise, you will learn to calculate weights when individual asset
# values are given! For this example, an investor has 4000 USD invested in
# equities, 4000 USD invested in bonds, and 2000 USD invested in commodities.
# Compute the weights as the proportion invested in each of those three assets.

# Define the vector values as the vector holding the three asset values. Define
# the vectors weights as the vector values divided by the total value (obtained
# by summing over the component values using the function sum(). Print weights.

# Define the vector values
values <- c(4000, 4000, 2000)

# Define the vector weights
weights <- values/ sum(values)

# Print the resulting weights
print(weights)


# The weights of an equally weighted portfolio
#
# One of the most commonly used portfolios in investing is the equally weighted
# portfolio. This means that you choose to invest an equal amount of capital in
# each asset.
#
# Suppose a portfolio is equally invested in N assets, where N <- 100. Use the R
# console to determine which of the following commands defines the weight vector
# for an equally weighted portfolio.

N <-100
weights <- rep(1/N,N)
print(weights)

# The weights of a market capitalization-weighted portfolio
#
# In a market capitalization-weighted portfolio, the weights are given by the
# individual assets' market capitalization (or market value), divided by the sum
# of the market capitalizations of all assets. A typical example is the S&P 500
# portfolio invested in the 500 largest companies listed on the US stock
# exchanges (NYSE, Nasdaq). Note that by dividing by the sum of asset values
# across all portfolio assets, the portfolio weights sum to unity (one).
#
# As an exercise, inspect the distribution of market capitalization based
# weights when the portfolio is invested in 10 stocks. For this exercise, you
# can use market capitalizations of 5, 8, 9, 20, 25, 100, 100, 500, 700, and
# 2000 million USD.

# Define the vector marketcaps holding the market capitalizations.
# Calculate the weights of marketcaps and assign them to weights.
# Print a summary of weights.
# Create a bar plot of weights.

# Define marketcaps
marketcaps <- c( 5, 8, 9, 20, 25, 100, 100, 500, 700, 2000)

# Compute the weights
weights <- marketcaps / sum(marketcaps)

# Inspect summary statistics
print( summary( weights))

# Create a bar plot of weights
barplot( weights)



# Calculation of portfolio returns
#
# For your first exercise on calculating portfolio returns, you will verify that
# a portfolio return can be computed as the weighted average of the portfolio
# component returns. In other words, this means that a portfolio return is
# calculated by taking the sum of simple returns multiplied by the portfolio
# weights. Remember that simple returns are calculated as the final value minus
# the initial value, divided by the initial value.
#
# Assume that you invested in three assets. Their initial values are 1000 USD,
# 5000 USD, 2000 USD, respectively. Over time, the values change to 1100 USD,
# 4500 USD, and 3000 USD.


# Create a vector of the initial asset values in_values. Create a vector of the
# final values, fin_values. Create a vector of the initial weights, weights. Use
# the simple return definition to compute the vector of returns on the three
# component assets. Assign return values to returns. Assign the portfolio
# returns to preturns.

# Vector of initial value of the assets
in_values <- c(1000, 5000, 2000)

# Vector of final values of the assets
fin_values <- c(1100, 4500,3000)

# Weights as the proportion of total value invested in each asset
weights <- in_values/sum(in_values)

# Vector of simple returns of the assets 
returns <- (fin_values - in_values)/in_values

# Compute portfolio return using the portfolio return formula
preturns <- sum( returns * weights)


# From simple to gross and multi-period returns
#
# The simple return R expresses the percentage change in the value of an
# investment. The corresponding so-called "gross" return is defined as the
# future value of 1 USD invested in the asset for one period and is thus equal
# to 1+R.
#
# The gross return over two periods is obtained similarly. Let $R1$ be the
# return in the first period and $R2$ the return in the second period. Then the
# end-value of a 1 USD investment is (1+ $R1$)∗(1+$R2$).
#
# The corresponding simple return over those two periods is: (1+
# $R1$)∗(1+$R2$)−1.
#
# Suppose that you have an investment horizon of two periods. In the first
# period, you make a 10% return. But in the second period, you take a loss of
# 5%.
#
# Use the R console to compute the end value of a 1000 USD investment.
#
# Which of the three following answers do you obtain?

# resposta by HH
print( 1000*(1+0.1)*(1-0.05))

# The asymmetric impact of gains and losses
#
# It is important to be aware of the fact that a positive and negative return of
# the same relative magnitude do not compensate each other in terms of terminal
# wealth. Mathematically, this can be seen from the identity (1+x)∗(1−x)=1−x2 ,
# which is less than one. A 50% loss is thus not compensated by a 50% gain.
#
# After a loss of 50%, what is the return needed to be at par again? Verify your
# answer in the R console.

# resposta by HH
# 100%
print( (1+1)*(1-0.5) )



# Buy-and-hold versus (daily) rebalancing
#
# The choice of investment matters, even when the underlying risky assets are
# similar. As an example, you will now consider the stock price of Apple and
# Microsoft from January 2006 until the end of August 2016. The time series plot
# shows you the value evolution of one dollar invested in each of them.
#
# For this exercise, your portfolio approach will be to invest half of your
# budget in Apple stock, and the other half of your budget in Microsoft stock.
# Over time, the portfolio weights will change. You will have two choices as an
# investor. The first choice is to be passive and not trade any further. This is
# called a buy and hold strategy. The second choice is to buy and trade at the
# close of each day that results in a rebalance of the portfolio such that your
# portfolio is equally invested in shares of Microsoft and Apple. This is a
# rebalanced portfolio.
#
# Which of the following statements is false?

# TRUE = By investing in a portfolio of risky assets, the portfolio payoff will
# be in between the minimum and maximum of the payoff of the underlying risky
# assets.

# TRUE = By investing in a portfolio of risky assets, the risk of the portfolio
# payoff will be less than the maximum risk of the underlying risky assets.

# FALSE = An investor needs to have a lot of capital to be able to invest in a
# portfolio of many assets.

# TRUE = Because the prices of Microsoft and Apple have evolved differently, the
# investor who spent initially half of his wealth on Microsoft and Apple ends up
# with a portfolio that is no longer equally invested.




# The time series of asset returns
#
# Calculating the returns for one period is pretty straightforward to do in R.
# When the returns need to be calculated for different dates the functions
# Return.calculate() and Return.portfolio(), in the R package
# PerformanceAnalytics are extremely helpful. They require the input data to be
# of the xts-time series class, which is pre-loaded. You will explore the
# functionality of the PerformanceAnalytics package in this exercise.
#
# The object prices which contains the Apple (aapl) and Microsoft (msft) stocks
# is available in the workspace.


# Load the package PerformanceAnalytics in your R session. Have a look at the
# first and last six rows of prices, using head() and tail() respectively. Use
# the function Return.calculate() with the only argument prices to compute for
# each date the return as the percentage change in the price compared to the
# previous date, call this returns. Print the first six rows of returns. Remove
# the first row of returns.

# By HH: pegar os dados de apple e microsoft entre January 2006 until the end of
# August 2016
from <- "2006-01-01"
to <- "2016-09-01"
apple <- getSymbols( Symbols = "aapl", src = "yahoo", index.class = "POSIXct",
                   from = from, to = to, adjust = TRUE, auto.assign = FALSE )
msft <- getSymbols( Symbols = "msft", src = "yahoo", index.class = "POSIXct",
                    from = from, to = to, adjust = TRUE, auto.assign = FALSE )
# junta os fechamentos na 'prices'
# ajuste no preço da Apple que teve 2 splits: em 09/06/2014, 7 para 1 e 
# em 31/08/2020 4 para 1
hh1 <- Cl(apple) * 4
names(hh1) <- "AAPL"
apple <-  hh1["/2014-06-06"] * 7
apple <- rbind(apple, hh1["2014-06-09/"])
# junta as 2 séries
prices <- merge( apple, Cl(msft))
names(prices) <- c( "AAPL", "MSFT")

## resposta:
# Load package PerformanceAnalytics 
require("PerformanceAnalytics")

# Print the first six rows and last six rows of prices
head(prices,6)
tail(prices,6)

# Create the variable returns using Return.calculate()  
returns <- Return.calculate(prices)

# Print the first six rows of returns. Note that the first observation is NA because there is no prior price.
head(returns, 6)

# Remove the first row of returns
returns <- returns[-1, ]


# The time series of portfolio returns
#
# In the previous exercise, you created a variable called returns from the daily
# prices of stocks of Apple and Microsoft. In this exercise, you will create two
# portfolios using the return series you previously created. The two portfolios
# will differ in one way, and that is the weighting of the assets.
#
# In the last video, you were introduced to two weighting strategies: the buy
# and hold strategy, and a monthly rebalancing strategy. In this exercise, you
# will create a portfolio in which you don’t rebalance, and one where you
# rebalance monthly. You will then visualize the portfolio returns of both.
#
# You will use the function Return.portfolio() for your calculations. For this
# function, you will provide three arguments: R, weights, and rebalance_on. R is
# a time series of returns, weights is a vector containing asset weights, and
# rebalance_on specifies which calendar-period to rebalance on. If you need
# help, be sure to check the documentation by clicking on the function!
#
# For this exercise, you will be working with the returns data that are
# pre-loaded in your workspace.

# Create a vector of weights for two equally weighted assets called eq_weights.
# Remember that weights must add to 1. Create a portfolio using the buy and hold
# strategy using Return.portfolio(). Note, you do not need to specify a
# rebalance period. Call this pf_bh. Create a portfolio where you rebalance your
# weights monthly. Use Return.portfolio() with the argument rebalance_on =
# "months". Call this pf_rebal. Plot the time series of each portfolio using
# plot.zoo(). par(mfrow = c(2, 1), mar = c(2, 4, 2, 2)) is used to organize the
# plots you create. Do not alter this code.

# Create the weights
eq_weights <- c(0.5, 0.5)

# Create a portfolio using buy and hold
pf_bh <- Return.portfolio(R = returns, weights = eq_weights)

# Create a portfolio rebalancing monthly 
pf_rebal <- Return.portfolio(R = returns, weights = eq_weights, rebalance_on = "months")

# Plot the time-series
hh <- par(mfrow = c(2, 1), mar = c(2, 4, 2, 2))
hh <- plot.zoo(pf_bh)
hh <- plot.zoo(pf_rebal)


# The time series of weights
#
# In the previous exercise, you explored the functionality of the
# Return.portfolio() function and created portfolios using two strategies.
# However, by setting the argument verbose = TRUE in Return.portfolio() you can
# create a list of beginning of period (BOP) and end of period (EOP) weights and
# values in addition to the portfolio returns, and contributions.
#
# You can access these from the resultant list-object created from
# Return.portfolio(). The resultant list contains $returns, $contributions,
# $BOP.Weight, $EOP.Weight, $BOP.Value, and $EOP.Value.
#
# In this exercise, you will recreate the portfolios you made in the last
# exercise but extend it by creating a list of calculations using verbose =
# TRUE. You will then visualize the end of period weights of Apple.
#
# The object returns is pre-loaded in your workspace.


# Define the vector eq_weights for two equally weighted assets. Create a
# portfolio of returns by using the buy and hold strategy and setting verbose =
# TRUE. Call this pf_bh. Create a portfolio of returns using the monthly
# rebalancing strategy and setting verbose = TRUE. Call this pf_rebal. Create a
# new object called eop_weight_bhusing the end of period weights of pf_bh.
# Create a new object called eop_weight_rebal using the end of period weights of
# pf_rebal. Plot the end of period weights of Apple in eop_weight_bh using
# plot.zoo(), and the end of period weights of Apple in eop_weight_rebal using
# plot.zoo(). par(mfrow = c(2, 1), mar = c(2, 4, 2, 2)) is used to organize the
# plots you create. Do not alter this code.

# Create the weights
eq_weights <- c(0.5, 0.5)

# Create a portfolio using buy and hold
pf_bh <- Return.portfolio(returns, weights = eq_weights, verbose = TRUE)

# Create a portfolio that rebalances monthly
pf_rebal <- Return.portfolio(returns, weights = eq_weights, rebalance_on = "months", verbose = TRUE)

# Create eop_weight_bh
eop_weight_bh <- pf_bh$EOP.Weight

# Create eop_weight_rebal
eop_weight_rebal <- pf_rebal$EOP.Weight

# Plot end of period weights
par(mfrow = c(2, 1), mar=c(2, 4, 2, 2))
hh <- plot.zoo(eop_weight_bh$AAPL)
hh <- plot.zoo(eop_weight_rebal$AAPL)



# Exploring the monthly S&P 500 returns
#
# For the upcoming exercises, you will examine the monthly performance of the
# S&P 500. A picture is worth a thousand words. This is why most analyses of
# performance start by studying the time series plot of the value of an
# investment.
#
# A plot of the S&P 500 for the period of 1986 until August 2016 is shown to
# your right. Each observation on this plot is an end-of-day value. This chart
# shows a number of booms and busts. Take a look at the chart, do you see why
# the 2000s are so often called the lost decade of investing?
#
# The PerformanceAnalytics and xts-package are preloaded, and the daily prices
# for the S&P 500 are available in your workspace as the variable sp500. This
# variable is of the xts time series class. This means that each observation has
# a time-stamp. Your job is to describe the monthly performance of the S&P 500.
# To do so, you will first need to aggregate daily price series to end-of-month
# prices. You will then calculate the monthly returns and visualize them in a
# table.

# Use the function to.monthly() with the argument sp500 and assign this to
# sp500_monthly. Print the first six rows of sp500_monthly. Notice how
# aggregating the data has resulted in a table of four columns holding the
# opening, lowest, highest, and closing price of sp500 for each month. Create
# sp500_returns using the function Return.calculate() on sp500_monthly using the
# closing prices (fourth column in sp500_monthly). Use plot.zoo() to plot the
# time series of sp500_returns Use the function table.CalendarReturns() in
# PerformanceAnalytics to present the monthly return data in a table format
# showing year by month.


# By HH: pegar os dados do S&P500 entre January 1986 until the end of
# August 2016
from <- "1985-12-30"
to <- "2016-08-31"
sp500 <- getSymbols( Symbols = "^GSPC", src = "yahoo", index.class = "POSIXct",
                     from = from, to = to, adjust = TRUE, auto.assign = FALSE )
#sp500 <- Ad(to.monthly(sp500))
# reset to default chart
par(mfrow = c(1, 1), mar=c(5, 4, 4, 2) + 0.1)

## resposta
# Convert the daily frequency of sp500 to monthly frequency: sp500_monthly
sp500_monthly <- to.monthly(sp500)

# Print the first six rows of sp500_monthly
head(sp500_monthly,6)

# Create sp500_returns using Return.calculate using the closing prices
sp500_returns <- Return.calculate( Cl( sp500_monthly))

# Time series plot
hh <- plot.zoo(sp500_returns)

# Produce the year x month table
print( table.CalendarReturns(sp500_returns))



# The monthly mean and volatility
#
# You have now created month to month returns for the S&P 500. Next, you will
# need to do a descriptive analysis of the returns.
#
# In this exercise, you will calculate the mean (arithmetic and geometric) and
# volatility (standard deviation) of the returns. These returns are available in
# your workspace as the variable sp500_returns.

# Compute the arithmetic mean value of the return series. Compute the geometric
# mean value of the return series using mean.geometric(). Compute the standard
# deviation of the return series.

# ajuste by HH
sp500_returns <- sp500_returns[-1, ]

## resposta
# Compute the mean monthly returns
print( mean(sp500_returns))

# Compute the geometric mean of monthly returns
print( mean.geometric(sp500_returns))

# Compute the standard deviation
print( sd(sp500_returns))




# Excess returns and the portfolio's Sharpe ratio
#
# You just learned how to create descriptive statistics of your portfolio
# returns. Now you will learn how to evaluate your portfolio's performance!
#
# Performance evaluation involves comparing your investment choices with an
# alternative investment choice. Most often, the performance is compared with
# investing in an (almost) risk-free asset, such as the U.S. Treasury Bill. The
# return from a U.S. Treasury Bill is known as a risk-free rate because Treasury
# Bills (T-Bills) are backed by the U.S. Government.
#
# In this exercise, you will be asked to annualize the risk-free rate by using
# the compound interest formula. The yearly compounded interest rate is given by
# (1+y)12−1
#
# . The annual rate is used to estimate a yearly return and is very useful for
# forecasting.
#
# As you might recall from the video, the Sharpe Ratio is an important metric
# that tells us the return-to-volatility ratio. It is calculated by taking the
# mean of excess returns (returns - risk-free rate), divided by the volatility
# of the returns.
#
# Pre-loaded in your workspace is the object rf which contains the one-month
# rate of a T-Bill. The S&P 500 portfolio returns are still available as
# sp500_returns.

# Calculate the annualized risk-free rate using the compound interest formula,
# assign it to annualized_rf. Plot the time-series of annualized_rf using
# plot.zoo(). Calculate the excess monthly portfolio return, assign it to
# sp500_excess. Print the mean excess returns and the mean returns. Compare the
# two. Complete the code to calculate the monthly Sharpe ratio, assign it to
# sp500_sharpe.


#by HH: pegar a taxa (ao mes) de T-Bill de 1 mes
rf <- sp500_returns
hh <- rep(0.003, nrow(sp500_returns)) # GAMBI, usando valor constante de 0.3%
rf <- merge(rf, matrix( hh, ncol=1))
rf$sp500.Close <-NULL
names(rf) <- NULL

# resposta:
# Compute the annualized risk free rate
annualized_rf <- (1 + rf)^12 - 1

# Plot the annualized risk-free rate
hh <- plot.zoo(annualized_rf)

# Compute the series of excess portfolio returns 
sp500_excess <- sp500_returns - rf

# Compare the mean of sp500_excess and sp500_returns 
mean(sp500_excess)
mean(sp500_returns)

# Compute the Sharpe ratio
sp500_sharpe <- mean(sp500_excess) / sd(sp500_returns)



# Annualized mean and volatility
#
# The mean and volatility of monthly returns correspond to the average and
# standard deviation over a monthly investment horizon. Investors annualize
# those statistics to show the performance over an annual investment horizon.
#
# To do so, the package PerformanceAnalytics has the function
# Return.annualized() and StdDev.annualized() to compute the (geometrically)
# annualized mean return and annualized standard deviation for you.
#
# Remember that the Sharpe ratio is found by taking the mean excess returns
# subtracted by the risk-free rate, and then divided by the volatility! The
# packages PerformanceAnalytics and sp500_returns are preloaded for you.

# Use the function Return.annualized() to compute the annualized mean of
# sp500_returns. Use the function StdDev.annualized() to compute the annualized
# standard deviation of sp500_returns. Calculate the annualized Sharpe Ratio
# using commands from the PerformanceAnalytics package, assign it to ann_sharpe.
# Assume the risk free rate is 0. Obtain all the above results at once using the
# function table.AnnualizedReturns().





