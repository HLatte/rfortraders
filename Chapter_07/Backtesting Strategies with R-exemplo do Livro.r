# exmplo do livro   Backtesting Strategies with R
# https://timtrice.github.io/backtesting-strategies/index.html

# rm(list = ls()) # Delete the workspace from any unwanted variable

# carrega a Utils.R
source("Backtesting Strategies with R-utils.r")
source("utils-livro.r")
verbose <- TRUE
# carrega os pacotes necessarios
load_package(verbose, "quantstrat")
load_package(verbose, "PerformanceAnalytics")
load_package(verbose, "data.table")
load_package(verbose, "parallel")
load_package(verbose, "doParallel")
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
### 5.1 - Strategy setup ####
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

# Next we’ll assign proper names for our portfolio, account and strategy objects.
# These can be any name you want and should be based on how you intend to log the
# data later on.
portfolio.st <- "Port.Luxor"
account.st <- "Acct.Luxor"
strategy.st <- "Strat.Luxor"

# We remove any residuals from previous runs by clearing out the portfolio and
# account values. At this point for what we have done so far this is unnecessary.
# However, it’s a good habit to include this with all of your scripts as data
# stored in memory can affect results or generate errors.
rm.strat(portfolio.st)
rm.strat(account.st)

# Now we initialize our portfolio, account and orders. We will also store our
# strategy to save for later.
initPortf(name = portfolio.st,
          symbols = symbols,
          initDate = init_date)
initAcct(name = account.st,
         portfolios = portfolio.st,
         initDate = init_date,
         initEq = init_equity)
initOrders(portfolio = portfolio.st,
           symbols = symbols,
           initDate = init_date)
strategy(strategy.st, store = TRUE)

#
### 5.2 - Add Indicators ####
# Indicators are functions used to measure a variable. A SMA is just an average
# of the previous n prices; typically closing price. So SMA(10) is just an average
# of the last 10 closing prices.
#
# This is where the TTR library comes in; short for Technical Trading Rules.
# SMA() is a function of TTR as are many other indicators. If you want MACD, RSI,
# Bollinger Bands, etc., you will use the TTR library.
#
# NOTE: mktdata is a special dataset created for each symbol that will store all
# of our indicators and signals. When the strategy is ran you will see the
# mktdata object in your environment. It will only exist for the last symbol
# the strategy executed.
add.indicator(strategy = strategy.st,
              name = "SMA",
              arguments = list(x = quote(Cl(mktdata)), 
                               n = 10),
              label = "nFast")
add.indicator(strategy = strategy.st, 
              name = "SMA", 
              arguments = list(x = quote(Cl(mktdata)), 
                               n = 30), 
              label = "nSlow")

#
### 5.3 - Add Signals ####
# Signals are a value given when conditions are met by our indicators. For example,
# in this strategy we want a signal whenever nFast is greater than or equal to
# nSlow. We also want another signal where nFast is less than nSlow. We’ll name
# these signals long and short, respectively.
#
# Here we’ll use some built-in quantstrat functions. Let’s take a quick look at
# what’s available:
#   sigComparison: boolean, compare two variables by relationship
#     gt = greater than
#     lt = less than
#     eq = equal to
#     gte = greater than or equal to
#     lte = less than or equal to
#   sigCrossover: boolean, TRUE when one signal crosses another. Uses the same
#     relationships as sigComparison
#   sigFormula: apply a formula to multiple variables.
#   sigPeak: identify local minima or maxima of an indicator
#   sigThreshold: boolean, when an indicator crosses a value. Uses relationships
#     as identified above.
#   sigTimestamp: generates a signal based on a timestamp.
add.signal(strategy = strategy.st,
           name="sigCrossover",
           arguments = list(columns = c("nFast", "nSlow"),
                            relationship = "gte"),
           label = "long")
add.signal(strategy = strategy.st,
           name="sigCrossover",
           arguments = list(columns = c("nFast", "nSlow"),
                            relationship = "lt"),
           label = "short")

