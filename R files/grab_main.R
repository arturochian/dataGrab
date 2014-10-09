source("R files/grab_funs.R")

dates <- seq(from=as.Date("2009-01-01"), to=as.Date("2014-10-09"), by=1) %>>%
  stringr::str_replace_all( pattern="-", replacement="")

suppressWarnings( all_grab(dates) )

suppressWarnings( today_grab() )
