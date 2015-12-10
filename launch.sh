#!/bin/bash

#./cleanup.sh

declare -a instanceARR

mapfile -t instanceARR < <(aws ec2 run-instances --image-id ami-d05e75b8 --count 1 --instance-type t2.micro --key-name itmo544-ctian --security-group-ids sg-6aa5a90d --subnet-id subnet-20d5860b --associate-public-ip-address --iam-instance-profile Name=phpdeveloperRole --user-data file://../Environment-Setup/install-webserver.sh --output table |grep InstanceId | sed "s/|//g"| sed "s/ //g" | sed "s/InstanceId//g")
echo ${instanceARR[@]}

sleep 25;
echo "instances are running"

aws elb create-load-balancer --load-balancer-name itmo544ctian-lb --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --subnets subnet-20d5860b --security-groups sg-6aa5a90d


echo -e "\nFinished launching ELB and sleeping 25 seconds"
for i in {0..25}; do echo -ne '.';sleep 1;done
echo "\n"

aws elb register-instances-with-load-balancer --load-balancer-name itmo544ctian-lb --instances ${instanceARR[@]}

aws elb configure-health-check --load-balancer-name itmo544ctian-lb --health-check Target=HTTP:80/index.php,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3

aws autoscaling create-launch-configuration --launch-configuration-name ctian-lc --image-id ami-d05e75b8 --key-name itmo544-ctian  --security-groups sg-6aa5a90d --instance-type t2.micro --user-data file://../Environment-Setup/install-webserver.sh --iam-instance-profile phpdeveloperRole

aws autoscaling create-auto-scaling-group --auto-scaling-group-name ctian-asg --launch-configuration-name ctian-lc --load-balancer-names itmo544ctian-lb  --health-check-type ELB --min-size 3 --max-size 6 --desired-capacity 3 --default-cooldown 600 --health-check-grace-period 120 --vpc-zone-identifier subnet-20d5860b


declare -a ARN

mapfile -t ARN < <(aws sns create-topic --name mp2)
echo "this is ARN: $ARN"
aws sns set-topic-attributes --topic-arn $ARN --attribute-name DisplayName --attribute-value mp2

aws cloudwatch put-metric-alarm --alarm-name cpug30 --alarm-description "Alarm when CPU exceeds 30%" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 120 --threshold 30 --comparison-operator GreaterThanThreshold  --dimensions  Name=ctian-asg,Value=ctian-asg  --evaluation-periods 2 --alarm-actions $ARN --unit Percent
aws cloudwatch put-metric-alarm --alarm-name cpul10 --alarm-description "Alarm when CPU beneath 10%" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 10 --comparison-operator LessThanThreshold  --dimensions  Name=ctian-asg,Value=ctian-asg  --evaluation-periods 2 --alarm-actions $ARN --unit Percent

sleep 30

aws rds create-db-instance --db-name ctiandb --engine mysql --db-instance-identifier ctian-db --db-instance-class db.t1.micro --allocated-storage 5 --master-username controller --master-user-password letmein88 --vpc-security-group-ids sg-434a0a24 --availability-zone us-east-1c

sleep 700;

aws rds create-db-instance-read-replica --db-instance-identifier ctian-db-1 --source-db-instance-identifier ctian-db --db-instance-class db.t1.micro 

