#!/bin/bash
# get all accounts which receive e-mail on last day

echo "start $(date)"
zimbra_command="/opt/zimbra/bin/zmmailbox -z -m"
test -f /tmp/bz.all && rm /tmp/bz.all
test -f /tmp/bz.list && rm /tmp/bz.list


for zimbra_user in $(/opt/zimbra/bin/zmprov -l gaa| grep -v -E "armazenamento|galsync|virus|admin@|ham.*@|spam.*@" | sort); do
   #echo -n testing $zimbra_user
   echo $zimbra_user >> /tmp/bz.all
   rval=$($zimbra_command $zimbra_user  search -t message -l 1 after:-1d|grep num:|awk -F: '{print $2}'|awk -F, '{print $1}')
   if [ $rval -eq 1 ]; then
      echo "backup $zimbra_user"
      echo $zimbra_user >> /tmp/bz.list
#   else
#      echo " "
   fi
done

echo "finished $(date)"