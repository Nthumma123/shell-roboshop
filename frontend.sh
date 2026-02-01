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

dnf module disable nginx -y &>> $LOGS_FILE
validate $? "Disabling nginx module"

dnf module enable nginx:1.24 -y &>> $LOGS_FILE
validate $? "Enabling nginx 1.24 module"

dnf install nginx -y &>> $LOGS_FILE
validate $? "Installing nginx"


systemctl enable nginx &>> $LOGS_FILE
validate $? "Enabling nginx service"

systemctl start nginx &>> $LOGS_FILE
validate $? "Starting nginx service"


rm -rf /usr/share/nginx/html/* &>> $LOGS_FILE
validate $? "Removing default nginx content"


curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOGS_FILE
validate $? "Downloading frontend code"


cd /usr/share/nginx/html &>> $LOGS_FILE
validate $? "Changing directory to nginx html folder"

unzip /tmp/frontend.zip &>> $LOGS_FILE
validate $? "Extracting frontend code"


cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>> $LOGS_FILE
validate $? "Copying nginx configuration file"

#vim /etc/nginx/nginx.conf

systemctl restart nginx &>> $LOGS_FILE
validate $? "Restarting nginx service"

# End of the script

