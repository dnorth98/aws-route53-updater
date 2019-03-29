#!/bin/bash

slack_url=$1
channel=$2
username=$3
r53zoneid=$4
fqdn=$5

ipfile='/tmp/ipaddress'

#
# Functions
#
update_route53() {
    zoneid=$1
    fqdn=$2
    ip=$3

    # Create changeset file
    cat << EOF > /tmp/r53_change.$$.json
{
    "Comment": "Updated by monitor_external_ip_change",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "$fqdn",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [
                    {
                        "Value": "$ip"
                    }
                ]
            }
        }
    ]
}
EOF

    aws route53 change-resource-record-sets --hosted-zone-id "$zoneid" --change-batch file:///tmp/r53_change.$$.json
    status=$?

    if [ $status -eq 0 ]; then
        rm -f /tmp/r53_change.$$.json
    else
        echo "Something went wrong updating route53"
    fi
}

#
# Mainline
#

[[ -f "$ipfile" ]] && ipold="$(< "$ipfile" )"
ipnew="$( wget -q -O - checkip.dyndns.org | sed -e 's/.*Current IP Address: //;s/<.*$//' )"

if [ -z "$ipnew" ]; then
	echo "blank new IP - will check next run"
	exit 0
fi

if [ ! -e "$ipfile" ]; then
	echo "$ipnew" > $ipfile
	ipold="$ipnew"
fi

if [[ "$ipold" != "$ipnew" ]]; then
	echo "The external IP has changed"
	echo "$ipnew" > $ipfile

	text="The external IP has changed from $ipold to $ipnew. Whitelists will need updating. $fqdn has been automatically updated"
	escapedText=$(echo "$text" | sed 's/"/\"/g' | sed "s/'/\\'/g" )

	json="{\"username\": \"$username\", \"icon_emoji\": \":heavy_exclamation_mark:\", \"channel\": \"#$channel\", \"text\": \"$escapedText\"}"

	curl -s -d "payload=$json" "$slack_url"

    update_route53 "$r53zoneid" "$fqdn" "$ipnew"
fi

