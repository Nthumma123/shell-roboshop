#!/bin/bash

USER_ID = $(id -u)
LOGS_FOLDER="/var/log/learn-shell"
LOGS_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD


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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOGS_FILE
validate $? "Copying rabbitmq repo"

dnf install rabbitmq-server -y &>> $LOGS_FILE
validate $? "Installing rabbitmq server"

systemctl enable rabbitmq-server  &>> $LOGS_FILE
validate $? "Enabling rabbitmq service"
    
systemctl start rabbitmq-server &>> $LOGS_FILE
validate $? "Starting rabbitmq service"


rabbitmqctl add_user roboshop roboshop123 &>> $LOGS_FILE
validate $? "Adding rabbitmq user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGS_FILE
validate $? "Setting up rabbitmq user and permissions" 