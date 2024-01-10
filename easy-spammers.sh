#!/bin/bash


NC='\033[0m' # No Color
RED='\033[0;31m'
PURPLE='\033[0;35m'

LANG="en_US.UTF-8"
temp=$(date +%d)
if [ ${temp} -eq 10 ] || [ ${temp} -eq 20 ] || [ ${temp} -eq 30 ]; then
        DT=$(echo "$(date +%b) $(date +%d)")
else
        DT=$(echo "$(date +%b) $(date +%d|tr 0 ' ')")
fi

addspammer() {
	x=$(grep $1 /etc/rspamd/maps.d/local_bl_domain.inc)
	if [ -z "${x}" ]; then
		echo "--- Found $1 ($2) -> Adding to blacklist"
		echo -e "$1" >> /etc/rspamd/maps.d/local_bl_domain.inc
	else
		echo "Already on blacklist $1 ($2)"
	fi
}

# block that domains 
for dom in $(grep "${DT}" /var/log/maillog|grep 'postfix/qmgr'|grep -v removed|cut -d "<" -f2|cut -d">" -f1|cut -d"@" -f2 |egrep -v 'amazonses.com|asbyte.com.br|positron|facebookmail|linkedin|minhati.com.br|listas.abrint|cosan.com.br|felipecenter.com.br|felipeengenharia.com.br|atima.com.br|espacomed|frasmil|icisolamento|interativa|isolamento|isonetcal|isolart|lasmil|marcari|montsena|orcaindustrial|sermedbarrinha|worksmusic|copacesp|brasmiil.com.br'|sort|uniq |sort|grep -v 'Found decoder'|egrep  '\.ga$|\.cf$|\.qq$|\.live$|\.com.de$|\.us$|\.icu$|\.xyz$|\.mobi$|\.info$|\.cu$\|\.club$|\.co$|\.online$|\.store$|\.space$|\.site$|\.de$|\.pl$|\.life$|\.be$|\.ru$|\.co$|\.rio.br$|\.click$|\.website$|\.cam$|\.network$|\.uno$|\.gq$|\.com.vc$|\.ag$|\.tk$|\.archi$|\.today$|\.we.bs$|\.dog$|\.tech$|\.buzz$|\.co$|\.art$|\.pw$|\.cloud$|\.miami$|\.app$|\.email$|\.shop$|\.institute$|\.photos$|\.live$|\.digital$|\.cyou$|\.page$|\.top$|\.gold$|\.work$|\.surf$|\.world$|\.agency$|\.support$|\.jewelry$|\.blog$|\.monster$|\.com.mx$|\.gob.mx$'); do
	addspammer "$dom" "prohibited domains"
done


systemctl reload rspamd