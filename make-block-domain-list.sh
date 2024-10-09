#!/bin/bash
#
# Desenvolvido por Victorio Henrique Felipe (victorio@felipecs.com.br)
# data 25 setembro 2024
# requisitos: poppler-utils
#
hj=$(date +%Y%m%d-%H%M%S)

pdftotext $1 $1.p1
for d in $(cat dotfinal.txt); do 
	cat $1.p1|egrep "[a-zA-Z0-9$]\.[a-zA-Z0-9$]"|grep -v '/'|grep -v gov.br | grep "\.$d$" >> $1.p2
done


for d in $(cat $1.p2); do
	rval=$(grep $d /etc/unbound/local.d/*.conf)
	if [ -z "$rval" ];  then
		echo "+++ adding $d to new file"
		echo "local-data: \"$d. 3600 IN A 127.0.0.1\"" >> /etc/unbound/local.d/anatel_$hj.conf
	#else
	#	echo "$rval"
	fi
done
