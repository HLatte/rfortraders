# Algumas funcoes do IKTrading pacage que não tem mais no CRAN
# fonte: https://github.com/IlyaKipnis/IKTrading
#
#



####'Order Size: Max Dollar ####
#'@description An order sizing function that limits position size based on dollar value of the position,
#'rather than quantity of shares.
#'@param tradeSize the dollar value to transact (use negative number to sell short)
#'@param maxSize the dollar limit to the position (use negative number for short side)
#'@param integerQty a boolean whether or not to truncate to the nearest integer of contracts/shares/etc.
#'@return a quantity to order
#'@export
"osMaxDollar" <- function(data, timestamp, orderqty, ordertype, orderside,
                          portfolio, symbol, prefer="Open", tradeSize,
                          maxSize, integerQty=TRUE,
                          ...) {
    pos <- getPosQty(portfolio, symbol, timestamp)
    if(prefer=="Close") {
        price <- as.numeric(Cl(mktdata[timestamp,]))
    } else {
        price <- as.numeric(Op(mktdata[timestamp,]))
    }
    posVal <- pos*price
    if (orderside=="short") {
        dollarsToTransact <- max(tradeSize, maxSize-posVal)
        #If our position is profitable, we don't want to cover needlessly.
        if(dollarsToTransact > 0) {dollarsToTransact=0}
    } else {
        dollarsToTransact <- min(tradeSize, maxSize-posVal)
        #If our position is profitable, we don't want to sell needlessly.
        if(dollarsToTransact < 0) {dollarsToTransact=0}
    }
    qty <- dollarsToTransact/price
    if(integerQty) {
        qty <- trunc(qty)
    }
    return(qty)
}





####'Lagged ATR ####
#'@description lags ATR computation by a lag parameter for use with order-sizing functions
#'@param HLC an HLC object
#'@param n a lookback period
#'@param maType the type of moving average
#'@param lag how many periods to lag the computation
#'@return a lagged ATR calculation
#'@export
"lagATR" <- function(HLC, n=14, maType, lag=1, ...) {
    ATR <- ATR(HLC, n=n, maType=maType, ...)
    ATR <- lag(ATR, lag)
    out <- ATR$atr
    colnames(out) <- "atr"
    return(out)
}

