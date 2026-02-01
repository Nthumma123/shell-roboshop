#!/bin/bash

USER_ID=$(id -u)
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

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ] ; then
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
  validate $? "Adding roboshop user"
else
    echo "roboshop user already exists" | tee -a $LOGS_FILE     
fi

mkdir /app &>> $LOGS_FILE
validate $? "Creating /app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOGS_FILE
validate $? "Downloading user code"

cd /app &>> $LOGS_FILE
validate $? "Changing directory to /app"

unzip /tmp/user.zip &>> $LOGS_FILE
validate $? "Extracting user code"

npm install &>> $LOGS_FILE
validate $? "Installing nodejs dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>> $LOGS_FILE
validate $? "Copying user systemd service file" 

systemctl daemon-reload &>> $LOGS_FILE
validate $? "Reloading systemd daemon"


systemctl enable user   &>> $LOGS_FILE
validate $? "Enabling user service"

systemctl start user &>> $LOGS_FILE
validate $? "Starting user service"

# End of the script