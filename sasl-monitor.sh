#!/bin/sh

LANG="en_US.UTF-8"
today="`date +%Y%m%d`"
log="/tmp/sasl_mon.txt.${today}"
max_login=120

change_pass() {
	account=$1
	echo "update vmail.mailbox set password='CoNta@3c0mPROmet1da001010101010' where username='${account}'"|mysql -pSENHA
}

if [ -e ${log} ]; then
	exit 2
fi

rval=$(/root/find_top_sasl_usernames.sh  /var/log/maillog |egrep -v 'nfe@empresa.local'|tail -n1|awk -F" " '{print $1}')
if [ -z "$rval" ]; then
	exit 2;
fi

if [ $rval -gt ${max_login} ]; then
	echo "to: noc@atima.com.br,atima@atima.com.br" >> $log
	echo "subject: ** `hostname` SASL Warning **" >> $log
	echo "from: postmaster@atima.com.br" >> $log
	echo " " >> $log
	echo "SASL Login on `hostname` is high: $rval" >> $log
        echo " " >> $log
	echo "*************************************************" >> $log
	echo "Por favor, entre em contato com o Victo'rio" >> $log
	echo "*************************************************" >> $log
	echo " " >> $log
	echo "Muitos logs do mesmo usuaio from detectado':" >> $log
	echo "$(/root/find_top_sasl_usernames.sh  /var/log/maillog |tail -n3)" >> $log
	echo " " >> $log
	echo " " >> $log
	badc=$(/root/find_top_sasl_usernames.sh  /var/log/maillog |tail -n1|awk -F" " '{print $2}'|awk -F= '{print $2}')
	if [ ! -z "${badc}" ]; then
		echo "alterando a senha da conta ${badc}" >> $log
		change_pass ${badc}
	fi
	/usr/sbin/sendmail -t < $log

fi
