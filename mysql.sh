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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling current mysql version"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo

VALIDATE $? "copied mysql repo"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "installing mysql"

systemctl enable mysqld $LOGFILE

VALIDATE $? "Enabling mysql"

systemctl start mysqld $LOGFILE

VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 $LOGFILE

VALIDATE $? "Setting mysql root password"