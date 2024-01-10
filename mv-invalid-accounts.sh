#!/bin/sh
#
# Find maildir which no longer exists in database
#
# author: Victo'rio H. Felipe - victoriofelipe@outlook.com.br
# last update 09 Feb 2012
#

PREFIX="/var/vmail/vmail1"
cd ${PREFIX}

for dir1 in `find . -maxdepth 1 -mindepth 1 -type d`; do
	if [ "$dir1" == "./invalid" ]; then
		continue
	fi
	cd $dir1
	for dir2 in `find . -maxdepth 1 -mindepth 1 -type d`; do
		d=`echo $dir1|cut -d/ -f2`
		u=`echo $dir2|cut -d/ -f2`
		#echo "select maildir from postfix.mailbox where maildir='$d/$u/';"
		rval=`echo "select maildir from vmail.mailbox where maildir='$d/$u/';" |mysql -u vmail -h localhost -pSENHA`
		if [ $? != 0 ]; then
			echo "Error on mysql query... exiting"
			exit 1
		fi
		rval2=`echo $rval|tail -n1`
		if [ -z "$rval2" ]; then
			echo -n "moving $d/$u..."
			sleep 1
			echo " now!"
			if [ ! -e ${PREFIX}/invalid/$d ]; then
				echo "mkdir $d"
				mkdir ${PREFIX}/invalid/$d
			fi
			mv -i ${PREFIX}/$d/$u ${PREFIX}/invalid/$d
		fi
	done
	cd ..
done
