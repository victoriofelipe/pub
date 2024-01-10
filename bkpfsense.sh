#!/bin/bash
#
# backup script for pfsense
# author: Victo'rio Felipe (victorio.felipe@baitzsolutions.com.br)
# Based on https://docs.netgate.com/pfsense/en/latest/backup/remote-backup.html
# 
# BSD 3-clause license
#
#****************************************************************************#
# KNOW ISSUES
# backup via SSH: pfSense admin user shows a menu and this screw up our 
# scp/ssh command, so we need an user with permission the get the xml file
#
# db/server.txt example:
#NAME=cliente-matriz
#IP1=climatriz.ddns.com.br
#USER=backupuser
#PASS=bkpass
#PROTO=https
#HTTPPORT=8080
#SSHPORT=2222
#METHOD=SSH (OPTIONAL)
#

BASEDIR="${HOME}/backup-pfsense"
LOG="${BASEDIR}/log.txt"
BKPDIR="${BASEDIR}/backups"
TEMP="${BASEDIR}/.tmp"
CURL=$(which curl)
NC=$(which nc)
GZ=$(which gzip)
AWK=$(which awk)
ZSTD=$(which zstd)

if [ -z "${CURL}" ]; then echo "Please, install curl. If it is installed check this script."; exit 1; fi
if [ -z "${NC}" ]; then echo "Please, install nc (netcat). If it is installed check this script."; exit 1; fi
if [ -z "${GZ}" ] && [ -z "${ZSTD}" ]; then echo "You need gzip or zstd"; exit 1; fi
if [ -z "${AWK}" ]; then echo "Please, install awk. If it is installed check this script."; exit 1; fi
CPRS=${GZ}
#if [ ! -z "${ZSTD}" ]; then
#   CPRS=${ZSTD}
#fi


if [ ! -d ${BKPDIR} ]; then mkdir ${BKPDIR}; fi
if [ ! -d ${TEMP} ]; then mkdir ${TEMP}; fi
if [ -f ${LOG} ]; then mv ${LOG} ${LOG}-$(date --date='-1 days' +%Y%m%d-%H%M); fi

# Variable is empty
e_var() {
   var_name=$1
   filename=$2
   echo "error in file ${filename}: variable ${var_name} is empty" >> $LOG
}

# Generic Exeption: save all information on log
e_error() {
  echo "$(date +%Y%m%d-%H%M%S): $1" >> $LOG
}

validate_backup() {
   name=$1
   f=$2
   line1=$(head -n1 $f|cut -d" " -f1)
   line2=$(head -n2 $f|tail -n1)
   lineF=$(tail -n1 $f)
   ret=0
   if [ -z "${line1}" ]; then ret=1; fi
   if [ "${line2}" != "<pfsense>" ]; then ret=1; fi
   if [ "${lineF}" != "</pfsense>" ]; then ret=1; fi
   if [ ${ret} == 1 ]; then
       e_error "backup fail: $1: $f is not a xml file"
   else
       ${CPRS} ${f}
   fi
}

# Get backup via HTTP(s)
get_backup() {
NAME=$1
HOST=$2
USER=$3
PASS=$4
PROTO=$5
HTTPPORT=$6
SSHPORT=22022
DT=$(date +%Y%m%d-%H%M%S)
TODAY=$(date +%Y%m%d)
BKD=${BKPDIR}/${TODAY}

if [ ! -d ${BKD} ]; then mkdir ${BKD}; fi

${CURL} -L -k --cookie-jar ${TEMP}/cookies.txt \
     ${PROTO}://${HOST}:${HTTPPORT}/ \
     | grep "name='__csrf_magic'" \
     | sed 's/.*value="\(.*\)".*/\1/' > ${TEMP}/csrf.txt

${CURL} -L -k --cookie ${TEMP}/cookies.txt --cookie-jar ${TEMP}/cookies.txt \
     --data-urlencode "login=Login" \
     --data-urlencode "usernamefld=${USER}" \
     --data-urlencode "passwordfld=${PASS}" \
     --data-urlencode "__csrf_magic=$(cat ${TEMP}/csrf.txt)" \
     ${PROTO}://${HOST}:${HTTPPORT}/ > /dev/null

${CURL} -L -k --cookie ${TEMP}/cookies.txt --cookie-jar ${TEMP}/cookies.txt \
     ${PROTO}://${HOST}:${HTTPPORT}/diag_backup.php  \
     | grep "name='__csrf_magic'"   \
     | sed 's/.*value="\(.*\)".*/\1/' > ${TEMP}/csrf.txt

# if you want backup extra data (dhcp leases and some databases add)
# --data-urlencode "backupdata=yes" \
${CURL} -L -k --cookie ${TEMP}/cookies.txt --cookie-jar ${TEMP}/cookies.txt \
     --data-urlencode "download=download" \
     --data-urlencode "donotbackuprrd=yes" \
     --data-urlencode "backupdata=yes" \
     --data-urlencode "__csrf_magic=$(head -n 1 ${TEMP}/csrf.txt)" \
     ${PROTO}://${HOST}:${HTTPPORT}/diag_backup.php > ${BKD}/pfsense-${NAME}-${DT}.xml

   validate_backup ${NAME} ${BKD}/pfsense-${NAME}-${DT}.xml
}

