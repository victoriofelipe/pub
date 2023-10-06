#!/bin/bash
#
# mysql_restore.sh
# 
# author: Victorio H. Felipe
# last update: 04 aug 2011

cwd="/usr/backup"
#DBPASS="" # no password
DBPASS="-pSENHA"

restore() {
	echo " + restoring $2 database... "
	cd $cwd/db/$1/$2
	for table in *; do
		if [ "X`echo $table|grep SCHEMA`" != "X" ]; then
			gunzip -c $table| mysql -u root $DBPASS;
		else
			gunzip -c $table | mysql -u root $DBPASS $2; 
		fi
	done
}

ls $cwd/db/
echo -n "choose a date: "
read date

if [ $1 == "all" ]; then
	echo " + restoring all databases "
	echo " + restoring mysql database..."
	restore $date mysql
	cd $cwd
	for dbname in `ls db/$date/`; do
		if [ $dbname == "mysql" ]; then continue; fi
		cd $cwd/db/$date
		restore $date $dbname
		cd $cwd
		sleep 2
	done
else
	ls $cwd/db/$date/
	echo -n "choose a database: "
	read dbname
	restore $date $dbname
	cd $cwd
fi


