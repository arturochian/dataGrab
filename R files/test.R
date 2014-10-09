source("R files/grab_funs.R")

date <- 20140930
date <- 20130101

system.time({
  shfe <- shfe_grab(date)
  dce <- dce_grab(date)
  czce <- czce_grab(date)
  cffex <- cffex_grab(date)
})

head(shfe, 1)
names(shfe)

head(dce, 10)
names(dce)

head(czce, 10)

head(cffex)
