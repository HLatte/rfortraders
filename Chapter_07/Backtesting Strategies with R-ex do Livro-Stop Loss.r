# exmplo do livro   Backtesting Strategies with R
# https://timtrice.github.io/backtesting-strategies/index.html
#
# Exemplo com stop-loss
#

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



# carrega os nomes das ações
symbols <- basic_symbols()

getSymbols(Symbols = symbols, 
          src = "yahoo", 
          index.class = "POSIXct",
          from = start_date, 
          to = end_date, 
          adjust = adjustment,
          auto.assign = TRUE) # by HH

# After we’ve loaded our symbols we use FinancialInstrument::stock() to define 
# the meta-data for our symbols. In this case we’re defining the currency in 
# USD (US Dollars) with a multiplier of 1. Multiplier is applied to price.
# This will vary depending on the financial instrument you are working on but for
# stocks it should always be 1.
stock(symbols, 
      currency = "USD", 
      multiplier = 1)



#
### 8 Stop-Loss Orders ####
#

# parametros
.fast <- 10
.slow <- 30
.threshold <- 0.0005
.orderqty <- 100
.txnfees <- -10
.stoploss <- 3e-3 # 0.003 or 0.3%
# nomes
portfolio.st <- "Port.Luxor.Stop.Loss"
account.st <- "Acct.Luxor.Stop.Loss"
strategy.st <- "Strat.Luxor.Stop.Loss"
# limpa
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
           symbols = symbols,
           initDate = init_date)
#
strategy(strategy.st, store = TRUE)
#
# 8.1 Add Indicators ##
#
add.indicator(strategy.st, 
              name = "SMA",
              arguments = list(x = quote(Cl(mktdata)),
                               n = .fast),
              label = "nFast")
#
add.indicator(strategy.st, 
              name = "SMA",
              arguments = list(x = quote(Cl(mktdata)),
                               n = .slow),
              label = "nSlow")
#
# 8.2 Add Signals ##
#
add.signal(strategy.st, 
           name = "sigCrossover",
           arguments = list(columns = c("nFast", "nSlow"),
                            relationship = "gte"),
           label = "long")
#
add.signal(strategy.st, 
           name = "sigCrossover",
           arguments = list(columns = c("nFast", "nSlow"),
                            relationship = "lt"),
           label = "short")
#
# 8.3 Add Rules ##
#
add.rule(strategy.st, 
         name = "ruleSignal",
         arguments = list(sigcol = "long" , 
                          sigval = TRUE,
                          replace = FALSE,
                          orderside = "long" ,
                          ordertype = "stoplimit",
                          prefer = "High",
                          threshold = .threshold,
                          TxnFees = .txnfees,
                          orderqty = +.orderqty,
                          osFUN = osMaxPos,
                          orderset = "ocolong"),
         type = "enter",
         label = "EnterLONG")
#
add.rule(strategy.st, 
         name = "ruleSignal",
         arguments = list(sigcol = "short", 
                          sigval = TRUE,
                          replace = FALSE,
                          orderside = "short",
                          ordertype = "stoplimit",
                          prefer = "Low",
                          threshold = .threshold,
                          TxnFees = .txnfees,
                          orderqty = -.orderqty,
                          osFUN = osMaxPos,
                          orderset = "ocoshort"),
         type = "enter",
         label = "EnterSHORT")
#
add.rule(strategy.st, 
         name = "ruleSignal",
         arguments = list(sigcol = "long", 
                          sigval = TRUE,
                          replace = TRUE,
                          orderside = "short",
                          ordertype = "market",
                          TxnFees = .txnfees,
                          orderqty = "all",
                          orderset = "ocoshort"),
         type = "exit",
         label = "Exit2LONG")
#
add.rule(strategy.st, 
         name = "ruleSignal",
         arguments = list(sigcol = "short", 
                          sigval = TRUE,
                          replace = TRUE,
                          orderside = "long" ,
                          ordertype = "market",
                          TxnFees = .txnfees,
                          orderqty = "all",
                          orderset = "ocolong"),
         type = "exit",
         label = "Exit2SHORT")
# 
# Stop loss #
#
add.rule(strategy.st, 
         name = "ruleSignal",
         arguments = list(sigcol = "long" , 
                          sigval = TRUE,
                          replace = FALSE,
                          orderside = "long",
                          ordertype = "stoplimit",
                          tmult = TRUE,
                          threshold = quote(.stoploss),
                          TxnFees = .txnfees,
                          orderqty = "all",
                          orderset = "ocolong"),
         type = "chain", 
         parent = "EnterLONG",
         label = "StopLossLONG",
         enabled = FALSE)
#
add.rule(strategy.st, 
         name = "ruleSignal",
         arguments = list(sigcol = "short", 
                          sigval = TRUE,
                          replace = FALSE,
                          orderside = "short",
                          ordertype = "stoplimit",
                          tmult = TRUE,
                          threshold = quote(.stoploss),
                          TxnFees = .txnfees,
                          orderqty = "all",
                          orderset = "ocoshort"),
         type = "chain", 
         parent = "EnterSHORT",
         label = "StopLossSHORT",
         enabled = FALSE)
#
# 8.4 Add Position Limit ##
#
for(symbol in symbols){
  addPosLimit(portfolio = portfolio.st,
              symbol = symbol,
              timestamp = init_date,
              maxpos = .orderqty)
}
#
# 8.5 Enable Rules ##
#
enable.rule(strategy.st, 
            type = "chain", 
            label = "StopLoss")
#
# 8.6 Apply Strategy ##
#
cwd <- getwd()
setwd("./_data/")
results_file <- paste("results", strategy.st, "RData", sep = ".")
if( file.exists(results_file) ) {
  load(results_file)
} else {
  results <- applyStrategy(strategy.st, portfolios = portfolio.st)
  if(checkBlotterUpdate(portfolio.st, account.st, verbose = TRUE)) {
    save(list = "results", file = results_file)
    save.strategy(strategy.st)
  }
}
setwd(cwd)








