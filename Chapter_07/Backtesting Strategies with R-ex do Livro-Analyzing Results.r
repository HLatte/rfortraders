# exmplo do livro   Backtesting Strategies with R
# https://timtrice.github.io/backtesting-strategies/index.html

# rm(list = ls()) # Delete the workspace from any unwanted variable

verbose <- FALSE

# carrega a Utils.R
source("Backtesting Strategies with R-utils.r")
source("utils-livro.r")

# carrega os pacotes necessarios
load_package(verbose, "lattice")
load_package(verbose, "knitr")
load_package(verbose, "tidyr")
load_package(verbose, "dplyr")
load_package(verbose, "quantstrat")
load_package(verbose, "PerformanceAnalytics")
load_package(verbose, "data.table")

# devtools::install_github("rstudio/DT")
# altera os defaults dos pacotes #
options("getSymbols.warning4.0" = FALSE) # Suppresses warnings
options("getSymbols.auto.assign" = FALSE)
options("getSymbols.yahoo.warning" = FALSE) # Suppresses warnings


### Geral setting ####
# set our timezone to UTC
Sys.setenv(TZ = "UTC")
# set currency
currency('USD')
# init_date: The date we will initialize our account and portfolio objects. 
# This date should be the day prior to start_date.
init_date <- "2007-12-31"
# start_date: First date of data to retrieve.
start_date <- "2008-01-01"
# end_date: Last date of data to retrieve.
end_date <- "2009-12-31"
# init_equity: Initial account equity.
init_equity <- 1e4 # $10,000
# adjustment: Boolean - TRUE if we should adjust the prices for dividend payouts, 
#stock splits, etc; otherwise, FALSE.
adjustment <- TRUE




#
### 12 - Analyzing Results ####
#
# carrega os nomes das ações
symbols <- basic_symbols()
# nomes
portfolio.st <- "Port.Luxor"
account.st <- "Acct.Luxor"
strategy.st <- "Strat.Luxor"
#
cwd <- getwd()
setwd("./_data/")
load.strategy(strategy.st)
setwd(cwd)
#
rm.strat(portfolio.st)
rm.strat(account.st)
#
initPortf(name = portfolio.st,
          symbols = symbols,
          initDate = init_date)
#
initAcct(name = account.st,
         portfolios = portfolio.st,
         initDate = init_date, 
         initEq = init_equity)
#
initOrders(portfolio = portfolio.st,
           initDate = init_date)

#
### 12.1 - Apply Strategy ####
#
applyStrategy(strategy.st, portfolios = portfolio.st)
#
checkBlotterUpdate(portfolio.st, account.st, verbose = TRUE)
#
updatePortf(portfolio.st)
#
updateAcct(account.st)
#
updateEndEq(account.st)

#
### 12.2 - Chart Positions ####
#
for(symbol in symbols) {
  chart.Posn(portfolio.st, Symbol = symbol, 
             TA = "add_SMA(n = 10, col = 4); add_SMA(n = 30, col = 2)")
}

#
### 12.3 - Trade Statistics ####
# 
tstats <- tradeStats(portfolio.st)
kable(t(tstats))

# 12.3.1 - Trade Related
tab.trades <- tstats %>% 
  mutate(Trades = Num.Trades, 
         Win.Percent = Percent.Positive, 
         Loss.Percent = Percent.Negative, 
         WL.Ratio = Percent.Positive/Percent.Negative) %>% 
  select(Trades, Win.Percent, Loss.Percent, WL.Ratio)
kable(t(tab.trades))

# 12.3.2 Profit Related
tab.profit <- tstats %>% 
  select(Net.Trading.PL, Gross.Profits, Gross.Losses, Profit.Factor)
kable(t(tab.profit))

# 12.3.3 Averages
tab.wins <- tstats %>% 
  select(Avg.Trade.PL, Avg.Win.Trade, Avg.Losing.Trade, Avg.WinLoss.Ratio)
kable(t(tab.wins))

# 12.3.4 Performance Summary
rets <- PortfReturns(Account = account.st)
rownames(rets) <- NULL
charts.PerformanceSummary(rets, colorset = bluefocus)

# 12.3.5 - Per Trade Statistics
for(symbol in symbols) {
  pts <- perTradeStats(portfolio.st, Symbol = symbol)
  kable(pts, booktabs = TRUE, caption = symbol)
}
kable(pts)

# 12.3.6 - Performance Statistics
rets <- PortfReturns(Account = account.st)
tab.perf <- table.Arbitrary(rets,
                            metrics=c(
                              "Return.cumulative",
                              "Return.annualized",
                              "SharpeRatio.annualized",
                              "CalmarRatio"),
                            metricsNames=c(
                              "Cumulative Return",
                              "Annualized Return",
                              "Annualized Sharpe Ratio",
                              "Calmar Ratio"))
kable(tab.perf)

