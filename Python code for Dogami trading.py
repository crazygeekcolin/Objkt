# %%
import numpy as np
import pandas as pd
import requests
import json
from datetime import datetime
import time
from collections import Counter
import seaborn as sns

# %%
%store -r
#import the outside excel
puppies = pd.read_excel("puppies.xlsx", sheet_name="Sheet 1")
url = "https://data.objkt.com/v2/graphql"


# %%
len(puppies.token_pk)
#Metadata_2.to_excel('Metadata_2.xlsx')

# %%
'['+','.join(f'"{item}"' for item in puppies['token_id'][:5]) + ']'

# %%
data =pd.Series([])
for i in range(201):
    num = list(range(50*i,50*i+50))
    print(num)
    query = 'query MyQuery {\n  event(\n    where: {fa: {contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}, event_type: {_in: ["ask_purchase","conclude_auction", "accept_offer","accept_offer_floor"]}, token: {token_id: {_in: '+'['+'´,'.join(f'"{item}"' for item in num) + ']'+'}}}\n  ) {\n    id\n    event_type\n    price\n    timestamp\n    token_pk\n    token {\n      token_id\n    }\n    recipient_address\n    creator_address\n  }\n}\n\n'
    r = requests.post(url, json={'query': query})
    time.sleep(0.2)
    print(r.status_code)
    json_data = json.loads(r.text)
    df = pd.json_normalize(json_data, record_path=['data','event'])
    #put df into data
    data = pd.concat([data,df])



# %%
#Add the trading info ofthe Dogami not included in the loop
data1 =pd.Series([])
num = list(range(10050,10092))
query = 'query MyQuery {\n  event(\n    where: {fa: {contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}, event_type: {_in: ["ask_purchase","conclude_auction", "accept_offer","accept_offer_floor"]}, token: {token_id: {_in: '+'['+','.join(f'"{item}"' for item in num) + ']'+'}}}\n  ) {\n    id\n    event_type\n    price\n    timestamp\n    token_pk\n    token {\n      token_id\n    }\n    recipient_address\n    creator_address\n  }\n}\n\n'
r = requests.post(url, json={'query': query})
time.sleep(0.2)
print(r.status_code)
json_data = json.loads(r.text)
df = pd.json_normalize(json_data, record_path=['data','event'])
data1 = pd.concat([data1,df])
#put df into data


# %%
Ptrade = pd.concat([data,data1]) #Merge two query's data

# %%
#Ptrade = pd.DataFrame(data)
#Ptrade.to_excel("Ptrade.xlsx")

# %%
Ptrade.drop(columns=0, inplace=True)

# %%
#Process the dataframe
Ptrade['ts_new']=Ptrade['timestamp'].astype('str').apply(lambda x: datetime.strptime(x, "%Y-%m-%dT%H:%M:%S+00:00"))
Ptrade['Week']= Ptrade['ts_new'].dt.week #create a week column
Ptrade['token.token_id'] = pd.to_numeric(Ptrade['token.token_id']) #Change format to int64

# %%
Ptrade = Ptrade.merge(Metadata_2[['token_id', 'last_metadata_update']], how ='left', left_on='token.token_id', right_on='token_id') #Merge the columns to get last metadata update

# %%
#Discard sector because the column 'last_metadata_date' is not needed anamore
#The foris different in datetime.strptime(x, "%Y-%m-%dT%H:%M:%S")
#Ptrade['last_metadata_dateformat']=Ptrade['last_metadata_update'].astype('str').apply(lambda x: datetime.strptime(x, "%Y-%m-%dT%H:%M:%S"))
#Ptrade['last_metadata_date']= Ptrade['last_metadata_dateformat'].dt.date

# %%
#Add Birthday column from another table
Ptrade = Ptrade.merge(puppies[['token_id','Birthday']], left_on= 'token.token_id', right_on='token_id')

# %%
Ptrade.head()

# %%
#exclude the price = NaN record, they are unsold auctions 
Ptrade = Ptrade[Ptrade['price'].astype('str')!='nan']

# %%
Ptrade.info()

# %%
Ptrade[Ptrade['ts_new']<Ptrade['Birthday']] #These are the trades when puppies were boxes

# %% [markdown]
# How to pick the boxes number from 12000 tokens

# %%
#[i in range(1,10) for i in puppies['token_id'][:10]] # so weird, when I use this statement, it gives me all true value
a = [len(puppies[puppies['token_id'] == i+1]) ==0 for i in range(12000)] #Get a Boolean list
box=[]
for i in range(12000):
    if a[i]:
        box.extend([i+1])

# %%
[i in puppies['token_id'] for i in range(10)] #Indeed token ID do not include 0,1,2

# %%
for i in range(190):
    print(box[10*i:10*i+10])

# %%
data =pd.Series([])
for i in range(190):
    num = box[10*i:10*i+10]
    print(num)
    query = 'query MyQuery {\n  event(\n    where: {fa: {contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}, event_type: {_in: ["ask_purchase","conclude_auction", "accept_offer","accept_offer_floor"]}, token: {token_id: {_in: '+'['+','.join(f'"{item}"' for item in num) + ']'+'}}}\n  ) {\n    id\n    event_type\n    price\n    timestamp\n    token_pk\n    token {\n      token_id\n    }\n    recipient_address\n    creator_address\n  }\n}\n\n'
    r = requests.post(url, json={'query': query})
    time.sleep(0.5)
    print(r.status_code)
    json_data = json.loads(r.text)
    df = pd.json_normalize(json_data, record_path=['data','event'])
    #put df into data
    data = pd.concat([data,df])

