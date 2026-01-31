#!/bin/bash

#requirements:

#Variables Declaration
SG_ID="sg-04afc53a2f45b85cc"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0208373RVMHCU0ECIYA"
#Z0208373RVMHCU0ECIYA

DOMAIN_NAME="neelimadevops.online"

# We are creating Instance and records in Route53


for instance in $@
do 
   INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$instance'}]' \
    --query 'Instances[0].InstanceId' \
    --output text )


    if [ $instance == frontend ] ; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
            )
        RECORD_NAME="$DOMAIN_NAME"

    else
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi
    
    echo "IP Address: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '{
        "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [{"Value": "'$IP'"}]
            }
        }]
    }
    '
    echo "record updated for $instance"

done
