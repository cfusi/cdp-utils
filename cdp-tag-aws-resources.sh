#!/bin/bash -x

display_usage() {
 echo "
Usage:
   $(basename "$0") [--help or -h]  <prefix> <tag_name> <tag_value>
Description:
   Creates the appropriate groups for recently create env
Arguments:
   prefix:         prefix for your assets
   tag_name:       the name of the tag
   tag_value:      the value of the tag
   --help or -h:   displays this help"

}


# check whether user had supplied -h or --help . If yes display usage
if [[ ( ${1:-x} == "--help") ||  ${1:-x} == "-h" ]]
then
    display_usage
    exit 0
fi


# Check the numbers of arguments
if [ ! $# -eq 3 ]
then
    echo "Not enough arguments!" >&2
    display_usage
    exit 1
fi

prefix=$1
tag_name=$2
tag_value=$3

# Get the details of EBS instances for the prefix
tmpfile=$(mktemp /tmp/aws_XXXX)
aws ec2 describe-instances --filters Name=tag:Name,Values=${prefix}* > ${tmpfile}

# Get the EBS volume IDs
volume_ids=$(jq -r '.Reservations|.[]|.Instances[]|.BlockDeviceMappings[]|.Ebs|.VolumeId ' ${tmpfile})

# Apply the tag to the volumes
for id in ${volume_ids}
do
   echo "Setting the tag for the volume ID $id"
   aws ec2 create-tags --resources ${id} --tags 'Key='${tag_name}',Value='${tag_value}
done

# Get the list of the EBS instance ids
instance_ids=$(jq -r '.Reservations|.[]|.Instances[]|.InstanceId ' ${tmpfile})

# Apply the tag to the instances
for id in ${instance_ids}
do
   echo "Setting the tag for the EC2 instance id $id"
   aws ec2 create-tags --resources ${id} --tags Key=${tag_name},Value=${tag_value}
done

# DynamoDB table
table_name="${prefix}-cdp-table"

# Get the ARN of the table
table_arn=$(aws dynamodb describe-table --table-name ${table_name} | jq -r '.Table|.TableArn')

# Add the tag to the table
echo "Setting the tag for the Dynamo table ${table_name} ($table_arn)"
aws dynamodb tag-resource --resource-arn ${table_arn} --tags Key=${tag_name},Value=${tag_value}

rm ${tmpfile}
