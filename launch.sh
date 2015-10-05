#!/bin/bash

echo "Please enter ami image id:"
read id
echo "Please enter cout:"
read cnt
echo "Please enter instance type:"
read type
echo "Please enter security group:"
read sg
echo "Please enter subnet id:"
read sn
echo "Please enter key name:"
read key

aws ec2 run-instances --image-id $id --count $cnt --instance-type $type --security-group-ids $sg --subnet-id $sn --key-name $key --associate-public-ip-address --user-data file:..//Environment-Setup/install-env.sh --debug

