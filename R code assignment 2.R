library(dplyr)
library(ggplot2)
library(caret)
library(AER)
library(MASS)
library(mfx)
library(corrplot)
library(gridExtra)
library(rms)
library(Hmisc)
library(survival)
library(survminer)
library(VGAM)

setwd("X:/My Downloads")
# Load data group
# For Lidia
data_total <- read.csv("C:/Users/gheor/OneDrive/Desktop/Assignment 2/yelp_oldies_a2_sample_2022.csv")
View(data_total)

#For Nektarios
data_total <- read.csv("C:/Users/gheor/OneDrive/Desktop/Assignment 2/yelp_oldies_a2_sample_2022.csv")
View(data_total)

#For Collin
data_total <- read.csv("C:/Users/gheor/OneDrive/Desktop/Assignment 2/yelp_oldies_a2_sample_2022.csv")
data_total <- read.csv("yelp_oldies_a2_sample_2022.csv")
View(data_total)

#For Catalin
data_total <- read.csv("C:/Users/gheor/OneDrive/Desktop/Assignment 2/yelp_oldies_a2_sample_2022.csv")
View(data_total)

#######################Question1_Data Exploration#################################

# user id: has only 1255 distinct values, so there are probable some dublicates
describe(data_total)


# duplicates, there are 745 duplicated records
dup <- duplicated(data_total)
summary(dup)
dup
data_cleaned <- data_total[!dup,]

# check for missing values
sort(sapply(data_cleaned, function(x) sum(is.na(x))))

# 1255 distinct user_ids
# review_count between 1 and 2277, mean=133.9 and median = 45
# yelping_since: from  2005-05-15 until 2010-12-31
# yelping_since_year: from 2005 until 2010, in 2005 there were only 5 user this goes up quickly each year to 632 users in 2010
# useful: mean=372.5 and median=57, mean and median quite far apart from each other
# funny: mean=196 and median=15, mean and median quite far apart from each other
# cool: mean=230 and median=16, mean and median quite far apart from each other
# elite: dummy 1 (member yes) / 0 (member no)
# first_elite: 895 missing values: not every member became an elite member, only 360 members became elite member.
#             the first ones in 2006 and the last ones in 2017
describe(data_cleaned)


# Checking distribution
# Boxplot shows quite few outliners for review_count, useful, funny and cool
boxplot(data_cleaned$review_count)
boxplot(data_cleaned$useful)
boxplot(data_cleaned$funny)
boxplot(data_cleaned$cool)


# There are only 5 yelpers that started in 2005, 21 in 2006, and then it goes up to over 600 in 2010
# 2005 has no outliners because of only 5 observations
# What is visible, is that when the numbers of Yelpers increase, the average number (median) of reviews per Yelper
# in a year, decreases
data_cleaned %>% 
  dplyr::select(yelping_since_year, review_count) %>%
  mutate(yelping_since_year = as.factor(yelping_since_year)) %>%
  ggplot() +
  aes(yelping_since_year, review_count) +
  geom_boxplot(fill="#87CEEB") +
  theme_bw() 

# There are a lot of missing values for first_elite, this is because this variable has only values for yelpers that
# became Elite members, all Yelpers who did not become Elite members have missing values
data_cleaned %>% 
  dplyr::select(first_elite, elite) %>%
  mutate(first_elite = as.factor(first_elite)) %>%
  group_by(first_elite) %>%
  summarise(n = n(),
            sum = sum(elite)) %>%
  ggplot() +
  aes(first_elite, n) +
  geom_col(fill="#87CEEB") +
  theme_bw() 


