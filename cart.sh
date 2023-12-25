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

mkdir -p /app

VALIDATE $? "creating app directory" 

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip

VALIDATE $? "downloading cart app" 

cd /app 

unzip -o /tmp/cart.zip

VALIDATE $? "unzipping cart" 

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies" 


#use absolute path because cart service exists there
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service

VALIDATE $? "copying cart service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "cart deamon reload" 

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enabling cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting cart" 
 







