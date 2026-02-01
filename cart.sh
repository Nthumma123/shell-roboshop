#!/bin/bash

USER_ID = $(id -u)
LOGS_FOLDER="/var/log/learn-shell"
LOGS_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
#MONGODB_HOST=mongodb.neelimadevops.online

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

dnf module disable nodejs -y &>> $LOGS_FILE
validate $? "Disabling nodejs module"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
validate $? "Enabling nodejs 20 module"


dnf install nodejs -y &>> $LOGS_FILE
validate $? "Installing nodejs"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ] ; then
    echo "roboshop user does not exist. Creating roboshop user" | tee -a $LOGS_FILE
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "Adding roboshop user"
else
    echo "roboshop user already exists" | tee -a $LOGS_FILE
fi  

mkdir /app &>> $LOGS_FILE
validate $? "Creating /app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip    &>> $LOGS_FILE
validate $? "Downloading cart code"

cd /app     &>> $LOGS_FILE
validate $? "Changing directory to /app"

unzip /tmp/cart.zip &>> $LOGS_FILE
validate $? "Extracting cart code"


npm install     &>> $LOGS_FILE
validate $? "Installing nodejs dependencies"


cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>> $LOGS_FILE
validate $? "Copying cart systemd service file"

systemctl daemon-reload     &>> $LOGS_FILE
validate $? "Reloading systemd daemon"

systemctl enable cart   &>> $LOGS_FILE
validate $? "Enabling cart service"

systemctl start cart    &>> $LOGS_FILE
validate $? "Starting cart service"



