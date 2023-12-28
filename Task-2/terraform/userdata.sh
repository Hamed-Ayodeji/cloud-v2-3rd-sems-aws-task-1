#!/bin/bash

# update packages
sudo apt-get update -y

#upgrade packages
sudo apt-get upgrade -y

# install ansible prerequisites
sudo apt-get install software-properties-common -y

# add ansible repository
sudo apt-add-repository ppa:ansible/ansible -y

# install ansible
sudo apt-get update -y

# install openssh-server
sudo apt-get install openssh-server -y

# enable ssh
sudo systemctl enable ssh

# start ssh
sudo systemctl start ssh

# update packages
sudo apt-get update -y

# create a new directory in home directory
mkdir /home/ubuntu/ansible

# change directory to ansible
cd /home/ubuntu/ansible