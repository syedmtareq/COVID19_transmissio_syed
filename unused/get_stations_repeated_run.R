# get weather stations for JHU covid19 counties
#install.packages('reshape2')
#install.packages("worldmet", lib='/content')
library(tidyverse)
library(lubridate)
library(reshape2)
library(ggplot2)
library(dplyr)
library(worldmet)

outputfile = "_metaTb_2.csv"

metaTb = read_csv("_metaTb_1.csv")


for( i in 1:length(tb$Lat)){
  if ( is.na(metaTb$station[i]) ) { # only work on NA rows
    tryCatch( info <- getMeta(lat = metaTb$Lat[i], lon = metaTb$Long_[i], plot=FALSE),   
              error=function(e)  {
                print( paste("***", i,"tryCaught error:", t(metaTb[i, ])) )
                metaTb$latStation[i] = NA
                metaTb$longStation[i] = NA
                metaTb$usaf[i] = NA
                metaTb$wban[i] = NA
                metaTb$station[i] = NA
              } 
    )
    print(i)
    
    metaTb$latStation[i] = info$latitude[1]
    metaTb$longStation[i] = info$longitude[1]
    metaTb$usaf[i] = info$usaf[1]
    metaTb$wban[i] = info$wban[1]
    metaTb$station[i] = info$station[1] 
    write.csv( metaTb, file= outputfile)
  }
}

write.csv( metaTb, file= outputfile)

