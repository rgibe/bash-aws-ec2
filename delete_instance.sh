#!/usr/bin/env bash

# Usage: delete_instance.sh host
#HOST=${1?"Usage: $0 HOST"}

debug=eval
#debug=echo

# Arrays
########

typeset -A volumes
typeset -A instances

# Queries
#########

QOutput='--output text'
QInstanceId='--query Reservations[].Instances[].InstanceId'
QVolumeId='--query Volumes[].VolumeId'
QFilter1='--filters Name=instance-state-name,Values=running'
QFilter2='--filters Name=size,Values=2 Name=status,Values=in-use'
QFilter3='--filters Name=size,Values=2 Name=status,Values=available'
QFilter4='--filters Name=instance-state-name,Values=stopped'

# Stop Instances
################

instances=()
instances="$(aws ec2 describe-instances $QOutput $QInstanceId $QFilter1)"
#echo ${instances[*]}

for instance in ${instances[@]}; do
  $debug aws ec2 stop-instances --instance-ids $instance
  $debug aws ec2 wait instance-stopped --instance-ids $instance
  echo -e "$instance stopped\n"
done

# Detach 2G Volumes
###################

volumes=()
volumes="$(aws ec2 describe-volumes $QOutput $QVolumeId $QFilter2)"
#echo ${volumes[*]}

for volume in ${volumes[@]}; do
  $debug aws ec2 detach-volume --volume-id $volume
  $debug aws ec2 wait volume-available --volume-id $volume
  echo -e "$volume available\n"
done

# Delete 2G Volumes
###################

volumes=()
volumes="$(aws ec2 describe-volumes $QOutput $QVolumeId $QFilter3)"
#echo ${volumes[*]}

for volume in ${volumes[@]}; do
  $debug aws ec2 delete-volume --volume-id $volume
  #$debug aws ec2 wait volume-deleted --volume-id $volume
  echo -e "$volume delete\n"
done

# Terminate Instances
#####################

instances=()
instances="$(aws ec2 describe-instances $QOutput $QInstanceId $QFilter4)"
#echo ${instances[*]}

for instance in ${instances[@]}; do
  $debug aws ec2 terminate-instances --instance-ids $instance
  #$debug aws ec2 wait instance-terminated --instance-ids $instance
  echo -e "$instance terminated\n"
done
