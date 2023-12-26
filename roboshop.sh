#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-07f4d0b903a441148
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z10372153VP4FHZWVXZOQ
DOMAIN_NAME="jaiaws446.online"


for i in "${INSTANCES[@]}"
do

      if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
      then
            INSTANCE_TYPE="t3.small"
      else
            INSTANCE_TYPE="t2.micro"
      fi
         IP_ADDRESS=$(aws ec2 run-instances --image-id ami-03265a0778a880afb --count 1 --instance-type $INSTANCE_TYPE --security-group-ids sg-07f4d0b903a441148 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
        
        echo "$i: $IP_ADDRESS"


        aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '
       {
            "Comment": "Creating a record set for cognito endpoint"
            ,"Changes": [{
            "Action"              : "CREATE"
            ,"ResourceRecordSet"  : {
                "Name"              : "'$i'.'$DOMAIN_NAME'"
                ,"Type"             : "A"
                ,"TTL"              : 1
                ,"ResourceRecords"  : [{
                    "Value"         : "'$IP_ADDRESS'"
               }]
            }
            }]
        }
            '
       
done 