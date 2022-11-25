library(stringr)
Dogamiquery<-Query$new()$query('link', 'query MyQuery {
  token(where: {fa: {contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}}) {
    artifact_uri
    average
    decimals
    description
    display_uri
    extra
    flag
    highest_offer
    is_boolean_amount
    last_listed
    last_metadata_update
    level
    lowest_ask
    metadata
    mime
    name
    ophash
    rights
    supply
    symbol
    thumbnail_uri
    timestamp
    tzip16_key
  }
  token_attribute {
    attribute {
      name
      type
      value
      id
    }
  }
}
')

dogami <- conn$exec(Dogamiquery$link, variables = variable) %>%
  fromJSON(flatten = F)
str(dogami)
names(dogami$data$token_attribute$attribute)
dim(dogami$data$token_attribute$attribute)
dim(dogami$data$token)
doga_attribute <- dogami$data$token_attribute$attribute
summary(doga_attribute$name)

grep("^S", doga_attribute$name, value = TRUE)

#So said, the API only provide with 500 records according to Objkt.com