# aws-route53-updater

Simple script to update both Slack and a provided AWS Route53 record if a change is made to "our" external IP.

##Usage

`./monitor_external_ip_change.sh <slack incoming webhook URL> <slack channel to post to> <slack user> <route53 zone id> <fqdn to update>`

Run from cron with something like:

`*/5 * * * * /home/monitor_external_ip_change.sh https://hooks.slack.com/services/ABCDEFG/BBBBBBB/SOMEKEYGENERATED mychannel notifier R53ID98765 myrecord.mycomain.com`