# Yelpers that started in 2005 have received on average the highest number of useful votes
# the average number of useful votes per yelper decreases with each year
data_cleaned %>% 
  dplyr::select(yelping_since_year, useful) %>%
  mutate(yelping_since_year = as.factor(yelping_since_year)) %>%
  group_by(yelping_since_year) %>%
  summarise(n = n(),
            avg = mean(useful)) %>%
  ggplot() +
  aes(yelping_since_year, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() 


# Yelpers that started in 2006 have received on average the highest number of funny votes
# the average number of funny votes per yelper is approximately the same for the years 2005, 2007 and 2008
# 2009 and 2010 score lower than the other years
data_cleaned %>% 
  dplyr::select(yelping_since_year, funny) %>%
  mutate(yelping_since_year = as.factor(yelping_since_year)) %>%
  group_by(yelping_since_year) %>%
  summarise(n = n(),
            avg = mean(funny)) %>%
  ggplot() +
  aes(yelping_since_year, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() 


# Yelpers that started in 2006 have received on average the highest number of cool votes
# 2009 and 2010 score lower than the other years
data_cleaned %>% 
  dplyr::select(yelping_since_year, cool) %>%
  mutate(yelping_since_year = as.factor(yelping_since_year)) %>%
  group_by(yelping_since_year) %>%
  summarise(n = n(),
            avg = mean(cool)) %>%
  ggplot() +
  aes(yelping_since_year, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() 



# Yelpers that started in 2006 have received on average the highest number of friends 
# 2010 scores lower than the other years
data_cleaned %>% 
  dplyr::select(yelping_since_year, number_friends) %>%
  mutate(yelping_since_year = as.factor(yelping_since_year)) %>%
  group_by(yelping_since_year) %>%
  summarise(n = n(),
            avg = mean(number_friends)) %>%
  ggplot() +
  aes(yelping_since_year, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() 


# Elite member have on average way more friends than non-elite memebers 
data_cleaned %>% 
  dplyr::select(elite, number_friends) %>%
  mutate(elite = as.factor(elite)) %>%
  group_by(elite) %>%
  summarise(n = n(),
            avg = mean(number_friends)) %>%
  ggplot() +
  aes(elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() 

# elite members that are elite members for 9-11 year have on avarage the highest amount of friends 
data_cleaned %>% 
  filter(elite==1) %>%
  dplyr::select(nyears_elite, number_friends) %>%
  mutate(nyears_elite = as.factor(nyears_elite)) %>%
  group_by(nyears_elite) %>%
  summarise(n = n(),
            avg = mean(number_friends)) %>%
  ggplot() +
  aes(nyears_elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() 

# there is not a clear difference between the average amount of stars 'newer' and 'older' elite members receive  
data_cleaned %>% 
  filter(elite==1) %>%
  dplyr::select(nyears_elite, average_stars) %>%
  mutate(nyears_elite = as.factor(nyears_elite)) %>%
  group_by(nyears_elite) %>%
  summarise(n = n(),
            avg = mean(average_stars)) %>%
  ggplot() +
  aes(nyears_elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() 


# there is not a clear difference between the average amount of stars elite  and non-elite members receive  
data_cleaned %>% 
  dplyr::select(elite, average_stars) %>%
  mutate(elite = as.factor(elite)) %>%
  group_by(elite) %>%
  summarise(n = n(),
            avg = mean(average_stars)) %>%
  ggplot() +
  aes(elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw()


# elite members that are elite members for 9-11 year have on avarage the highest amount of useful votes 
data_cleaned %>% 
  filter(elite==1) %>%
  dplyr::select(nyears_elite, useful) %>%
  mutate(nyears_elite = as.factor(nyears_elite)) %>%
  group_by(nyears_elite) %>%
  summarise(n = n(),
            avg = mean(useful)) %>%
  ggplot() +
  aes(nyears_elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() 


#  Elite member have on average way more useful votes than non-elite memebers
data_cleaned %>% 
  dplyr::select(elite, useful) %>%
  mutate(elite = as.factor(elite)) %>%
  group_by(elite) %>%
  summarise(n = n(),
            avg = mean(useful)) %>%
  ggplot() +
  aes(elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw()


# elite members that are elite members for 9-11 year have on average the highest numver of fans 
data_cleaned %>% 
  filter(elite==1) %>%
  dplyr::select(nyears_elite, fans) %>%
  mutate(nyears_elite = as.factor(nyears_elite)) %>%
  group_by(nyears_elite) %>%
  summarise(n = n(),
            avg = mean(fans)) %>%
  ggplot() +
  aes(nyears_elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() +
  labs(title='Average amount of fans elite members have per\nhow many years they have been an elite member')


#  Elite member have on average way more fans than non-elite members
data_cleaned %>% 
  dplyr::select(elite, fans) %>%
  mutate(elite = as.factor(elite)) %>%
  group_by(elite) %>%
  summarise(n = n(),
            avg = mean(fans)) %>%
  ggplot() +
  aes(elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw()


# elite members that are elite members for 11-12 years have on average the highest number of negative reviews 
data_cleaned %>% 
  filter(elite==1) %>%
  dplyr::select(nyears_elite, negreviews) %>%
  mutate(nyears_elite = as.factor(nyears_elite)) %>%
  group_by(nyears_elite) %>%
  summarise(n = n(),
            avg = mean(negreviews)) %>%
  ggplot() +
  aes(nyears_elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() +
  labs(title='Average amount of negative reviews for elite members have per\nhow many years they have been an elite member')


#  Elite member have on average way more negative reviews than non-elite members
data_cleaned %>% 
  dplyr::select(elite, negreviews) %>%
  mutate(elite = as.factor(elite)) %>%
  group_by(elite) %>%
  summarise(n = n(),
            avg = mean(negreviews)) %>%
  ggplot() +
  aes(elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw()


# elite members that are elite members for 11-12 years have on average the highest number of negative reviews 
data_cleaned %>% 
  filter(elite==1) %>%
  dplyr::select(nyears_elite, posreviews) %>%
  mutate(nyears_elite = as.factor(nyears_elite)) %>%
  group_by(nyears_elite) %>%
  summarise(n = n(),
            avg = mean(posreviews)) %>%
  ggplot() +
  aes(nyears_elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() +
  labs(title='Average amount of positive reviews elite members\nhave per how many years they have been an elite member')


#  Elite member have on average way more fans than non-elite members
data_cleaned %>% 
  dplyr::select(elite, posreviews) %>%
  mutate(elite = as.factor(elite)) %>%
  group_by(elite) %>%
  summarise(n = n(),
            avg = mean(posreviews)) %>%
  ggplot() +
  aes(elite, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw()



#  from the Yelpers that started in 2005, 100%(out of 5) became an elite member
#  from the Yelpers that started in 2006, 62% (out of 21)became an elite member
#  from the Yelpers that started in 2007, 39% (out of 77)became an elite member
#  from the Yelpers that started in 2008, 43% (out of 143)became an elite member
#  from the Yelpers that started in 2009, 32% (out of 377)became an elite member
#  from the Yelpers that started in 2010, 20% (out of 632)became an elite member
data_cleaned %>% 
  dplyr::select(elite, yelping_since_year) %>%
  group_by(yelping_since_year) %>%
  summarise(n = n(),
            avg = mean(elite)) %>%
  ggplot() +
  aes(yelping_since_year, avg) +
  geom_col(fill="#87CEEB") +
  theme_bw() +
  scale_y_continuous(limits = c(0,1), breaks = seq(0, 1,0.1), labels = scales::percent)

#######################Question2#################################

# yelp's management is interested in learning about which variables affect the timing of a customer becoming an elite member
# elite member: elite
# timing: first_elite
# Dependent variables are two elements: Time (when someone became an elite member), and Event (Did someone become an elite member?)
# so dependent variables are first_elite and elite


# create dataset model1
# create new variable for the time (first_elite) so that the model can handle it 
# (starting with 1 until 15, instead of 2006 until 2019)
datasetmodel.1 <- data_cleaned %>% 
  dplyr::select(elite, first_elite, yelping_since_year) %>%
  mutate(first_elite_modified = ifelse(is.na(first_elite), 2019, first_elite),
         first_elite_modified = cut(first_elite_modified, breaks = c(2005:2019), labels = c(1:14)),
         first_elite_modified = ifelse(first_elite_modified==14, 15, first_elite_modified),
         first_elite_modified = as.numeric(first_elite_modified))


ggplot(datasetmodel.1, aes(x=first_elite_modified)) + geom_bar(fill = '#0073C2FF')

KMSurvivalCurve.1 <- survfit(Surv(first_elite_modified, elite) ~1, data = datasetmodel.1)
ggsurvplot(KMSurvivalCurve.1, data=datasetmodel.1)
summary(KMSurvivalCurve.1)

# create dataset model2
datasetmodel.2 <- data_cleaned %>% 
  dplyr::select(elite, first_elite, yelping_since_year) %>%
  mutate(yelping_since_year = as.factor(yelping_since_year),
         first_elite_modified = ifelse(is.na(first_elite), 2019, first_elite),
         first_elite_modified = cut(first_elite_modified, breaks = c(2005:2019), labels = c(1:14)),
         first_elite_modified = ifelse(first_elite_modified==14, 15, first_elite_modified),
         first_elite_modified = as.numeric(first_elite_modified))

KMSurvivalCurve.2 <- survfit(Surv(first_elite_modified, elite) ~ yelping_since_year, data = datasetmodel.2)
ggsurvplot(KMSurvivalCurve.2, data=datasetmodel.2, pval = T)
summary(KMSurvivalCurve.2)

survdiff(Surv(first_elite_modified, elite) ~ yelping_since_year, data = datasetmodel.2, rho = 0)

# Estimation of cox model
# create dataset model2
datasetmodel.3 <- data_cleaned %>% 
  dplyr::select(elite, first_elite, posreviews, negreviews, review_count, fans) %>%
  mutate(posreviews5ormore = ifelse(posreviews >= 5, 1, 0),
         negreviews = ifelse(negreviews >= 5, 1, 0),
         hasfans = ifelse(fans > 0, 1, 0),
         first_elite_modified = ifelse(is.na(first_elite), 2019, first_elite),
         first_elite_modified = cut(first_elite_modified, breaks = c(2005:2019), labels = c(1:14)),
         first_elite_modified = ifelse(first_elite_modified==14, 15, first_elite_modified),
         first_elite_modified = as.numeric(first_elite_modified))

CoxModel.1 <- coxph(Surv(first_elite_modified, elite) ~ posreviews5ormore + hasfans + 
                      negreviews + review_count, 
                    method = 'efron', 
                    data = datasetmodel.3)

# concordance > 0.7, so thats good
summary(CoxModel.1)

# interpretation:
# posreview5ormore has a positive effect on being an elite member
# hazard rate change with 81%
100*(exp(CoxModel.1$coefficients[[1]])-1)
# odds to become an elite for someone who has given 5 or more positive reviews, 
# compared to someone who has not given 5 or more positive reviews is 1.81:1
# or a 81% higher  probability to become an elite member in a particular year

# fans has a positive effect on being an elite member
# hazard rate change with 1834%
100*(exp(CoxModel.1$coefficients[[2]])-1)
# odds to become an elite for someone who has fans, compared to someone who 
# does not have fans is 19.34:1
# or a 1834% higher probability to become an elite member in a particular year

# negreview not a significant effect on becoming an elite member

# fans has a positive effect on being an elite member
# hazard rate changes with 0.18% with each unit increase of review_count 
100*(exp(CoxModel.1$coefficients[[4]])-1)
# odds to become an elite member in a particular year, increases with 0.18% 
# with each extra review a yelper writes


# proportionality for continuous variable review_count
proptest <- cox.zph(CoxModel.1, global=T)
print(proptest)

# review_count: looks like a strait line 
plot(proptest)

###########Question 4-- basic analysis and plot#########
data4<-data_cleaned
names(data4)


summary(data4$number_friends) # There are outliers in ntips and number of friends, and fans, thus it cut 
data4%>%
  ggplot(aes(number_friends))+
  geom_boxplot()
data4%>%
  ggplot(aes(fans))+
  geom_boxplot()
summary(data4$fans)


barplot(data4$ntips)

data4<-data_cleaned
data4%>%
  filter(number_friends<2000)%>%
  ggplot(aes(number_friends, review_count))+
  geom_point()

data4%>% # fans and friends should be consider
  filter(fans<200)%>%
  ggplot(aes(fans, ntips))+
  geom_point()

data4%>% #Years of elite member has impact on average review
  group_by(nyears_elite,)%>%
  summarise(avg_review=mean(nreviews))%>%
  ggplot(aes(nyears_elite, avg_review))+
  geom_point()

data4%>% #Years of elite member seems do not have impact on number of tips, but we will include it into models
  group_by(nyears_elite,)%>%
  summarise(avg_tips=mean(ntips))%>%
  ggplot(aes(nyears_elite, avg_tips))+
  geom_point()


data4%>%
  ggplot(aes(avg_rest_stars_rev, ntips))+
  geom_point()

data4%>% #from the plot it seems avg_rest_stars_rev has positive effect on count of tips and review
  ggplot(aes(avg_rest_stars_rev, review_count))+
  geom_point()


data4%>% #from the plot there is no obvious evidence for positive relationship
  ggplot(aes(compliment_count_tips, ntips))+
  geom_point()

data4%>%
  ggplot(aes(compliment_count_tips, review_count))+
  geom_point()

data4%>%
  ggplot(aes(review_length_med , ntips))+
  geom_point()

data4%>% #from the plot it seems avg_rest_stars_rev has positive effect on count of tips and review
  ggplot(aes(review_length_med, review_count))+
  geom_point()

#########Question 4 model############
#Since ntips and review counts is minimum 1, we should consider truncated
mean(data4$ntips)
var(data4$ntips)
mean(data4$review_count)
var(data4$review_count)
summary(data4$ntips) #We choose the truncated negative binomial model since the mean < variance

summary(data4$number_friends>500)
summary(data4$number_friends>2000)
a <- c(1:20)
table(cut(a, breaks = c(0, 1, 5, 13,18, 20), labels = c(1,2,3,4,5) ))

data4$group_num_of_friends <- cut(data4$number_friends, breaks = c(0,3,50,200,500,Inf), labels = 1:5)
table(cut(data4$number_friends, breaks = c(0,3,50,200,500,Inf), labels = 1:5))

data4$number_friends1<-ifelse(data4$number_friends>500, 500, data4$number_friends)


#Some variables are correlated, I choose one from similiar variables.
correlation::correlation(data4, select = c("number_friends","fans" ,"nyears_elite", "avg_rest_stars_rev", "review_length_med"))
data4$yelping_since_year1 <- data4$yelping_since_year-2005
summary(data4$yelping_since_year1 )

a<-vglm(nreviews~number_friends+compliment_count_tips +
          avg_rest_stars_rev,data=data4,family=posnegbinomial())
summary(a)

b<-vglm(nreviews~number_friends+compliment_count_tips + nyears_elite+
          avg_rest_stars_rev,data=data4,family=posnegbinomial())
summary(b)

c<-vglm(ntips~number_friends+compliment_count_tips +
          avg_rest_stars_rev,data=data4,family=posnegbinomial())
summary(c)

d<-vglm(ntips~number_friends+compliment_count_tips +nyears_elite+
          avg_rest_stars_rev,data=data4,family=posnegbinomial())
summary(d)

names(data4)


b<-vglm(ntips~number_friends+
          avg_rest_stars_rev,data=data4,family=posnegbinomial())



vglm(ntips~number_friends+nyears_elite+
       avg_rest_stars_rev+review_length_med,data=data4,family=posnegbinomial())



