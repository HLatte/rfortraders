# The checkBlotterUpdate() function comes courtesy of Guy Yollin. 
# The purpose of this function is to check for discrepancies between the account 
# object and portfolio object. If the function returns FALSE we must examine why 
# (perhaps we didn’t clear our objects before running the strategy?).


# Guy Yollin, 2014
# http://www.r-programming.org/papers

checkBlotterUpdate <- function(port.st = portfolio.st, 
                               account.st = account.st, 
                               verbose = TRUE) {
  
  ok <- TRUE
  p <- getPortfolio(port.st)
  a <- getAccount(account.st)
  syms <- names(p$symbols)
  port.tot <- sum(
    sapply(
      syms, 
      FUN = function(x) eval(
        parse(
          text = paste("sum(p$symbols", 
                       x, 
                       "posPL.USD$Net.Trading.PL)", 
                       sep = "$")))))
  
  port.sum.tot <- sum(p$summary$Net.Trading.PL)
  
  if(!isTRUE(all.equal(port.tot, port.sum.tot))) {
    ok <- FALSE
    if(verbose) print("portfolio P&L doesn't match sum of symbols P&L")
  }
  
  initEq <- as.numeric(first(a$summary$End.Eq))
  endEq <- as.numeric(last(a$summary$End.Eq))
  
  if(!isTRUE(all.equal(port.tot, endEq - initEq)) ) {
    ok <- FALSE
    if(verbose) print("portfolio P&L doesn't match account P&L")
  }
  
  if(sum(duplicated(index(p$summary)))) {
    ok <- FALSE
    if(verbose)print("duplicate timestamps in portfolio summary")
    
  }
  
  if(sum(duplicated(index(a$summary)))) {
    ok <- FALSE
    if(verbose) print("duplicate timestamps in account summary")
  }
  return(ok)
}


# Grupos de ações ####
#
# Most our strategies will use three ETF’s: IWM, QQQ and SPY. 
# This is only for demonstration purposes. They are loaded into basic_symbols().
basic_symbols <- function() {
  symbols <- c(
    "IWM", # iShares Russell 2000 Index ETF
    "QQQ", # PowerShares QQQ TRust, Series 1 ETF
    "SPY" # SPDR S&P 500 ETF Trust
  )
}

# Where we may want to test strategies on a slightly broader scale we’ll use 
# enhanced_symbols() which adds basic_symbols(), TLT and Sector SPDR ETF’s XLB, 
# XLE, XLF, XLI, XLK, XLP, XLU, XLV, and XLY.
enhanced_symbols <- function() {
  symbols <- c(
    basic_symbols(), 
    "TLT", # iShares Barclays 20+ Yr Treas. Bond ETF
    "XLB", # Materials Select Sector SPDR ETF
    "XLE", # Energy Select Sector SPDR ETF
    "XLF", # Financial Select Sector SPDR ETF
    "XLI", # Industrials Select Sector SPDR ETF
    "XLK", # Technology  Select Sector SPDR ETF
    "XLP", # Consumer Staples  Select Sector SPDR ETF
    "XLU", # Utilities  Select Sector SPDR ETF
    "XLV", # Health Care  Select Sector SPDR ETF
    "XLY" # Consumer Discretionary  Select Sector SPDR ETF
  )
}

# Lastly, we may use global_symbols() for better insight into a strategy.
# However, the purposes of this book is to show how to backtest strategies, not 
# to find profitable strategies.
global_symbols <- function() {
  symbols <- c(
    enhanced_symbols(), 
    "EFA", # iShares EAFE
    "EPP", # iShares Pacific Ex Japan
    "EWA", # iShares Australia
    "EWC", # iShares Canada
    "EWG", # iShares Germany
    "EWH", # iShares Hong Kong
    "EWJ", # iShares Japan
    "EWS", # iShares Singapore
    "EWT", # iShares Taiwan
    "EWU", # iShares UK
    "EWY", # iShares South Korea
    "EWZ", # iShares Brazil
    "EZU", # iShares MSCI EMU ETF
    "IGE", # iShares North American Natural Resources
    "IYR", # iShares U.S. Real Estate
    "IYZ", # iShares U.S. Telecom
    "LQD", # iShares Investment Grade Corporate Bonds
    "SHY" # iShares 42372 year TBonds
  )
}

