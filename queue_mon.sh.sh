#!/bin/bash

MAX=200

change_pass() {
	account=$1
	echo "update vmail.mailbox set password='BLA@#$FSFDSF#$545gfgdg' where username='${account}'"|mysql 
}

log="/tmp/queue_mon_`date +\"%Y%m%d%H%M\"`"
qtde=`/sbin/postqueue -p|tail -n1|awk '/Request/ {print $5}'`

if [ -z "$qtde" ]; then
	logger -t queue_mon "$qtde found: `/sbin/postqueue -p|tail -n1`"
	exit 0
fi

month="`date +%b`"

if [ $qtde -gt $MAX ];  then
	today="`date +%Y%m%d%H`"
	wassend=`ls /tmp/queue_mon_$today*`
	if [ -z "$wassend" ]; then
		echo "to: alerta@empresa.com.br,suporte@empresa.com.br" >> $log
		echo "subject: ** `hostname` QUEUE WARNING **" >> $log
		echo "from: root@mx.empresa.com.br" >> $log
		echo " " >> $log
		echo "Mail queue at `hostname` is high: $qtde" >> $log
	        echo " " >> $log
		echo "*************************************************" >> $log
		echo "Por favor, entre em contato com o Victo'rio" >> $log
		echo "*************************************************" >> $log
		echo " " >> $log
		echo "O total de mensagens na fila e':" >> $log
		echo "`/sbin/postqueue -p|tail -n1`" >> $log
		echo " " >> $log
		echo "Veja uma lista dos remetentes na fila. Provavelmente o com maior nu'mero" >> $log
		echo "de mensagens e' a conta que deve ser bloqueada no painel. Altere a senha" >> $log
		echo "se nao conseguir falar com o Victo'rio." >> $log
		echo " " >> $log
		echo "`/sbin/postqueue -p|grep $month|awk -F" " '{print $7}'|sort|uniq -c|sort`" >> $log
		echo " " >> $log
		badac=$(/sbin/postqueue -p|grep $month|awk -F" " '{print $7}'|sort|uniq -c|sort|tail -n1|awk -F" " '{print $2}')
		if [ "${badac}" != "MAILER-DAEMON" ]; then
			echo "Esse programa esta' alterando a senha de ${badac}." >> $log
			#change_pass ${badac}
		fi
		echo " " >> $log
		/usr/sbin/sendmail -t < $log
	fi
fi