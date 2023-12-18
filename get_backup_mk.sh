#!/bin/bash

dt=$(date '+%Y-%m-%d_%H-%M')
basedir="/usr/backup/mikrotik/$dt"
dia=$(date '+%Y-%m-%d')

make_backup() {
	data=$(date '+%Y-%m-%d_%H-%M')
	mk=$1
	ip=$2
	echo "+ getting $mk $ip"
	#ping -c1 $ip
	#if [ $? != 0 ]; then exit; fi
	cd $basedir
#	ncftpget -P 1021 -u backup -p SENHA $ip $basedir backup.backup
	ncftpget -P 1021 -u backup -p SENHA $ip $basedir bkexport.rsc
	#echo "++ push backup on ftp ++"
	if [ -e Backup.backup ]; then
		mv Backup.backup backup-$mk-$data.backup
#		ncftpput -m -u backup -p SENHA ftp.a.com.br /mikrotik/$dia/ backup-$mk-$data.backup
	fi
	if [ -e bkexport.rsc ]; then
		mv bkexport.rsc bkexport-$mk-$data.rsc
#		ncftpput -m -u backup -p SENHA ftp.a.com.br /mikrotik/$dia/ bkexport-$mk-$data.rsc
	fi
	echo "---"
}

if [ ! -d $basedir ]; then
	mkdir -p $basedir
fi

make_backup "concentrador1" "10.1.2.1"
make_backup "concentrador2" "18.22.8.18"
#make_backup "" ""
#make_backup "" ""

find /usr/backup/mikrotik -maxdepth 1 -mtime +320 -type d -exec rm -rf {} \;