####'osDollarATR ####
#'@description computes an order size by way of ATR quantities, as a proportion of tradeSize
#'@param orderside long or short
#'@param tradeSize a notional dollar amount for the trade
#'@param pctATR a percentage of the tradeSize to order in units of ATR. That is, if tradeSize is
#'10000 and pctATR is .02, then the amount ordered will be 200 ATRs of the security.
#'If the last observed ATR is 2, then 100 units of the security will be ordered.
#'@param maxPctATR an upper limit to how many ATRs can be held in a position; a risk limit
#'@param integerQty an integer quantity of shares
#'@param atrMod a string modifier in case of multiples of this indicator being used.
#'Will append to the term 'atr', that is, atrMod of "X" will search for a term called 'atrX'
#'in the column names of the mktdata xts object.
#'@param rebal if TRUE, and current position exceeds ATR boundaries, will automatically sell
#'@export
"osDollarATR" <- function(orderside, tradeSize, pctATR, maxPctATR=pctATR, data, timestamp, symbol,
                          prefer="Open", portfolio, integerQty=TRUE, atrMod="", rebal=FALSE, ...) {
    if(tradeSize > 0 & orderside == "short"){
        tradeSize <- tradeSize*-1
    }
    pos <- getPosQty(portfolio, symbol, timestamp)
    atrString <- paste0("atr",atrMod)
    atrCol <- grep(atrString, colnames(mktdata))
    if(length(atrCol)==0) {
        stop(paste("Term", atrString, "not found in mktdata column names."))
    }
    atrTimeStamp <- mktdata[timestamp, atrCol]
    if(is.na(atrTimeStamp) | atrTimeStamp==0) {
        stop(paste("ATR corresponding to",atrString,"is invalid at this point in time. 
               Add a logical operator to account for this."))
    }
    dollarATR <- pos*atrTimeStamp
    desiredDollarATR <- pctATR*tradeSize
    remainingRiskCapacity <- tradeSize*maxPctATR-dollarATR
    
    if(orderside == "long"){
        qty <- min(tradeSize*pctATR/atrTimeStamp, remainingRiskCapacity/atrTimeStamp)
    } else {
        qty <- max(tradeSize*pctATR/atrTimeStamp, remainingRiskCapacity/atrTimeStamp)
    }
    
    if(integerQty) {
        qty <- trunc(qty)
    }
    if(!rebal) {
        if(orderside == "long" & qty < 0) {
            qty <- 0
        }
        if(orderside == "short" & qty > 0) {
            qty <- 0
        }
    }
    if(rebal) {
        if(pos == 0) {
            qty <- 0
        }
    }
    return(qty)
}




####'HeikinAshi ####
#'@param OHLC an OHLC time series
#'@return the Heikin Ashi recomputed OHLC time series
#'@export
"heikinAshi" <- function(OHLC) {
    heikinAshi <- xts(matrix(nrow=dim(OHLC)[1], ncol=dim(OHLC)[2],0), order.by=index(OHLC))
    colnames(heikinAshi) <- c("xO","xH","xL","xC")
    heikinAshi$xO[1] <- (Op(OHLC)[1]+Cl(OHLC)[1])/2
    heikinAshi$xC <- rowMeans(OHLC)
    heikinAshi$xO <- computeHaOpen(heikinAshi$xO, heikinAshi$xC)
    
    tmp <- cbind(Hi(OHLC),Lo(OHLC),heikinAshi$xO,heikinAshi$xC)
    heikinAshi$xH <- apply(tmp,1,max)
    heikinAshi$xL <- apply(tmp,1,min)
    heikinAshi$posNeg <- 1
    heikinAshi$posNeg[heikinAshi$C < heikinAshi$O] <- -1
    return(heikinAshi)
}



####'Ichimoku ####
#'@description The ichimoku indicator, as invented by Goichi Hosoda. It has five components. 
#'\cr The turning line is the average of the highest high and highest low of the past nFast periods.
#'\cr The base line is computed the same way over the course of nMed periods.
#'\cr Span A is the average of the above two calculations, projected nMed periods into the future.
#'\cr Span B is the average of the highest high and lowest low over the past nSlow periods, also projected the same way.
#'\cr Finally, the lagging span is the close, projected backwards by nMed periods.
#'@param HLC an HLC time series
#'@param nFast a fast period of days, default 9
#'@param nMed a medium period of days, default 26
#'@param nSlow a slow period of days, default 52
#'@return The first four computations (turning line, base line, span A, span B), plotSpan (do NOT use this for backtesting, but for plotting),
#'laggingSpan, and a lagged Span A and lagged Span B for comparisons with the lagging span, as per Ichimoku strategies.
#'@export
"ichimoku" <- function(HLC, nFast=9, nMed=26, nSlow=52) {
    turningLine <- (runMax(Hi(HLC), nFast)+runMin(Lo(HLC), nFast))/2
    baseLine <- (runMax(Hi(HLC), nMed)+runMin(Lo(HLC), nMed))/2
    spanA <- lag((turningLine+baseLine)/2, nMed)
    spanB <- lag((runMax(Hi(HLC), nSlow)+runMin(Lo(HLC), nSlow))/2, nMed)
    plotSpan <- lag(Cl(HLC), -nMed) #for plotting the original Ichimoku only
    laggingSpan <- lag(Cl(HLC), nMed)
    lagSpanA <- lag(spanA, nMed)
    lagSpanB <- lag(spanB, nMed)
    out <- cbind(turnLine=turningLine, baseLine=baseLine, spanA=spanA, spanB=spanB, plotSpan=plotSpan, laggingSpan=laggingSpan, lagSpanA, lagSpanB)
    colnames(out) <- c("turnLine", "baseLine", "spanA", "spanB", "plotLagSpan", "laggingSpan", "lagSpanA","lagSpanB")
    return (out)
}



####'sigAND ####
#'@description signal AND operator for quantstrat signals.
#'@param label name of the output signal
#'@param data the market data
#'@param columns the signal columns to intersect
#'@param cross whether to only provide a true value for crossing values
#'@return a new signal column that intersects the provided columns
#'@export
"sigAND" <- function(label, data=mktdata, columns,  cross = FALSE) {
    ret_sig = NULL
    colNums <- rep(0, length(columns))
    for(i in 1:length(columns)) {
        colNums[i] <- match.names(columns[i], colnames(data))
    }
    ret_sig <- data[, colNums[1]]
    for(i in 2:length(colNums)) {
        ret_sig <- ret_sig & data[, colNums[i]]
    }
    ret_sig <- ret_sig*1
    if (isTRUE(cross)) 
        ret_sig <- diff(ret_sig) == 1
    colnames(ret_sig) <- label
    return(ret_sig)
}

