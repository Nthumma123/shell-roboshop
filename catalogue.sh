#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/learn-shell"
LOGS_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.neelimadevops.online

if [ $USER_ID -ne 0 ] ; then
    echo -e "$R You should run this script as root user $N"
    exit 1
fi  

mkdir -p $LOGS_FOLDER

validate() {
    if [ $1 -ne 0 ] ; then
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

#Configuring the catalogue service

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ] ; then
    echo "roboshop user does not exist. Creating roboshop user" | tee -a $LOGS_FILE
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "Adding roboshop user"
else
    echo "roboshop user already exists" | tee -a $LOGS_FILE
fi

mkdir -p /app &>> $LOGS_FILE
validate $? "Creating /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGS_FILE
validate $? "Downloading catalogue code"

cd /app
validate $? "Changing directory to /app"

unzip /tmp/catalogue.zip &>> $LOGS_FILE
validate $? "Extracting catalogue code"

npm install &>> $LOGS_FILE
validate $? "Installing nodejs dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGS_FILE
validate $? "Copying catalogue systemd service file"

systemctl daemon-reload &>> $LOGS_FILE
validate $? "Reloading systemd daemon"

systemctl enable catalogue &>> $LOGS_FILE
validate $? "Enabling catalogue service"

systemctl start catalogue &>> $LOGS_FILE
validate $? "Starting catalogue service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
validate $? "Copying mongo repo"

dnf install mongodb-mongosh -y &>> $LOGS_FILE
validate $? "Installing mongodb-mongosh"

#INDEX=$(mongosh --host $MONGODB_HOST </app/db/master-data.js &>> $LOGS_FILE)
INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $INDEX -ne -1 ] ; then
    echo "Catalogue DB is already present, so skipping the schema load" | tee -a $LOGS_FILE
else
    echo "Catalogue DB is not present, so loading the schema" | tee -a $LOGS_FILE
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>> $LOGS_FILE
fi      
validate $? "Loading catalogue schema to mongodb"


systemctl restart catalogue
validate $? "Restarting catalogue service"
# End of the script