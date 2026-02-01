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


dnf module disable redis -y &>> $LOGS_FILE
validate $? "Disabling redis module"

dnf module enable redis:7 -y    &>> $LOGS_FILE
validate $? "Enabling redis 7 module"

dnf install redis -y &>> $LOGS_FILE
validate $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g'/etc/redis/redis.conf &>> $LOGS_FILE
validate $? "Updating bind address in redis.conf"
sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf &>> $LOGS_FILE
validate $? "Disabling protected-mode in redis.conf"

systemctl enable redis  &>> $LOGS_FILE
validate $? "Enabling redis service"

systemctl start redis   &>> $LOGS_FILE
validate $? "Starting redis service"

# End of the script

