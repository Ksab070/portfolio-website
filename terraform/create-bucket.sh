#!/bin/bash

<<INFO
 Run this script before terraform init, to create the bucket and the key, else initialization will fail
INFO

BUCKETNAME="prod-tfstate-crc"
FOLDER="prod/"
REGION="us-east-1"

echo "=================="
echo -e "Creating bucket \n"
aws s3api create-bucket --bucket $BUCKETNAME --region $REGION
echo -e "\nBucket Creation complete"
echo -e "================== \n"

echo "=================="
echo -e "Enabling versioning \n"
aws s3api put-bucket-versioning --bucket $BUCKETNAME --versioning-configuration Status=Enabled
echo "Versioning Enabled successfully"
echo -e "================== \n"

echo "=================="
echo -e "Creating prod folder \n"
aws s3api put-object --bucket $BUCKETNAME --key $FOLDER
echo -e "\nFolder creation successful, exiting script"
echo -e "================== \n"

exit 0