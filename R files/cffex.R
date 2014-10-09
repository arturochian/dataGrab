library(RSQLite)
library(pipeR)
library(foreach)

source("R files/grab_funs.R")

dates <- seq(from=as.Date("2013-01-01"), to=as.Date("2014-09-30"), by=1) %>>%
  stringr::str_replace_all( pattern="-", replacement="")

conn <- dbConnect(SQLite(), "dbGrab/dbGrab.sqlite")

for( date in dates ){
  cffex <- cffex_grab(date)
  if( cffex != "Not a Trading Day." ) dbWriteTable(conn, "CFFEX", cffex, append=TRUE)
}

dbDisconnect(conn)
