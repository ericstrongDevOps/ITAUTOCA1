#!/bin/bash
eval `ssh-agent`
clear
#bastion script
echo 'install ansible and git and update'
sudo yum update -y
sudo yum install ansible -y
sudo yum install git -y

echo 'clone repo for ansible'
#clone in git repo for ansible
git clone https://github.com/ericstrongDevOps/Ansible.git

echo 'install pip, boto and ansible for python'
#install pip and boto
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python get-pip.py
sudo python3.6 -m pip install boto
sudo python3.6 -m pip install ansible

echo 'chmod to POC, ssh agent and add key'
sudo chmod 400 ~/environment/POC.pem

echo 'get ec2.py for dynamic inventory, update the python interpreter'
sudo wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py
sudo sed -i '1d' ec2.py
sudo sed -i '1 i\#!/usr/bin/env python3.6' ec2.py


echo 'give ec2.py executable rights and copy to /etc/ansible with the ini file'
sudo chmod +x ec2.py
sudo cp ec2.py /etc/ansible/
sudo cp ec2.ini /etc/ansible/

echo 'export aws vars'
export ANSIBLE_HOSTS=/etc/ansible/ec2.py
export EC2_INI_PATH=/etc/ansible/ec2.ini


eval `ssh-agent`
#ssh-agent bash &
ssh-add ~/environment/POC.pem
echo 'run the ec2.py list, and run a ping for all ec2 instances'
python /etc/ansible/ec2.py --list

ansible -i /etc/ansible/ec2.py -u ec2-user key_POC -m ping

echo 'run the ansible playbook to update all ec2 instances, create a user and update webservers'
#run the playbooks
ansible-playbook ~/environment/Ansible/playbook.yaml -i /etc/ansible/ec2.py
ansible-playbook ~/environment/Ansible/blue-playbook.yaml -i /etc/ansible/ec2.py
ansible-playbook ~/environment/Ansible/green-playbook.yaml -i /etc/ansible/ec2.py

#demo the swap over with blue green deployment












