#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.jaiaws446.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]  
    then
        echo -e "$2 ... $R FAILED $N"
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi         
}    

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: please run this script with root user $N"
    exit 1 # you can give other than 0
else
    echo "you are root user"
fi #fi means reverse of if, indicating condition end

dnf module disable nodejs -y 

VALIDATE $? "Disabling current nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y 

VALIDATE $? "Enabling nodejs 18 ver" &>> $LOGFILE

dnf install nodejs -y 

VALIDATE $? "installing nodejs18" &>> $LOGFILE

useradd roboshop

VALIDATE $? "creating roboshop user" &>> $LOGFILE

mkdir /app

VALIDATE $? "creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading catalogue app" &>> $LOGFILE

cd /app 

unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue" &>> $LOGFILE

npm install 

VALIDATE $? "installing dependencies" &>> $LOGFILE


#use absolute path because catalogue service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "copying catalogue service file" &>> $LOGFILE

systemctl daemon-reload

VALIDATE $? "catalogue deamon reload" &>> $LOGFILE

systemctl enable catalogue

VALIDATE $? "enabling catalogue" &>> $LOGFILE

systemctl start catalogue

VALIDATE $? "starting catalogue" &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongo repo" &>> $LOGFILE

dnf install mongodb-org-shell -y

VALIDATE $? "installing mongodb client" &>> $LOGFILE

mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "Loading catalogue data into mongodb" &>> $LOGFILE







