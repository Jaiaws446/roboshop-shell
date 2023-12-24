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
        exit 1
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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling nodejs 18 ver" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodejs18" 

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi    

VALIDATE $? "creating roboshop user" 

mkdir -p /app

VALIDATE $? "creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading catalogue app" 

cd /app 

unzip -o /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue" 

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies" 


#use absolute path because catalogue service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "copying catalogue service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue deamon reload" 

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalogue" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongo repo" 

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb client" 

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue data into mongodb" 







