#!/bin/bash

USER_ID = $(id -u)
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
    if [$1 -ne 0 ] ; then
        echo -e "$R FAILURE $N" | tee -a $LOGS_FILE
        echo "Refer the log file $LOGS_FILE for more information" 
        exit 1
    else
        echo -e "$G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf install maven -y &>> $LOGS_FILE
validate $? "Installing maven"

id=roboshop &>> $LOGS_FILE
if [ $? -ne 0 ] ; then
    echo "roboshop user does not exist. Creating roboshop user" | tee -a $LOGS_FILE
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "Adding roboshop user"
else
    echo "roboshop user already exists" | tee -a $LOGS_FILE
fi

mkdir /app &>> $LOGS_FILE
validate $? "Creating /app directory"


curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip    &>> $LOGS_FILE
validate $? "Downloading shipping code"

cd /app     &>> $LOGS_FILE
validate $? "Changing directory to /app"

unzip /tmp/shipping.zip &>> $LOGS_FILE
validate $? "Extracting shipping code"

mvn clean package   &>> $LOGS_FILE
validate $? "Building shipping code"

mv target/shipping-1.0.jar shipping.jar &>> $LOGS_FILE
validate $? "Renaming shipping jar file"


systemctl daemon-reload &>> $LOGS_FILE 
validate $? "Reloading systemd daemon"


systemctl enable shipping &>> $LOGS_FILE
validate $? "Enabling shipping service"

systemctl start shipping &>> $LOGS_FILE
validate $? "Starting shipping service"


dnf install mysql -y &>> $LOGS_FILE
validate $? "Installing mysql client"

mysql -h $MONGODB_HOST -uroot -pRoboShop@1 < /app/db/shipping.sql   &>> $LOGS_FILE
validate $? "Loading shipping schema to mysql"

mysql -h $MONGODB_HOST -uroot -pRoboShop@1 < /app/db/schema.sql  &>> $LOGS_FILE
validate $? "Loading shipping schema to mysql"

mysql -h $MONGODB_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql  &>> $LOGS_FILE
validate $? "Loading shipping master data to mysql"


systemctl restart shipping &>> $LOGS_FILE
validate $? "Restarting shipping service"
# End of the script

