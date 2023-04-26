import mysql
import time
from pymongo import MongoClient

# Single or mongo router (mongos)
client = MongoClient('194.210.86.10',

                    username='aluno',

                    password='aluno',

                    authSource='admin',

                    authMechanism='SCRAM-SHA-256')


# Repllica

client = MongoClient('localhost:27027,localhost:25017,localhost:23017', replicaSet='db_replicaset',

                     readPreference='nearest'

                     )

print("MongoDB Connection Successful")

mysqlclient = mysql.connector.connect(

   host="localhost",

   user="root",

   database="pisid",

   password=""

)

print("Mysql Connection Successful")

mydb = client["bdteste"]

mycol = mydb["collectionteste"]

mycursor = mysqlclient.cursor()

counter = 0

for x in mycol.find():
    print(x)

    # xaux = datetime.strptime('2023-03-16 14:32:13.904208', '%Y-%m-%d %H:%M:%S.%f')
    #
    # if(datetime.strptime(x['Hora'], '%Y-%m-%d %H:%M:%S.%f') > xaux):
    #    print(datetime.strptime(x['Hora'], '%Y-%m-%d %H:%M:%S.%f'))
    #
    # vetoraux = x.split("'")
    # vetorauxaux = vetoraux[7]
    # print(vetorauxaux)
    sql = "INSERT INTO titles (primaryTitle, genres) VALUES (%s, %s)"

    val = (x["primaryTitle"], x["genres"])

    mycursor.execute(sql, val)

    time.sleep(1)  # desnecesssária esta pausa de 1 segundo, apenas para debugger

mysqlclient.commit()

mysqlclient.close()

client.close()