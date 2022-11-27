#Source url: https://ropensci.org/blog/2020/12/08/accessing-graphql-in-r/

#install.packages("ghql")
#install.packages("jsonlite")
#install.packages("dplyr")

library(ghql)
library(jsonlite)
library(dplyr)
library(ggplot2)


link <- 'https://data.objkt.com/v2/graphql'
conn <- GraphqlClient$new(url = link)

#Below is the query, copied from the web. Please customise the query on the Web first
query <- '
query MyQuery {
  fa(limit: 10, distinct_on: active_auctions) {
    collection_id
    collection_type
    contract
    active_listing
  }
}'

new <- Query$new()$query('link', query)
new


result <- conn$exec(new$link, variables = variable) %>%
  fromJSON(flatten = F) #Decode from JSON project
matrix<-result$data$fa
str(result)

result$data$fa %>% 
  as_tibble()


#Another example-----

newquery<- Query$new()$query('link', 'query MyQuery {
  event(
    where: {fa_contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}, event_type: {_neq: "mint"}, recipient_address: {_eq: "tz1PX35SHSkaD9x56DKTHLdvNxY3KQ5vacCE"}}
    order_by: {timestamp: desc}
    limit: 30
  ) {
    creator {
      address
      alias
    }
    amount
    event_type
    timestamp
    price
    recipient_address
  }
}
')

newquery<- Query$new()$query('link', 'query MyQuery {
  event(
    where: {event_type: {_eq: "ask_purchase"}, fa_contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}
    limit: 30
  ) {
    fa_contract
    id
    level
    event_type
    marketplace_event_type
  }
   fa2_attribute_count {
    id
    tokens
  }
}
')


newquery<- Query$new()$query('link', 'query MyQuery {
  event(
    where: {fa_contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}, event_type: {_neq: "mint"}, recipient_address: {_eq: "tz1PX35SHSkaD9x56DKTHLdvNxY3KQ5vacCE"}}
    order_by: {timestamp: desc}
    limit: 30
  ) {
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
')


result <- conn$exec(newquery$link, variables = variable) %>%
  fromJSON(flatten = F) #Decode from JSON project
result
matrix<-result$data$event
str(result$data)


#get Dogami NFT contract info--------
Dogamiquery<-Query$new()$query('link', 'query MyQuery {
  fa(where: {contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}) {
    active_auctions
    active_listing
    category
    collection_id
    collection_type
    creator_address
    description
    editions
    floor_price
    index_contract_metadata
    items
    last_metadata_update
    ledger_type
    level
    logo
    metadata
    name
    originated
    owners
    path
    short_name
    timestamp
    token_link
    twitter
    type
    tzip16_key
    updated_attributes_counts
    verified_creators
    volume_24h
    volume_total
    website
  }
}
')


result <- conn$exec(Dogamiquery$link, variables = variable) %>%
  fromJSON(flatten = F) 
str(result$data$fa)


