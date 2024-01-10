#!/bin/bash

echo "       ATENCAO!"
echo " esse programa APAGA mensagens da fila de correio. Use com cuidado."

if [ $# -eq 1 ]; then
        email=$1
else
        echo -n "Digite o e-mail: "
        read email
fi

num=`postqueue -p|grep $email|cat -n|awk -F" " '{print $1}'|tail -n1`
echo "Encontrei $num"
sleep 1

for i in `postqueue -p|grep $email|awk -F" " '{print $1}'|cut -d* -f1`; do
#        echo `postqueue -p|grep $i`
        postsuper -d $i;
done

