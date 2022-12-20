query MyQuery {
  event(
    where: {event_type: {_eq: "ask_purchase "}, fa_contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}
    limit: 30
  ) {
    fa_contract
    id
    level
    event_type
    marketplace_event_type
  }
}

#test fa
{
  fa_contract
  id
  level
  event_type
  marketplace_event_type
  currency {
    fa_contract
  }
}
}


library(tidyverse)

mpg[mpg$manufacturer == 'audi'& mpg$year =='1999',]$hwy
a = mpg[mpg$manufacturer == 'audi'& mpg$year =1999]$hwy
a = a+1
a


for (i in meanup$Brand) {
  b<-meannp[meanup$brand = i]$meanprice
  uk.df [uk.df$Brand ==i&uk.dfPrice ==0, ]$Price <- b
  
  
}