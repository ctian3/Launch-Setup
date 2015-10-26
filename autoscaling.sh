#!/bin/bash

aws autoscaling create-launch-configuration --launch-configuration-name ctian-lc --image-id ami-d05e75b8 --key-name itmo544-ctian  --security-groups sg-6aa5a90d --instance-type t2.micro --user-data file://../Environment-Setup/install-webserver.sh --iam-instance-profile phpdeveloperRole

aws autoscaling create-auto-scaling-group --auto-scaling-group-name ctian-asg- --launch-configuration-name ctian-lc --load-balancer-names itmo544ctian-lb  --health-check-type ELB --min-size 1 --max-size 3 --desired-capacity 2 --default-cooldown 600 --health-check-grace-period 120 --vpc-zone-identifier subnet-20d5860b
