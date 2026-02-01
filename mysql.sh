#!/bin/bash

USER_ID = $(id -u)
LOGS_FOLDER="/var/log/learn-shell"
LOGS_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER_ID -ne 0 ] ; then
    echo -e "$R You should run this script as root user $N"
    exit 1
fi  

mkdir -p $LOGS_FOLDER

validate() {
    if [$1 -ne 0 ] ; then
        echo -e "$R FAILURE $N" | tee -a $LOGS_FILE
        echo "Refer the log file $LOGS_FILE for more information" 
        exit 1
    else
        echo -e "$G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf install mysql-server -y &>> $LOGS_FILE
validate $? "Installing mysql server"


systemctl enable mysqld &>> $LOGS_FILE
validate $? "Enabling mysqld service"

systemctl start mysqld &>> $LOGS_FILE
validate $? "Starting mysqld service"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGS_FILE
validate $? "Setting up mysql root password"