# 12.3.7 - Risk Statistics
rets <- PortfReturns(Account = account.st)
tab.risk <- table.Arbitrary(rets,
                            metrics=c(
                              "StdDev.annualized",
                              "maxDrawdown",
                              "VaR",
                              "ES"),
                            metricsNames=c(
                              "Annualized StdDev",
                              "Max DrawDown",
                              "Value-at-Risk",
                              "Conditional VaR"))
kable(tab.risk)

### 12.3.8 - Buy and Hold Performance ####
rm.strat("buyHold")
# initialize portfolio and account
initPortf("buyHold", "SPY", initDate = init_date)
initAcct("buyHold", portfolios = "buyHold",
         initDate = init_date, initEq = init_equity)
# place an entry order
CurrentDate <- time(getTxns(Portfolio = portfolio.st, Symbol = "SPY"))[2]
equity = getEndEq("buyHold", CurrentDate)
ClosePrice <- as.numeric(Cl(SPY[CurrentDate,]))
UnitSize = as.numeric(trunc(equity/ClosePrice))
addTxn("buyHold", Symbol = "SPY", TxnDate = CurrentDate, TxnPrice = ClosePrice,
       TxnQty = UnitSize, TxnFees = 0)
# place an exit order
LastDate <- last(time(SPY))
LastPrice <- as.numeric(Cl(SPY[LastDate,]))
addTxn("buyHold", Symbol = "SPY", TxnDate = LastDate, TxnPrice = LastPrice,
       TxnQty = -UnitSize , TxnFees = 0)
# update portfolio and account
updatePortf(Portfolio = "buyHold")
updateAcct(name = "buyHold")
updateEndEq(Account = "buyHold")
chart.Posn("buyHold", Symbol = "SPY")

### 12.3.9 - Strategy vs. Market ####
rets <- PortfReturns(Account = account.st)
rets.bh <- PortfReturns(Account = "buyHold")
returns <- cbind(rets, rets.bh)
charts.PerformanceSummary(returns, geometric = FALSE, wealth.index = TRUE, 
                          main = "Strategy vs. Market")
# 12.3.10 Risk/Return Scatterplot
chart.RiskReturnScatter(returns, Rf = 0, add.sharpe = c(1, 2), 
                        main = "Return vs. Risk", 
                        colorset = c("red", "red", "red", "blue"))
# 12.3.11 Relative Performance
for(n in 1:(ncol(returns) - 1)) {
  chart.RelativePerformance(returns[, n], returns[, ncol(returns)], 
                            colorset = rich8equal, # "blue", 
                            lwd = 2, legend.loc = "topleft")
}


#
### 12.3.12 Portfolio Summary ####
#' Error
pf <- getPortfolio(portfolio.st)
xyplot(pf$summary, type = "h", col = 4)

# 12.3.13 Order Book
ob <- getOrderBook(portfolio.st)

# 12.3.14 Maximum Adverse Excursion
for(symbol in symbols) {
  chart.ME(Portfolio = portfolio.st, Symbol = symbol, type = "MAE", 
           scale = "percent")
}

# 12.3.15 Maximum Favorable Excursion
for(symbol in symbols) {
  chart.ME(Portfolio = portfolio.st, Symbol = symbol, type = "MFE", 
           scale = "percent")
}

#
### 12.4 Account Summary ####
account <- getAccount(account.st)
xyplot(account$summary, type = "h", col = 4)

# 12.4.1 Equity Curve
equity <- account$summary$End.Eq
plot(equity, main = "Equity Curve")

# 12.4.2 Account Performance Summary
ret <- Return.calculate(equity, method = "log")
charts.PerformanceSummary(ret, colorset = bluefocus, 
                          main = "Strategy Performance")

# 12.4.3 Cumulative Returns
rets <- PortfReturns(Account = account.st)
chart.CumReturns(rets, colorset = rich10equal, legend.loc = "topleft", 
                 main="SPDR Cumulative Returns")

# 12.4.4 Distribution Analysis
chart.Boxplot(rets, main = "SPDR Returns", colorset= rich10equal)

# 12.4.5 Annualized Returns
print(ar.tab <- table.AnnualizedReturns(rets))

# 12.4.6 Performance Scatter Plot
max.risk <- max(ar.tab["Annualized Std Dev",])
max.return <- max(ar.tab["Annualized Return",])
chart.RiskReturnScatter(rets,
                        main = "SPDR Performance", colorset = rich10equal,
                        xlim = c(0, max.risk * 1.1), ylim = c(0, max.return))

# 12.4.7 Notional Costs
#quantstratII pp. 67/69
mnc <- pts$Max.Notional.Cost
pe <- sapply(pts$Start,getEndEq, Account = account.st)/3
barplot(rbind(pe,mnc),beside=T,col=c(2,4),names.arg=format(pts$Start,"%m/%d/%y"),
        ylim=c(0,1.5e5),ylab="$",xlab="Trade Date")
legend(x="topleft",legend=c("(Portfolio Equity)/9","Order Size"),
       pch=15,col=c(2,4),bty="n")
title("Percent of Portfolio Equity versus Trade Size for XLU")












