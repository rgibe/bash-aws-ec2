#!/usr/bin/env bash

# 1. Check Network connectivity
###############################

ping -c 3 8.8.8.8 &> /dev/null && echo "Ping is OK" || { echo "Ping failed, check Network first"; exit; }

# 2. Configure puppetlabs repo and install puppet
#################################################

echo -e "Aggiorno /etc/apt/sources.list.d"
echo -e "deb http://apt.puppetlabs.com jessie dependencies" > /etc/apt/sources.list.d/puppetlabs-dependencies.list 
echo -e "deb http://apt.puppetlabs.com jessie main" > /etc/apt/sources.list.d/puppetlabs.list
echo -e "Aggiorno /etc/apt/preferences:"
echo -e "\n\nPackage: *\nPin: origin apt.puppetlabs.com\nPin-Priority: 750\n" > /etc/apt/preferences.d/puppetlabs.pref

echo -e "Add puppetlabs keys:"
/usr/bin/wget http://apt.puppetlabs.com/pubkey.gpg 
apt-key add pubkey.gpg
cat /etc/apt/preferences.d/puppetlabs.conf
apt-get update
echo -e "\n\nPuppet Install"
apt-get install -y puppet-common puppet

# 3. Change Hostname
####################

apt-get install -y dbus curl

echo -e "\n\nChange Hostname"
curl="curl --retry 3 --silent --show-error --fail"
instance_data_url='http://169.254.169.254/latest'

name="$($curl $instance_data_url/meta-data/public-hostname)"
hostnamectl set-hostname "$name"
echo -e "\n"; hostname

# 4. Set Timezone
#################

echo -e "\n\nSet Timezone"
export DEBIAN_FRONTEND=noninteractive
echo "Europe/Rome" > /etc/timezone && dpkg-reconfigure tzdata

# 5. Mount FS
#############

mkdir /production
mkfs.ext4 /dev/xvdb
/bin/mount -t ext4 -o defaults /dev/xvdb /production

# X. And so on
##############

# Contact puppet master
# or
# Install packages by apt
# ...

