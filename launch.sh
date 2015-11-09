#!/bin/bash

./cleanup.sh

#declare an array in bash
declare -a instanceARR

mapfile -t instanceARR < <(aws ec2 run-instances --image-id ami-d05e75b8 --count 3 --instance-type t2.micro --key-name itmo544-ctian --security-group-ids sg-6aa5a90d --subnet-id subnet-20d5860b --associate-public-ip-address --iam-instance-profile Name=phpdeveloperRole --user-data file://../Environment-Setup/install-env.sh --output table | grep InstanceID | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g)

echo ${instanceARR[@]}

was ec2 wait instance-running --instance-ids ${instanceARR[@]}
echo "instances are running"

ELBURL=('aws elb create-load-balancer --load-balancer-name itmo544ctian-lb --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --subnets subnet-20d5860b --security-group sg-6aa5a90d --output=text');echo $ELBURL
echo -e "\nFinished launching ELB and sleeping 25 seconds"
for i in {0..25}; do echo -ne '.';sleep 1;done
echo"\n"

aws elb register-instances-with-load-balancer --load-balancer-name itmo544ctian-lb --instances ${instanceARR[@]}

aws elb configure-health-check --load-balancer-name itmo544ctian-lb --health-check Target=HTTP:80/index.php,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3

