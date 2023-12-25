#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


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

dnf install maven -y &>> $LOGFILE

VALIDATE $? "Installing maven"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi     

mkdir -p /app

VALIDATE $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip

VALIDATE $? "downloading shipping"

cd /app

VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip

VALIDATE $? "unzipping shipping"

mvn clean package

VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar

VALIDATE $? "Renaming jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service

VALIDATE $? "copying shipping service"

systemctl daemon-reload

VALIDATE $? "deamon reload"

systemctl enable shipping 

VALIDATE $? "enable shipping"

systemctl start shipping

VALIDATE $? "Start shipping"

dnf install mysql -y

VALIDATE $? "Installing MYSQL client"

mysql -h mysql.jaiaws446.online -uroot -pRoboShop@1 < /app/schema/shipping.sql 

VALIDATE $? "Loading shipping data"

systemctl restart shipping

VALIDATE $? "Restart shipping"
