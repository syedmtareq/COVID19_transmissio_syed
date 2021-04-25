# batch estimate Rt of USA counties with EpiNow2
# Hong Qin, October 29, 2020

rm(list=ls())
library(tidyverse)
library(readr)
#install.packages('EpiNow2', repos='http://cran.us.r-project.org') 
#do if enviroment and defaulty are not the same

library(EpiNow2)
library(ggplot2)
library(dplyr)
library(lubridate)

#R -f file --args startIndex end Index debug startDateMDY endDateMDY

# for example 
# R -f batch_Rt_by_county.R --args 10 15 1  '10/1/2020'  '10/15/2020'


options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)
print(args)
# trailingOnly=TRUE means that only your arguments are returned, check:
# print(commandsArgs(trailingOnly=FALSE))
start = as.integer(args[1])
end = as.integer(args[2])
debug = as.integer(args[3])

start_date = args[4]
end_date   = args[5]

countyfiles = fs::dir_ls('counties/')
countyfiles = str_subset(countyfiles, "\\.csv") # there are 2242 files 


for ( i in start:end ) {
  if (debug>0){
    print(paste( "i=", i, " input file=", countyfiles[i]) )
  }
  
  tbCounty = readr::read_csv( countyfiles[i] )
  
  local_cases = tbCounty[, c("date", "dailyCases")]
  names( local_cases ) = c("date", "confirm")
  
  local_cases <- local_cases %>% dplyr::filter( between(date, mdy(start_date), mdy(end_date)))
  local_cases$confirm[  local_cases$confirm < 0 ] = 0
  
  reporting_delay <- bootstrapped_dist_fit(rlnorm(100, log(4), 1), max_value = 30)
  generation_time <- get_generation_time(disease = "SARS-CoV-2", source = "ganyani")
  incubation_period <- get_incubation_period(disease = "SARS-CoV-2", source = "lauer")
  
  estimates <- epinow(reported_cases = local_cases, samples=100, output='samples',
                      generation_time = generation_time,
                      delays = list(incubation_period, reporting_delay))
  
  localRtTb = estimates$estimates$summarised[ estimates$estimates$summarised$variable=='R' , all=TRUE]
  
  localRtTb2 <- localRtTb %>% select(date, mean )
  names( localRtTb2 ) = c( 'date', 'Rt' )
  
  tbCounty2 = merge( tbCounty, localRtTb2, by='date', all=TRUE)
  
  currentLocation = gsub( '\\.csv', '',  countyfiles[i] )
  currentLocation = gsub( 'counties/', 'counties2/',  currentLocation )
  
  outfilename = paste( currentLocation, "_v2.csv", sep='' )
  if (debug> 0) {
    print( paste("output file to", outfilename) )
  }
  
  write_csv( tbCounty2, outfilename )
}


