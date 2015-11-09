#!/bin/bash


mapfile -t dbInstanceARR < <(aws rds describe-db-instances --output json | grep "\"DBInstanceIdentifier" | sed "s/[\"\:\, ]//g" | sed "s/DBInstanceIdentifier//g" )

if [ ${#dbInstanceARR[@]} -gt 0 ]
   then
   echo "Detceting existing RDS database-instances"
   LENGTH=${#dbInstanceARR[@]}

      for (( i=0; i<${LENGTH}; i++));
      do
      if[ [ ${dbInstanceARR[i]} == "ctian-db" ] ]
     then 
      echo "db exists"
     else
     aws rds create-db-instance --db-instance-identifier ctian-db --db-name ctiandb --db-instance-class db.t1.micro --engine MySQL --master-username controller --master-user-password letmein88 --allocated-storage 5 --vpc-security-group-ids sg-434a0a24 --availability-zone us-east-1c
      fi  
     done
fi


