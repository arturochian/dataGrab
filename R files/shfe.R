library(RSQLite)
library(pipeR)
library(foreach)

source("R files/grab_funs.R")

dates <- seq(from=as.Date("2013-01-01"), to=as.Date("2013-09-30"), by=1) %>>%
  stringr::str_replace_all( pattern="-", replacement="")

conn <- dbConnect(SQLite(), "dbGrab/dbGrab.sqlite")

for( date in dates ){
  shfe <- shfe_grab(date)
  if( shfe != "Not a Trading Day." ) dbWriteTable(conn, "SHFE", shfe, append=TRUE)  
}

dbDisconnect(conn)
