library(stringr)

Dogamiquery<-'query MyQuery {
  token_attribute(
    where: {token: {fa: {contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}, token_id: {_in: ["1","2"]}}}
  ) {
    id
    attribute_id
    attribute {
      id
      type
      value
      name
    }
    token {
      token_id
    }
    token_pk
  }
}
'
Getquery<-Query$new()$query('link', string2)

dogami <- conn$exec(Getquery$link, variables = variable) %>%
  fromJSON(flatten = F)
str(dogami)

names(dogami$data$token_attribute$attribute)
dim(dogami$data$token_attribute$attribute)
dim(dogami$data$token)
doga_attribute <- dogami$data$token_attribute$attribute
summary(doga_attribute$id)


#So said, the API only provide with 500 records according to Objkt.com
Sys.sleep(5)  

#start of the loop------
dogami_attribute =""
for (i in ) {
  
}
list <- c(1:5)
string1<- sprintf('"%s"', list)
#string1[2] <- substring(string1[2],1, nchar(string1[2])-1) #Delete ","
writeLines(toString(string1))

string2 <-sprintf('query MyQuery {
  token_attribute(
    where: {token: {fa: {contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}, token_id: {_in: [%s]}}}
  ) {
    id
    attribute_id
    attribute {
      id
      type
      value
      name
    }
    token {
      token_id
    }
    token_pk
  }
}', toString(string1))

Getquery<-Query$new()$query('link', string2)

dogami <- conn$exec(Getquery$link, variables = variable) %>%
  fromJSON(flatten = F)

str(dogami$data$token_attribute)
dogami_attribute_sub <- dogami$data$token_attribute$attribute
dogami_attribute_sub$token_id <-dogami$data$token_attribute$token$token_id
dogami_attribute_sub$token_pk <-dogami$data$token_attribute$token_pk
dogami_attribute <-cbind(dogami_attribute_sub)
Sys.sleep(0.6)

#end of the loop
dogami_attribute %>% arrange(token_id, id)

arrange(mtcars, cyl, disp)
dogami_1$token$token_id