# %%
data.head()

# %%
box = data

# %%
#Process the dataframe
box['ts_new']=box['timestamp'].astype('str').apply(lambda x: datetime.strptime(x, "%Y-%m-%dT%H:%M:%S+00:00"))
box['Week']= box['ts_new'].dt.week
box['token.token_id'] = pd.to_numeric(box['token.token_id'])
box.merge(Metadata_2[['token_id', 'last_metadata_update']], how ='left', left_on='token.token_id', right_on='token_id') #Add a column from another table
#box.drop(columns=0, inplace=True) #Drop one unnecessary column

# %%
Ptrade.columns

# %%
box.columns

# %%
#Temp variable a is the trasaction of puppies when they were boxes
a = Ptrade[['id', 'event_type', 'price', 'timestamp', 'token_pk',
       'recipient_address', 'creator_address', 'token.token_id', 'ts_new',
       'Week']][Ptrade['ts_new']<Ptrade['Birthday']]
a.head()

# %%
box = pd.concat([box, a])

# %%
pd.concat([box, Ptrade[['id', 'event_type', 'price', 'timestamp', 'token_pk',
       'recipient_address', 'creator_address', 'token.token_id', 'ts_new',
       'Week']]])


# %%
Ptrade_final = Ptrade[Ptrade['ts_new']>Ptrade['Birthday']]
#Add rarity tier and rarity score to the table
Ptrade_final = Ptrade_final.merge(puppies[['token_id','Rarity tier','Rarity score']], left_on='token_id', right_on='token_id')
#Finally we left 2794 transaction of puppies and 1869 transaction of boxes

# %%
#fix the price to original
box.price = box.price/1000000
Ptrade_final.price = Ptrade_final.price/1000000


# %%


# %% [markdown]
# Explory data analysis, plots

# %%
box.head()

# %%
#Add rarity tier and rarity score
Ptrade_final.head()

# %%


# %%
print(Counter(box['token.token_id']).most_common(6))
Counter(Ptrade_final['token_id']).most_common(6) #The most traded puppies, no too many traded


# %%
a=sns.scatterplot(box, x='Week', y='price',hue='event_type', palette='husl')
a.set(ylabel= 'Price(XTZ)',title='Dogami Box transactions history')

# %%
a = sns.histplot(box,x='Week',hue='event_type',multiple="stack",binwidth = 1)
a.set(title='Trade volume by event type(limited week)', xlim=(10, None), ylim = (0, 200))

# %%
Ptrade_final.columns

# %%
sns.scatterplot(Ptrade_final[Ptrade_final['Rarity tier']=='Bronze'], x='Week', y='price')
sns.scatterplot(Ptrade_final[Ptrade_final['Rarity tier']=='Silver'], x='Week', y='price')
sns.scatterplot(Ptrade_final[Ptrade_final['Rarity tier']=='Gold'], x='Week', y='price')
sns.scatterplot(Ptrade_final[Ptrade_final['Rarity tier']=='Diamond'], x='Week', y='price')

# %%
a = sns.boxplot(Ptrade_final[Ptrade_final['Rarity tier']=='Bronze'], x='Week', y='price')
#sns.set(rc={'figure.figsize':(8,6)})
a.set(title='Transaction of Bronze dogs')

# %%
a = sns.boxplot(Ptrade_final[Ptrade_final['Rarity tier']=='Gold'], x='Week', y='price')
a.set(title='Transaction of Gold dogs')

# %%
a = sns.scatterplot(Ptrade_final, x='Week', y='price', hue='Rarity tier')
a.set(ylim= (0,500))

# %%
Counter(Ptrade['Week']).most_common(20)

# %%


# %%


# %%
Ptrade_final.info()

# %%
box.info()

# %%


# %%
Ptrade.drop(columns=0, inplace=True)

# %%
query = """query MyQuery {
  event(
    where: {fa: {contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}, event_type: {_eq: "ask_purchase"}, token: {token_id: {_in: ["3","4"]}}}
  ) {
    id
    event_type
    price
    timestamp
    token_pk
    token {
      token_id
    }
    recipient_address
    creator_address
  }
}

"""
url = "https://data.objkt.com/v2/graphql"

# %%
r = requests.post(url, json={'query': query})
print(r.status_code)
json_data = json.loads(r.text)
type(json_data)
df = pd.json_normalize(json_data, record_path=['data','event'])
df.head()

# %%
for i in [2,3,4,5]:
    print(i in [2,3,4])

# %%
df.to_excel("df.xlsx", sheet_name='ask purchase')

# %%
df["timestamp"].apply(lambda x: datetime.strptime(x, "%Y-%m-%dT%H:%M:%S+00:00").isoformat())[1]

# %%
df.info()

# %%
query

# %%
query = 'query MyQuery {\n  event(\n    where: {fa: {contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}, event_type: {_in: ["ask_purchase","conclude_auction", "accept_offer","accept_offer_floor"]}, token: {token_id: {_in: '+'['+','.join(f'"{item}"' for item in puppies['token_id'][:5]) + ']'+'}}}\n  ) {\n    id\n    event_type\n    price\n    timestamp\n    token_pk\n    token {\n      token_id\n    }\n    recipient_address\n    creator_address\n  }\n}\n\n'


# %%


# %%



