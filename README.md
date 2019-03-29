# aws-route53-updater

Simple script to update both Slack and a provided AWS Route53 record if a change is made to "our" external IP.

## Usage

`./monitor_external_ip_change.sh <slack incoming webhook URL> <slack channel to post to> <slack user> <route53 zone id> <fqdn to update>`

Run from cron with something like:

`*/5 * * * * /home/monitor_external_ip_change.sh https://hooks.slack.com/services/ABCDEFG/BBBBBBB/SOMEKEYGENERATED mychannel notifier R53ID98765 myrecord.mycomain.com`

## Requirements
* the AWS CLI must be pre-installed and configured with a default access key.
* The user associated with the access key must have permission to update the zone

## Sample IAM Policy

Technically list zones is not required but it's handy to be able to test the CLI basically works before submitting a change. 

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Route53ListZones",
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Route53UpdateSpecificZones",
            "Effect": "Allow",
            "Action": [
                "route53:ListResourceRecordSets",
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": "arn:aws:route53:::hostedzone/MYZONEID"
        }
    ]
}
```

