#!/bin/bash
#
# Autoria: Heitor Faria (Copyleft: all rights reversed).
# Testado por: Victorio H. Felipe
#
# Deve ser chamado no sub-recurso INCLUDE do FileSet do bacula-dir.conf, referente ao backup do cliente instalado na máquina do Zimbra (por exemplo):
#
# Plugin = "\|/etc/bacula/bpipe_zimbra.sh %l"
#

# somente fazemos backup incremental

level=$1

#if [ $level == Incremental ]
#then
query="&start=-1days"
#fi

#if [ $level == Differential ]
#then
#query="&start=-7days"
#fi

if [ ! -f /tmp/bz.list ]; then
   echo "/tmp/bz.list not found!"
   exit 1
fi

query="&start=-1days"
zimbra_command="/opt/zimbra/bin/zmmailbox -z -m"

for zimbra_user in $(cat /tmp/bz.list); do
      echo "bpipe:/var/$zimbra_user.tgz:$zimbra_command $zimbra_user -t 0 getRestURL '/?fmt=tgz$query':dd of=/tmp/$zimbra_user.tgz && $zimbra_command $zimbra_user -t 0 postRestURL -i '//?fmt=tgz&resolve=skip' /tmp/$zimbra_user.tgz"
done