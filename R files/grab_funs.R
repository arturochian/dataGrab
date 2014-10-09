# install.packages(c("jsonlite", "XML"))

shfe_grab <- function(date){
  dt.source <- paste0("http://www.shfe.com.cn/data/dailydata/kx/kx", date, ".dat")
  ori.dt <- suppressWarnings( readLines(con = dt.source, encoding = "UTF-8") )
  
  if( length("ori.dt") == 1 ) {
    return("Not a Trading Day.")
  } else{
    data <- jsonlite::fromJSON(ori.dt)$o_curinstrument
    data <- data["小计" != data$DELIVERYMONTH & "" != data$DELIVERYMONTH, ]
    names(data) <- tolower(names(data))  
    data <- transform(data, productid=stringr::str_trim(productid),
                      productname=stringr::str_trim(productname),
                      openprice=as.numeric(openprice),
                      highestprice=as.numeric(highestprice),
                      lowestprice=as.numeric(lowestprice),
                      closeprice=as.numeric(closeprice),
                      date=date)

    return(data)
  }
}

treat <- function(vec) {
  rst <- rep(NA, length(vec))
  for( i in 1:length(vec) ){
    if( vec[i] != "-" ) rst[i] <- as.integer(vec[i])
  }
  return(rst)
}

dce_grab <- function(date){
  dt.source <- paste0("http://www.dce.com.cn/PublicWeb/MainServlet?action=Pu00012_download&Pu00011_Input.trade_date=", date, "&Pu00011_Input.variety=all&Pu00011_Input.trade_type=0&Submit2=%CF%C2%D4%D8%CE%C4%B1%BE%B8%F1%CA%BD")
  data <- readLines(dt.source)
  
  if(data[1] == "") { return("Not a Trading Day.") 
  } else {
    data <- data[5:length(data)]
    data.split <- strsplit(data,"\\s+")
    data <- suppressWarnings(data.frame( do.call(rbind, data.split),stringsAsFactors=FALSE ))
    data <- subset(data, is.na( stringr::str_extract(as.character(data$X1), "小计") ) )
    data <- subset(data, as.character(data$X1) != "总计" )
    names(data) <- c("ProductName", "DeliveryMonth", "Open", "High", "Low", "Close",
                     "PreSettlementPrice", "SettlementPrice", "WinLoss", "WinLoss1",
                     "Volume", "OpenInterest", "DiffOpenInterest", "Amount")
    data <- transform(data, Open=treat(Open), High=treat(High), 
                      Low=treat(Low), Close=treat(Close),
                      Date=date)
    
    return(data)
  }
}

## 商品名称              交割月份     开盘价     最高价     最低价     收盘价   前结算价     结算价       涨跌      涨跌1        成交量        持仓量     持仓量变化             成交额  


czce_grab <- function(date){
  dt.source <- paste0("http://www.czce.com.cn/portal/exchange/", substr(date, 1, 4),  
                      "/datadaily/", date, ".txt")  
  
  data <- suppressWarnings( try( read.csv(dt.source), silent = TRUE) )
  if( inherits(z, "try-error") == TRUE ) {
    return("Not a Trading Day.")
  } else {
    data <- read.csv(dt.source, skip=1, header=FALSE, sep=",", stringsAsFactors=FALSE)
    data <- data[data$V1 != "小计" & data$V1 != "总计", ]
    names(data) <- c("IntrumentID", "PreSettlementPrice", 
                     "Open", "High", "Low", "Close", "WinLoss", 
                     "BuyHigh", "SellLow", "Volume", "OpenInterest", 
                     "SettlementPrice", "BuyVolume", "SellVolume")
    data <- transform(data, Date=date)
    return(data)
  }
}

## CZXE: 合约   昨结算 	今开盘 	最高价 	最低价 	最新价 	涨跌 	最高买 	最低卖 	成交量(手) 	持仓量 	今结算 	买盘量 	卖盘量

cffex_grab <- function(date){
  dt.source <- paste0("http://www.cffex.com.cn/fzjy/mrhq/", 
                      substr(date, 1, 6), "/", substr(date, 7, 8), "/index.xml")
  xml <- suppressWarnings( try( XML::xmlParse(dt.source,isURL = TRUE, ), silent=TRUE ) )
  if( inherits(xml, "try-error") == TRUE ){
    return("Not a Trading Day.")
  } else {
    data <- XML::xmlToDataFrame(xml,stringsAsFactors = FALSE)
    data <- transform(data, instrumentid = stringr::str_trim(instrumentid),
                      productid = stringr::str_trim(productid), date=date)
  
    return(data)
  }
}
