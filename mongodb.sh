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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
validate $? "Copying mongo repo"

dnf install mongodb-org -y &>> $LOGS_FILE
validate $? "Installing mongodb-org"

systemctl enable mongod &>> $LOGS_FILE
validate $? "Enabling mongod service"

systemctl start mongod &>> $LOGS_FILE
validate $? "Starting mongod service"

sed -i 's/127.0.0.1/0.0.0.0 /g' /etc/mongod.conf &>> $LOGS_FILE
validate $? "Updating bind_ip in mongod.conf"   

systemctl restart mongod &>> $LOGS_FILE
validate $? "Restarting mongod service"

# End of the script