#
### 5.4 - Add Rules ####
# add.rules will determine the positions we take depending on our signals, what
# type of order we’ll place and how many shares we will buy.
#
# Whenever our long variable (sigcol) is TRUE (sigval) we want to place a stoplimit order (ordertype). Our preference is at the High (prefer) plus threshold. We want to buy 100 shares (orderqty). A new variable EnterLONG will be added to mktdata. When we enter (type) a position EnterLONG will be TRUE, otherwise FALSE. This order will not replace any other open orders.
add.rule(strategy = strategy.st,
         name = "ruleSignal",
         arguments = list(sigcol = "long",
                          sigval = TRUE,
                          orderqty = 100,
                          ordertype = "stoplimit",
                          orderside = "long", 
                          threshold = 0.0005,
                          prefer = "High", 
                          TxnFees = -10, 
                          replace = FALSE),
         type = "enter",
         label = "EnterLONG")
# If our short variable (sigcol) is TRUE (sigval) we will place another stoplimit
# order (ordertype) with a preference on the Low (prefer). We will sell 100 shares
# (orderqty). This order will not replace any open orders (replace).
add.rule(strategy.st,
         name = "ruleSignal",
         arguments = list(sigcol = "short",
                          sigval = TRUE,
                          orderqty = -100,
                          ordertype = "stoplimit",
                          threshold = -0.005, 
                          orderside = "short", 
                          replace = FALSE, 
                          TxnFees = -10, 
                          prefer = "Low"),
         type = "enter",
         label = "EnterSHORT")
# We now have rules set up to enter positions based on our signals. However, we
# do not have rules to exit open positions. We’ll create those now.
#
# Our next rule, Exit2SHORT, is a simple market order to exit (type) when short
# is TRUE (sigcol, sigval). This closes out all long positions (orderside, orderqty).
# This order will replace (replace) any open orders.
#
# TxnFees are transaction fees associated with an order. This can be any value
# you choose but should accurately reflect the fees charged by your selected broker.
# In addition, we only show them here on exits. Some brokers charge fees on entry
# positions as well. TxnFees can be added to any rule set.
add.rule(strategy.st, 
         name = "ruleSignal", 
         arguments = list(sigcol = "short", 
                          sigval = TRUE, 
                          orderside = "long", 
                          ordertype = "market", 
                          orderqty = "all", 
                          TxnFees = -10, 
                          replace = TRUE), 
         type = "exit", 
         label = "Exit2SHORT")
# Lastly, we close out any short positions (orderside) when long is TRUE (sigcol
#, sigval). We will exit (type) at market price (ordertype) all open positions
# (orderqty). This order will replace any open orders we have (replace).
add.rule(strategy.st, 
         name = "ruleSignal", 
         arguments = list(sigcol = "long", 
                          sigval = TRUE, 
                          orderside = "short", 
                          ordertype = "market", 
                          orderqty = "all", 
                          TxnFees = -10, 
                          replace = TRUE), 
         type = "exit", 
         label = "Exit2LONG")

#
### 5.5 - Apply Strategy ####
# Now we get to the fun part! Do or die. Here we’ll find out if we built our
# strategy correctly or if we have any errors in our code. Cross your fingers.
# Let’s go!
#
# applyStrategy() is the function we will run when we have a straight strategy.
# What I mean by that is a strategy that doesn’t test different parameters.
#
# Next we update our portfolio and account objects. We do this with the updatePortf(),
# updateAcct() and updateEndEq() functions. updatePortf calculates the P&L for
# each symbol in symbols. updateAcct calculcates the equity from the portfolio
# data. And updateEndEq updates the ending equity for the account. They MUST BE
# called in order.
cwd <- getwd()
setwd("./_data/")
results_file <- paste("results", strategy.st, "RData", sep = ".")
if( file.exists(results_file) ) {
  load(results_file)
  # colocar? by HH: load.strategy(strategy.st)
} else {
  results <- applyStrategy(strategy.st, portfolios = portfolio.st)
  updatePortf(portfolio.st)
  updateAcct(account.st)
  updateEndEq(account.st)
  if(checkBlotterUpdate(portfolio.st, account.st, verbose = TRUE)) {
    save(list = "results", file = results_file)
    save.strategy(strategy.st)
  }
}
setwd(cwd)

#
### 6.2 - Examining Trades ####
#
chart.Posn(portfolio.st, Symbol = "SPY", Dates="2008-01-01::2008-07-01", 
           TA="add_SMA(n = 10, col = 2); add_SMA(n = 30, col = 4)")