# Get backup via ssh
get_backup_ssh() {
  TODAY=$(date +%Y%m%d)
  BKD=${BKPDIR}/${TODAY}
  DT=$(date +%Y%m%d-%H%M%S)
  na=$1
  us=$2
  pa=$3
  ip=$4
  po=$5
  if [ ! -d ${BKD} ]; then mkdir ${BKD}; fi
  echo "${pa}">${TEMP}/p
  #sshpass -f${TEMP}/p ssh -p ${po} ${us}@${ip} cat /cf/conf/config.xml > ${BKD}/pfsense-${na}-${DT}.xml
  sshpass -f${TEMP}/p  scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P ${po} ${us}@${ip}:/cf/conf/config.xml ${BKD}/pfsense-${na}-${DT}.xml
   # scp may be disabled on RHEL>=9
#   sshpass -f${TEMP}/p sftp -oPort=${po} -oUserKnownHostsFile=/dev/null \
#       -o StrictHostKeyChecking=no ${us}@${ip} <<EOF
#         get /cf/conf/config.xml \
#  EOF
   validate_backup ${na}  ${BKD}/pfsense-${na}-${DT}.xml
}

# Test if we can connect to IP and port on the pfSense
test_conn() {
   name=$1
   ip=$2
   port=$3
   ${NC} -zw5 ${ip} ${port}
   if [ $? -gt 0 ]; then
      e_error "${name}: ${ip}:${port} is unreacheable"
      retval=1
   else
      retval=0
   fi
}

cd ${BASEDIR}

# MAIN LOOP
# for every file .txt in db directory, get params and backup a HTTP or SSH backup
for p in db/*.txt; do
#for p in db/beraldo-rp.txt; do
   HTTPFAIL=0
   cli_getmethod="HTTP"
   cli_name=$(grep NAME ${p}|head -n1|cut -d= -f2)
   cli_ip1=$(grep IP1 ${p}|head -n1|cut -d= -f2)
   cli_ip2=$(grep IP2 ${p}|head -n1|cut -d= -f2)
   cli_username=$(grep USER ${p}|head -n1|cut -d= -f2)
   cli_password=$(grep PASS ${p}|head -n1|cut -d= -f2)
   cli_proto=$(grep PROTO ${p}|head -n1|cut -d= -f2)
   cli_httpport=$(grep HTTPPORT ${p}|head -n1|cut -d= -f2)
   cli_sshport=$(grep SSHPORT ${p}|head -n1|cut -d= -f2)
   cli_getmethod=$(grep METHOD ${p}|head -n1|cut -d= -f2)

   # test all vars are empty
   if [ -z "${cli_name}" ]; then e_var "NAME" "${p}"; continue; fi
   if [ -z "${cli_ip1}" ]; then e_var "IP1" "${p}"; continue; fi
   if [ -z "${cli_username}" ]; then e_var "USER" "${p}"; continue; fi
   if [ -z "${cli_password}" ]; then e_var "PASS" "${p}"; continue; fi
   if [ -z "${cli_proto}" ]; then e_var "PROTO" "${p}"; continue; fi
   if [ -z "${cli_httpport}" ]; then e_var "HTTPPORT" "${p}"; continue; fi
   # optional params
#   if [ -z "${cli_ip2}" ]; then e_var "IP2" "${p}"; fi
   if [ -z "${cli_sshport}" ]; then cli_sshport=22; fi
   if [ -z "${cli_getmethod}" ]; then
      cli_getmethod="HTTP"
   else
      cli_getmethod=$(echo ${cli_getmethod}|awk '{print toupper($0)}')
   fi

   cli_proto=$(echo ${cli_proto}||awk '{print tolower($0)}')

   echo "+++ ${cli_name} ${cli_getmethod}"

   # Try to get backup via HTTP(s) first
   if [ "${cli_getmethod}" == "HTTP" ]; then
      test_conn ${cli_name} ${cli_ip1} ${cli_httpport}
      if [ $retval == 0 ]; then
         get_backup ${cli_name} ${cli_ip1} ${cli_username} ${cli_password} ${cli_proto} ${cli_httpport}
         continue
      else
        if [ ! -z "$cli_ip2" ]; then
           test_conn ${cli_name} ${cli_ip2} ${cli_httpport}
           if [ $retval == 0  ]; then 
              get_backup ${cli_name} ${cli_ip2} ${cli_username} ${cli_password} ${cli_proto} ${cli_httpport}
              continue
           else
              e_error "backup cannot connect HTTP, trying SSH: ${cli_name} ${cli_ip1} and ${cli_ip2} via SSH port ${cli_sshport}"
              HTTPFAIL=1
           fi
        else
           e_error "backup cannot connect HTTP, trying SSH: ${cli_name} ${cli_ip1} via HTTP port ${cli_sshport}"
           HTTPFAIL=1
        fi
      fi
   fi
   # get backup via SSH
   #
   if [ "$cli_getmethod" == "SSH" ] || [ ${HTTPFAIL} -eq 1 ]; then
      test_conn ${cli_name} ${cli_ip1} ${cli_sshport}
      if [ $retval == 0 ]; then
         get_backup_ssh  ${cli_name} ${cli_username} ${cli_password} ${cli_ip1} ${cli_sshport}
         continue
      else
        if [ ! -z "$cli_ip2" ]; then
           test_conn ${cli_name} ${cli_ip2} ${cli_sshport}
           if [ $retval == 0  ]; then 
              get_backup_ssh  ${cli_name} ${cli_username} ${cli_password} ${cli_ip2} ${cli_sshport}
              continue
           else
              e_error "backup fail: ${cli_name} ${cli_ip1} and ${cli_ip2} via ssh"
              continue
           fi
        else
           e_error "backup fail: ${cli_name} ${cli_ip1} via ssh"
           continue
        fi
      fi
   fi

done

