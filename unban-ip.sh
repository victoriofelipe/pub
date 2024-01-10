#!/bin/bash

FBC="fail2ban-client"

IP=$1
if [ $# -lt 1 ]; then
	echo -n "Enter IP: "
	read IP
fi

for BLK_LIST in postfix-iredmail dovecot-iredmail roundcube-iredmail nginx; do
	r=$(${FBC} status ${BLK_LIST} |grep ${IP})
	if [ ! -z "$r" ]; then
		echo "found in ${BLK_LIST}... removing..."
		${FBC} set ${BLK_LIST} unbanip ${IP}
	else
		echo "not found in ${BLK_LIST}."
	fi
done

echo "done."