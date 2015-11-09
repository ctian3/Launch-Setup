#! /bin/bash

aws elb create-load-balancer --load-balancer-name itmo544ctian-lb --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --subnets subnet-20d5860b --security-group sg-6aa5a90d


aws elb register-instances-with-load-balancer --load-balancer-name itmo544ctian-lb --instances i-666d3ed9 i-a6affc19

aws elb configure-health-check --load-balancer-name itmo544ctian-lb --health-check Target=HTTP:80/index.php,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3

sleep 300

