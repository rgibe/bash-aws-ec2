#!/bin/bash

debug=eval
#debug=echo

# Create a new instance
#######################

#last 'debian-8-amd64-default' available = ami-184cc56b
Instance_config='--image-id ami-184cc56b --count 1 --instance-type t2.micro --key-name USER-key --security-groups GROUP-sg'

InstanceId="$(aws ec2 run-instances $Instance_config --output text --query 'Instances[*].InstanceId')"
echo "InstanceId = ${InstanceId}"
$debug aws ec2 wait instance-running --instance-ids $InstanceId

# TAGS
######

count=$(aws ec2 describe-tags --filters "Name=key,Values=Name" "Name=value,Values=aws-instance*" --output text|awk '{print $5}'|sort -r|head -n 1|tail -c2)
if [ -z "$count" ]; then count=1; else count=$(($count +1)); fi

$debug aws ec2 create-tags --resources $InstanceId --tags Key=Name,Value=aws-instance$count Key=stack,Value=Production

# Queries
#########

QOutput='--output text'
QFilter1='--filters Name=instance-state-name,Values=running'
QInstanceId='--query Reservations[].Instances[].InstanceId'
QPublicDnsName='--query Reservations[].Instances[].NetworkInterfaces[0].Association.PublicDnsName'
QPublicIp='--query Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp'
QAvailabilityZone='--query Reservations[].Instances[].Placement.AvailabilityZone'
QVolumeId='--query VolumeId'

# Variables
###########

PublicDnsName="$(aws ec2 describe-instances --instance-ids ${InstanceId} $QOutput $QPublicDnsName)"
echo "PublicDnsName = ${PublicDnsName}"
PublicIp="$(aws ec2 describe-instances --instance-ids ${InstanceId} $QOutput $QPublicIp)"
echo "PublicIp = ${PublicIp}"
AvailabilityZone="$(aws ec2 describe-instances --instance-ids ${InstanceId} $QOutput $QAvailabilityZone)"
echo "AvailabilityZone = ${AvailabilityZone}"
#
SSH_OPT="-oStrictHostKeyChecking=no -oBatchMode=yes -oConnectTimeout=2"
SSH="ssh -i /PATH_TO/USER-key.pem $SSH_OPT admin@$PublicDnsName"
SCP="scp -i /PATH_TO/USER-key.pem"
SUDO='/usr/bin/sudo -u root'
ROOT='/PATH_TO'

# Create Additional Volume
##########################

Volume_config="--size 2 --region eu-west-1 --availability-zone $AvailabilityZone --volume-type gp2"
Volume1=$(aws ec2 create-volume $Volume_config $QOutput $QVolumeId)
echo "Volume1 = ${Volume1}"
#Volume2=$(aws ec2 create-volume $Volume_config $QOutput $QVolumeId)
#echo "Volume2 = ${Volume2}"

$debug aws ec2 wait volume-available --volume-ids $Volume1
#$debug aws ec2 wait volume-available --volume-ids $Volume2

# Attach new volume
###################

$debug aws ec2 attach-volume --volume-id $Volume1 --instance-id $InstanceId --device /dev/xvdb
#$debug aws ec2 attach-volume --volume-id $Volume2 --instance-id $InstanceId --device /dev/xvdc

# Wait until everything is ok
#############################

$debug aws ec2 wait instance-status-ok --instance-ids $InstanceId

# Initial config
#######################

$debug $SSH $SUDO 'bash -s' < $ROOT/aws-kickstart.sh &> aws-kickstart.log