# Our strategy called for a long entry when SMA(10) was greater than or equal to
# SMA(30). It seems we got a cross on February 25 but the trade didn’t trigger
# until two days later. Let’s take a look.
le <- as.data.frame(mktdata["2008-02-25::2008-03-07", c(1:4, 7:10)])
DT::datatable(le, 
              rownames = TRUE,
              extensions = c("Scroller", "FixedColumns"), 
              options = list(pageLength = 5, 
                             autoWidth = TRUE, 
                             deferRender = TRUE, 
                             scrollX = 200, 
                             scroller = TRUE,
                             fixedColumns = FALSE), #by HH: TRUE
              #caption = htmltools::tags$caption( "Table 6.1: mktdata object for Feb. 25, 2008 to Mar. 7, 2008"))
              caption = "Table 6.1: mktdata object for Feb. 25, 2008 to Mar. 7, 2008")
# The 2008-02-25T00:00:00Z bar shows nFast just fractions of a penny lower than
# nSlow. We get the cross on 2008-02-26T00:00:00Z which gives a TRUE long signal.
# Our high on that bar is $132.61 which would be our stoplimit. On the
# 2008-02-27T00:00:00Z bar we get a higher high which means our stoplimit order
# gets filled at $132.61. This is reflected by the faint green arrow at the top
# of the candles upper shadow.
ob <- as.data.table(getOrderBook(portfolio.st)$Port.Luxor$SPY)
DT::datatable(ob, 
              rownames = FALSE,
              filter = "top",
              extensions = c("Scroller", "FixedColumns"), 
              options = list(pageLength = 5, 
                             autoWidth = TRUE, 
                             deferRender = TRUE, 
                             scrollX = 200, 
                             scroller = TRUE, 
                             fixedColumns = FALSE), #by HH: TRUE 
              #caption = htmltools::tags$caption( "Table 6.2: Order book for SPY"))
              caption = "Table 6.2: Order book for SPY")
# When we look at the order book (Table 6.2) we get confirmation of our order.
# index reflects the date the order was submitted. Order.StatusTime reflects
# when the order was filled.
# If we look at Rule we see the value of EnterLONG. These are the labels of the
# rules we set up in our strategy. Now you can see how all these labels we assigned
# earlier start coming together.
#
# If you flip to page 5 of Table 6.2, on 2009-11-03T00:00:00Z you will see we had
# an order replaced (Order.Status). Let’s plot this time frame and see what was
# going on.
chart.Posn(portfolio.st, Symbol = "SPY", Dates="2009-08-01::2009-12-31", 
           TA="add_SMA(n = 10, col = 2); add_SMA(n = 30, col = 4)")
# We got a bearish SMA cross on November 2 which submitted the short order.
# However, our stoplimit was with a preference of the Low and a threshold of
# $0.0005 or $102.98. So the order would only fill if we broke below that price.
# As you see, that never happened. The order stayed open until we got the bullish
#SMA cross on Nov. 11. At that point our short order was replaced with our long
# order to buy; a stoplimit at $109.50. Nov. 12 saw an inside day; the high
# wasn’t breached therefore the order wasn’t filled. However, on Nov. 13 we rallied
# past the high triggering the long order (green arrow). This is the last position
# taken in our order book.
#
# So it seems the orders are triggering as expected.

#
chart.Posn(portfolio.st, Symbol = "SPY", 
           TA="add_SMA(n = 10, col = 2); add_SMA(n = 30, col = 4)")


#
### 7.1 - Examining Trades ####
# We’ll assign the range for each of our SMA’s to two new variables: .fastSMA
# and .slowSMA. Both are just simple integer vectors. You can make them as narrow
# or wide as you want. However, this is an intensive process. The wider your
# parameters, the longer it will run. I’ll address this later.
#
# We also introduce .nsamples. .nsamples will be our value for the input parameter
# nsamples in apply.paramset(). This tells quantstrat that of the x-number of
# combinations of .fastSMA and .slowSMA to test to only take a random sample of
# those combinations. By default apply.paramset(nsamples = 0) which means all
# combinations will be tested. This can be fine provided you have the computational
# resources to do so - it can be a very intensive process (we’ll deal with
# resources later).
.fastSMA <- seq(5,30,5) #(1:30)
.slowSMA <- seq(20,180,10) # (20:80)
.nsamples <- 5
# novo portfolio a ser optimizado
portfolio.st <- "Port.Luxor.MA.Opt"
account.st <- "Acct.Luxor.MA.Opt"
strategy.st <- "Strat.Luxor.MA.Opt"
# limpa memoria
rm.strat(portfolio.st)
rm.strat(account.st)
# inicializa o portfolio
initPortf(name = portfolio.st,
          symbols = symbols,
          initDate = init_date)
