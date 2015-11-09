#!/bin/bash

aws autoscaling create-launch-configuration --launch-configuration-name ctian-lc --image-id ami-d05e75b8 --key-name itmo544-ctian  --security-groups sg-6aa5a90d --instance-type t2.micro --user-data file://../Environment-Setup/install-webserver.sh --iam-instance-profile phpdeveloperRole

aws autoscaling create-auto-scaling-group --auto-scaling-group-name ctian-asg --launch-configuration-name ctian-lc --load-balancer-names itmo544ctian-lb  --health-check-type ELB --min-size 3 --max-size 6 --desired-capacity 3 --default-cooldown 600 --health-check-grace-period 120 --vpc-zone-identifier subnet-20d5860b

aws elb configure-health-check --load-balancer-name itmo544ctian-lb --health-check Target=HTTP:80/index.html,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3

aws cloudwatch put-metric-alarm --alarm-name cpug30 --alarm-description "Alarm when CPU exceeds 30%" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 30 --comparison-operator GreaterThanThreshold  --dimensions  Name=ctian-asg,Value=ctian-asg  --evaluation-periods 2 --alarm-actions ctian-asg --unit Percent
aws cloudwatch put-metric-alarm --alarm-name cpul10 --alarm-description "Alarm when CPU beneath 10%" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 10 --comparison-operator LessThanThreshold  --dimensions  Name=ctian-asg,Value=ctian-asg  --evaluation-periods 2 --alarm-actions ctian-asg --unit Percent
