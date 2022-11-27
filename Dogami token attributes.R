library(stringr)

#Test query---------------
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
Getquery<-Query$new()$query('link', Dogamiquery)

dogami <- conn$exec(Getquery$link, variables = variable) %>%
  fromJSON(flatten = F)
str(dogami$data$token_attribute)
dim(dogami$data$token_attribute)

summary(dogami_attribute$token_id)

#So said, the API only provide with 500 records according to Objkt.com
Sys.sleep(5)  


list <- (50*i-49):(50*i)
#start of the loop------
dogami_raw =""
dogami_attribute =""
range.list = ""


for (i in 1:600) {list <- (20*i-19):(20*i)
range.list[i] = toString(range(list))
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
dogami_attribute <-rbind(dogami_attribute,dogami_attribute_sub)
Sys.sleep(0.6)
}
#End of loop-----------

dogami_attribute$token_id <-as.numeric(dogami_attribute$token_id)
dogami_attribute$id <-as.numeric(dogami_attribute$id)
dogami_attribute%>%arrange(desc(token_id),id)


test <- which(1:12000 %in% dogami_attribute$token_id) #
test



list <- c(5:10)
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
dogami_attribute <-rbind(dogami_attribute_sub)
Sys.sleep(0.6)


#end of the loop
dogami_attribute$token_id <-as.numeric(dogami_attribute$token_id)
dogami_attribute$id <-as.numeric(dogami_attribute$id)
dogami_attribute <- dogami_attribute%>%arrange(token_id,id)

#Inspection-------
summary(dogami_attribute$value == "Bronze") #There are 6020 Bronze Dogami, correct.
summary(dogami_attribute$value == "Diamond") 
summary(dogami_attribute$value == "Husky") #There are 704 Husky, correct.
summary(dogami_attribute$value == "Box" | dogami_attribute$value == "Puppy")
summary(dogami_attribute$value == "Puppy")

#To check a special Dogami by Token ID------
dogami_attribute %>% filter(dogami_attribute$token_id == 360)
dogami_attribute %>% filter(dogami_attribute$token_id == 7384)

rarity_score <- dogami_attribute %>% filter(name =='Rarity score')%>%arrange(desc(value))
rarity_score$value <-as.numeric(rarity_score$value)
head(rarity_score)
tail(rarity_score)

#Plots of attributes----------
ggplot(rarity_score, aes(value))+
  geom_histogram(bins = 30, fill = "#87CEEB", colour = "black", boundary = 35)+
  ggtitle("Distribution of Dogami rarity scores ")+
  theme_bw()
  