initAcct(name = account.st,
         portfolios = portfolio.st,
         initDate = init_date,
         initEq = init_equity)
initOrders(portfolio = portfolio.st,
           symbols = symbols,
           initDate = init_date)
strategy(strategy.st, store = TRUE)

#
### 7.1 - Add Distribution ####
# We use add.distribution to distribute our range of values across the two
# indicators. Again, our first parameter the name of our strategy strategy.st.
#   paramset.label: name of the function to which the parameter range will be applied; in this case TTR:SMA().
#   component.type: indicator
#   component.label: label of the indicator when we added it (nFast and nSlow)
#   variable: the parameter of SMA() to which our integer vectors (.fastSMA and
#     .slowSMA) will be applied; n.
#   label: unique identifier for the distribution.
add.distribution(strategy.st,
                 paramset.label = "SMA",
                 component.type = "indicator",
                 component.label = "nFast",
                 variable = list(n = .fastSMA),
                 label = "nFAST")
add.distribution(strategy.st,
                 paramset.label = "SMA",
                 component.type = "indicator",
                 component.label = "nSlow",
                 variable = list(n = .slowSMA),
                 label = "nSLOW")

#
### 7.2 - Add Distribution Constraint ####
# What we do not want is to abandon our initial rules. In other words, go long
# when our faster SMA is greater than or equal to our slower SMA and go short
# when the faster SMA was less than the slower SMA.
# We keep this in check by using add.distribution.constraint. We pass in the
# paramset.label as we did in add.distribution. We assign nFAST to distribution.
# label.1 and nSLOW to distribution.label.2.
# Our operator will be one of c("<", ">", "<=", ">=", "="). Here, we’re issuing
# a constraint to always keep nFAST less than nSLOW.
# We’ll name this constraint SMA.Constraint by applying it to the label parameter.
add.distribution.constraint(strategy.st,
                            paramset.label = "SMA",
                            distribution.label.1 = "nFAST",
                            distribution.label.2 = "nSLOW",
                            operator = "<",
                            label = "SMA.Constraint")

#
### 7.3 - Running Parallel ####
# quantstrat includes the foreach library for purposes such as this. foreach
# allows us to execute our strategy in parallel on multicore processors which
# can save some time.
# On my current setup it is using one virtual core which doesn’t help much for
# large tasks such as this. However, if you are running on a system with more
# than one core processor you can use the follinwg if/else statement courtesy
# of Guy Yollin. It requires the parallel library and doParallel for Windows
# users and doMC for non-Windows users.

# by HH: parte dp codigo colocado no inicio junto com os outros pacotes
#by HH library(parallel)
if( Sys.info()['sysname'] == "Windows") {
#by HH  library(doParallel)
  registerDoParallel(cores=detectCores())
} else {
#by HH  library(doMC)
  registerDoMC(cores=detectCores())
}

#
### 7.4 Apply Paramset ####
# When we ran our original strategy we used applyStrategy(). When running
# distributions we use apply.paramset().
# For our current strategy we only need to pass in our portfolio and account
# objects.
# I’ve also used an if/else statement to avoid running this strategy repeatedly
# when making updates to the book which, again, is time-consuming. The results
# are saved to a RData file we’ll analyze later.
cwd <- getwd()
setwd("./_data/")
results_file <- paste("results", strategy.st, "RData", sep = ".")
if( file.exists(results_file) ) {
  load(results_file)
} else {
  results <- apply.paramset(strategy.st,
                            paramset.label = "SMA",
                            portfolio.st = portfolio.st,
                            account.st = account.st, 
                            nsamples = .nsamples)
  if(checkBlotterUpdate(portfolio.st, account.st, verbose = TRUE)) {
    save(list = "results", file = results_file)
    save.strategy(strategy.st)
  }
}
setwd(cwd)



# Tentativa de usar o parametro calculado pelO "apply.paramset"
#
# atualiza todos os parametros
#applyStrategy(strategy.st, portfolios = portfolio.st)
#checkBlotterUpdate(portfolio.st, account.st, verbose = TRUE)
#initOrders(portfolio.st)
updatePortf(portfolio.st)
updateAcct(account.st)
updateEndEq(account.st)
# faz o gráfico para cada ativo
for(symbol in symbols) {
  chart.Posn(portfolio.st, Symbol = symbol, 
             TA = "add_SMA(n = 10, col = 4); add_SMA(n = 30, col = 2)")
}





