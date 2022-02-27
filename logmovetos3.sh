#! /usr/bin/bash

#To run this script perfectly you need to install AWSCLI first and configure it using "aws configure" command with IAM user private and access keys.

CKR=$(which aws)
VAL=$1
WEBHOOK_URL= #incoming webhook URL generated from teams channel should be pasted here.
upload () {
        TITLE="Success! The file has been moved"
        COLOR="00ff00"
        TEXT="File name is $1"
        JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${TEXT}\" }"
        curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
}
failed () {
        TITLE="Failed! Unable to move the file."
        COLOR="ff0000"
        TEXT="File name is $1"
        JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${TEXT}\" }"
        curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
}

if [ -z "$VAL" ]
then
        tar -zcf file_name.tar.gz sample_file.log
else
        if [ ! -r "$VAL" ]
        then
		echo "You dont have read access! Access denied"
		failed "$1"
		exit
	elif [[ ! -w "$VAL" && ! -x "$VAL" ]]
	then
       		 while true; do
        		 read -p "You dont have enough access! Do you really want to continue?" yn
        		 case $yn in
       				 [Yy]* )  break;;
       				 [Nn]* ) failed "$1" exit;;
       				 * ) echo "Please answer yes or no.";;
   			 esac
 		 done
        else
                tar -zcf file_name.tar.gz "$1"
        fi
fi
	#aws s3 mb s3://bucketname ---this command is to create a s3 bucket uncomment it when needed.
        aws s3 mv "#location of the tar file which is needed to be moved to s3" s3://bucket_name/ #Command to move file to s3 bucket.
	AWSOPT=$(aws s3api head-object --bucket bucket_name --key file_name.tar.gz) #This command is to check whether the file is moved to s3 or not. If the file is not in s3 bucket the variable AWSOPT will be empty.
	
if [ -z "$AWSOPT" ]
then
	if [ -z "$CKR" ]
	then
		echo "please configure awscli first"
       		failed "$1"
	else
		echo "your file does not reached the destination"
		failed "$1"
	fi
else
        upload "$1"
fi
