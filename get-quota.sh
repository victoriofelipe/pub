#!/bin/sh

echo -n "Domain: "
read domain

for u in $(ls /var/vmail/$domain/); do 
	quota=$(doveadm -f flow quota get -u $u@$domain|grep STORAGE|cut -d= -f4|cut -d" " -f1)
	if [ -z $quota ]; then
		continue
	fi
	quotam=$(( $quota / 1024 ))
	if [ $quotam -gt 6420 ]; then
		printf "%30s $s: %s ++++\n" "$u" "$quotam Mb"
	elif [ $quotam -gt 4096 ]; then
		printf "%30s $s: %s ++\n" "$u" "$quotam Mb"
	else
		printf "%30s $s: %s\n" "$u" "$quotam Mb"
	fi
done
