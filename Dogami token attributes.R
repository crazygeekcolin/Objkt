library(ggpubr)
library(stringr)
library(tidyr)
library(RColorBrewer)
library(lubridate)
library(fastDummies)
library(openxlsx)




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
print(list)
string1<- sprintf('"%s"', list)
print(string1)
writeLines(toString(string1)) #What it shows in the Graphql query
#string1[2] <- substring(string1[2],1, nchar(string1[2])-1) #Delete ","


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
dogami_attribute <- dogami_attribute%>%filter(!is.na(dogami_attribute$token_id))

#Inspection-------
summary(dogami_attribute$value == "Bronze") #There are 6020 Bronze Dogami, correct.
summary(dogami_attribute$value == "Diamond") 
summary(dogami_attribute$value == "Husky") #There are 704 Husky, correct.
summary(dogami_attribute$value == "Box" | dogami_attribute$value == "Puppy") #Total 12000tokens
summary(dogami_attribute$value == "Puppy")

#To check a special Dogami by Token ID------
dogami_attribute %>% filter(dogami_attribute$token_id == 360)
dogami_attribute %>% filter(dogami_attribute$token_id == 7384)

rarity_score <- dogami_attribute %>% filter(name =='Rarity score')%>%arrange(desc(value))
rarity_score$value <-as.numeric(rarity_score$value)
head(rarity_score)
tail(rarity_score)


#Reorganize the attribute table-------  
puppies <- dogami_attribute %>% filter(dogami_attribute$value == "Puppy")
puppies_id <- puppies$token_id
puppies <- dogami_attribute %>% 
  filter(dogami_attribute$token_id %in% puppies_id) %>% 
  select(c(-1,-2))
#To check success exclude Boxes
Boxes <- (nrow(dogami_attribute)-nrow(puppies))/2

head(puppies)
unique(puppies$name)
#temp <- puppies%>%pivot_wider(id_cols = token_id, names_from = name, values_from = value)
puppies <- puppies%>%spread(key= name, value = value, convert =T)%>%arrange(token_id)
str(puppies)

#Draw the plots, Rarity tier---------
names(puppies)
summary(puppies$`Rarity score`)

ggplot(puppies, aes(`Rarity score`,fill = `Rarity tier`))+ 
  geom_histogram(bins = 30, colour = "black", boundary = 35)+
  scale_fill_brewer(palette= "Set2")+
  ggtitle("Distribution of Dogami rarity scores ")+
  theme_bw()

puppies%>% count(Birthday, sort = T)
# ggplot(puppies, aes(x= `Rarity tier`,y=`Rarity score`, fill = `Rarity tier`))+
#   geom_boxplot()+
#   scale_fill_brewer(palette= "Set2")
#   ggtitle("Distribution of Dogami rarity scores")+
#   theme_bw()
  
ggboxplot(puppies, x="Rarity tier" ,y="Rarity score", order =c("Bronze","Silver","Gold","Diamond"), fill = "Rarity tier")+
  scale_fill_brewer(palette= "Set2")+
  ggtitle("Distribution of Dogami rarity scores")+
  theme_bw()
ggboxplot(puppies, x="Rarity tier" ,y="Rarity score", order =c("Bronze","Silver","Gold","Diamond"), fill = "Generation")+
  scale_fill_brewer(palette= "Dark2")+
  ggtitle("Distribution of Dogami rarity scores")+
  theme_bw()
ggboxplot(puppies, x="Rarity tier" ,y="Rarity score", order =c("Bronze","Silver","Gold","Diamond"), fill = "Gender")+
  scale_fill_brewer(palette= "Dark2")+
  ggtitle("Distribution of Dogami rarity scores by Gender")+
  theme_bw()

#illustrate geom_col------
head(puppies)
temp <-puppies%>% 
  group_by(Generation)%>%
  count(Birthday, sort = T)

temp <- temp[1:8,]%>%
  arrange(desc(n))
temp
temp%>%
  ggplot(aes(x= factor(as.character(Birthday),levels = as.character(Birthday)),n, fill = Generation,))+
  geom_col()+
  scale_fill_brewer(palette= "Set2")+
  ggtitle("In which date tokens are minted? (8 highest dates)")+
  xlab("Mint date")
  theme_bw()


temp<-puppies%>%
  count(`Fur color`, sort=T)%>%
  arrange(n)
temp<-temp[(nrow(temp)-7):nrow(temp),]
temp%>%
  ggplot(aes(x=factor(`Fur color`, levels = `Fur color`), n, fill = `Fur color`))+
   geom_col()+
  scale_fill_brewer(palette= "Set3")+
  ggtitle("Fur color count")+
  theme_bw()


#Equation--------
puppies<-dummy_cols(puppies, select_columns = "Rarity tier")
dataf <- dummy_cols(dataf, select_columns = 'rank')

#Simple linear regression
lm1<- lm(`Rarity score`~ Friendliness+ Intelligence + Obedience + Strength + Vitality 
         + `Rarity tier_Diamond`+`Rarity tier_Gold`+`Rarity tier_Silver`
         , data = puppies)
summary(lm1)
head(puppies)

puppies_Bronze<- puppies %>% filter(`Rarity tier`== "Bronze")
puppies_Silver<- puppies %>% filter(`Rarity tier`== "Silver")
lm_bronze<- lm(`Rarity score`~ Friendliness+ Intelligence + Obedience + Strength + Vitality 
               , data = puppies_Bronze)
summary(lm_bronze)

lm_silver<- lm(`Rarity score`~ Friendliness+ Intelligence + Obedience + Strength + Vitality 
               , data = puppies_Silver)
summary(lm_silver)

lm_gold<- lm(`Rarity score`~ Friendliness+ Intelligence + Obedience + Strength + Vitality 
               , data = puppies[puppies$`Rarity tier`== "Gold",])
summary(lm_gold)


lm_diamond<- lm(`Rarity score`~ Friendliness+ Intelligence + Obedience + Strength + Vitality 
             , data = puppies[puppies$`Rarity tier`== "Diamond",])
summary(lm_diamond)

#Plots of characters
names(puppies)
ggboxplot(puppies, x="Friendliness" ,y="Rarity score", fill = "Friendliness")+
  scale_fill_brewer(palette= "Set3")+
  ggtitle("Distribution of Dogami rarity scores")+
  theme_bw()

ggboxplot(puppies, x="Intelligence" ,y="Rarity score", fill = "Intelligence")+
  scale_fill_brewer(palette= "Set3")+
  ggtitle("Distribution of Dogami rarity scores")+
  theme_bw()

ggboxplot(puppies, x="Vitality" ,y="Rarity score", fill = "Vitality")+
  scale_fill_brewer(palette= "Set3")+
  ggtitle("Distribution of Dogami rarity scores")+
  theme_bw()

ggboxplot(puppies, x="Strength" ,y="Rarity score", fill = "Strength")+
  scale_fill_brewer(palette= "Set3")+
  ggtitle("Distribution of Dogami rarity scores")+
  theme_bw()

write.xlsx(puppies,file = "puppies")
?write.xlsx
