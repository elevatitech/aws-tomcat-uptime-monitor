# aws-tomcat-uptime-monitor
##Monitor Tomcat Uptime status using AWS CloudWatch

Purpose:
  There is no straightforward way to monitor process uptime thru AWS CloudWatch. This script will help you monitor and report status code 0 (ALL OK) or 1 (Down) for tomcat process to the Cloudwatch. Look for Metric Name: TomcatUptime Under Namespace: Monitoring. Once you start getting metrics on CloudWatch, set alarm for Value 1 to alert the Downtime.
  
Prerequisite: 
  * This script works only on AWS EC2 instance
  * This script use *awscli* to push data to cloudwatch. *awscli* need to be installed.
  
Usage:
  * ```cd /opt && git clone https://github.com/elevatitech/aws-tomcat-uptime-monitor.git```
  * ```chmod +x /opt/aws-tomcat-uptime-monitor/awsTomcatStatus.sh```
  * run the command ```/opt/aws-tomcat-uptime-monitor/awsTomcatStatus.sh``` manually to test data collection on the cloudwatch
  * make an entry in /etc/crontab, change cron interval as needed
     ```
     # Tomcat Status monitor
     */5 * * * * root /opt/aws-tomcat-uptime-monitor/awsTomcatStatus.sh
     ```

Contact: 
  * neeraj@elevatitech.com
  

