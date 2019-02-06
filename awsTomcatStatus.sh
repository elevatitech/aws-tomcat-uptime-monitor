#!/bin/bash
# Verify if the host of AWS EC2 Instance
if [ -f /sys/hypervisor/uuid ] && [ `head -c 3 /sys/hypervisor/uuid` == ec2 ]; then
    echo 
else
    echo
    echo "This is not an EC2 instance, or a reverse-customized one, this package is for monitoring AWS EC2 Instance only..."
    echo
    exit;
fi

#Store all required values in variable
TOMPORT=`netstat -lnp | grep 8080|wc -l`
TOMPROC=`ps x | grep '/opt/tomcat8' | grep -v grep |wc -l`
AWS_METRIC_NAME="TomcatUptime"
EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\"`"; test -n "$EC2_INSTANCE_ID" || die 'cannot obtain instance-id'
EC2_AVAIL_ZONE="`wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone || die \"wget availability-zone has failed: $?\"`";test -n "$EC2_AVAIL_ZONE" || die 'cannot obtain availability-zone'
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
EC2_INSTANCE_NAME="`aws ec2 describe-tags --region $EC2_REGION --filters "Name=resource-id,Values=$EC2_INSTANCE_ID" "Name=key,Values=Name" --output text|cut -f5`"

if ! which aws > /dev/null; then
   echo -e "awscli not found! Please install and configure awscli with proper permissions before continuing..."
fi
#   echo -e "awscli not found! Install? (y/n) \c"
#   read
#   if "$REPLY" = "y"; then
#      sudo apt-get install awscli
#   fi
#fi

#Check if Tomcat process is running and/or Port is open

if (( $TOMPORT >= 1 ))
then
#       echo "Tomcat port 8080 is reachable"
        portval=0
else
#       echo "ERROR:Tomcat port 8080 not reachable"
        portval=1
fi

if (( $TOMPROC >= 1 ))
then
#       echo "Tomcat process is running"
        procval=0
else
#       echo "ERROR: No Tomcat process found"
        procval=1
fi

if (( $procval >= 1 || $portval >= 1 ))
then
        AWS_VAL=1
else
        AWS_VAL=0
fi

#Just for testing
#echo procval $procval
#echo portval $portval
#echo AWS_VAL $AWS_VAL
#echo AWS_METRIC_NAME $AWS_METRIC_NAME

#push all data to CloudWatch
aws cloudwatch put-metric-data --namespace "Monitoring" --metric-name $AWS_METRIC_NAME --value $AWS_VAL --unit Count --dimensions InstanceID=$EC2_INSTANCE_ID,"Instance Name"=$EC2_INSTANCE_NAME --region $EC2_REGION
