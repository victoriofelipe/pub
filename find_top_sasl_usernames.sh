#!/usr/bin/env bash
# Purpose: Find usernames used for smtp authentication in Postfix log file,
#          sorted by login times.

LANG=en_US.UTF-8
MAIL_LOG="$1"
IFS='%'
temp=$(date +%d)
if [ ${temp} -eq 10 ] || [ ${temp} -eq 20 ] || [ ${temp} -eq 30 ]; then
        DT=$(echo "$(date +%b) $(date +%d)")
else
        DT=$(echo "$(date +%b) $(date +%d|tr 0 ' ')")
fi

if [ -z ${MAIL_LOG} ]; then
    echo "Please specify the mail log file: $0 /path/to/maillog"
    exit 255
fi

tmpfile="/tmp/sasl_username_${RANDOM}"
grep 'sasl_username=' ${MAIL_LOG}|grep "${DT}"|grep -v 186.232.84.1 > ${tmpfile}
awk '{print $NF}' ${tmpfile}  | sort | uniq -c | sort -n

rm -f ${tmpfile}