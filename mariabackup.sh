#!/bin/bash
#
# this script uses the new tool MariaBackup to do Full and Incremental backups
# for mariadb 10.2+ servers
# https://mariadb.com/kb/en/mariabackup-overview/
#
# Author: Victorio H. Felipe (victoriofelipe@outlook.com)
#
# License: 2-Clause BSD
# https://opensource.org/licenses/BSD-2-Clause
#
# 1. create an user with permissions to backup
# CREATE USER 'mariabackup'@'localhost' IDENTIFIED BY 'mypassword';
# 10.5+ -> GRANT RELOAD, PROCESS, LOCK TABLES, BINLOG MONITOR ON *.* TO 'mariabackup'@'localhost'; 
# 10.2-4 -> GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'mariabackup'@'localhost';
#

# This script only support incremental backups on the same day of Full backup
# Backup incremental = Diferencial 

BIN=/usr/bin/mariadb-backup
USER="mariabackup"
PASS="M4r1f@9fAF9i24jdojf"
BASEDIR=/recovery_mariadb/mariadb-backup
LOGTAG="mariabackup"
KEEP=1 # we keep this -1 days

MONTH=$(date +%Y-%m)
DATE=$(date +%Y-%m-%d)
DATEINC=$(date +%Y-%m-%d_%H%M)


# first parameter is 'Full' for full backup or 'Incremental' for incremental backup
BKTYPE="${1:-Full}"
# bacula backup types Full Differential Incremental

test -d ${BASEDIR}/${DATE} && logger -t mariabackup "${BASEDIR}/${DATE} exits." || mkdir ${BASEDIR}/${DATE}

# We make sure there's no another Full or Incremental backups
if [ "${BKTYPE}" == "Full" ]; then
	x=$(find ${BASEDIR}/${DATE} -maxdepth 0 -empty -exec echo empty \;)
	if [ "X"$x != "Xempty" ]; then
		echo "WARNING: You are asking for a Full backup in a non-empty directory! ${BASEDIR}/${DATE} "
		echo $(ls ${BASEDIR}/${DATE})
		echo " "
		echo "All contents above will be erased in 5 seconds! Press Ctrl+C to abort"
		sleep 6
	fi
	if [ -d ${BASEDIR}/${DATE} ]; then
		rm -rf ${BASEDIR}/${DATE}/*
	fi
fi

if [ "${BKTYPE}" == "Full" ]; then
	# takes a full backup
	logger -t ${LOGTAG} "starting a Full backup"
	echo "$(date) starting a Full backup"
	echo "${BASEDIR}/${DATE}/Full-${DATEINC}">${BASEDIR}/${DATE}/.ctrl-full-last
	${BIN} --backup --target-dir=${BASEDIR}/${DATE}/Full-${DATEINC} \
		--user=${USER} --password=${PASS}
	if [ $? -ne 0 ]; then
		logger -t ${LOGTAG} "fail on command ${BIN}"
		exit 1
	fi
	logger -t ${LOGTAG} "finished the Full backup"
	echo "$(date) finished the Full backup"
fi

if [ "${BKTYPE}" == "Incremental" ]; then
	# takes an Incremental backup
	if [ ! -f ${BASEDIR}/${DATE}/.ctrl-full-last ]; then
		logger -t ${LOGTAG} "${BKTYPE} failed because no control file found"
		echo "$(date) ${BKTYPE} failed because no control file found:"
		echo "$(ls -a ${BASEDIR}/${DATE}/)"
		exit 1
	fi
	logger -t ${LOGTAG} "starting an ${BKTYPE} backup"
	echo "$(date) starting an ${BKTYPE} backup"
	echo "${BASEDIR}/${DATE}/Incr-${DATEINC}">${BASEDIR}/${DATE}/.ctrl-incr-last
	LASTDIFF=$(cat ${BASEDIR}/${DATE}/.ctrl-full-last)
	${BIN} --backup --incremental-basedir=${LASTDIFF} \
	       	--target-dir=${BASEDIR}/${DATE}/Incr-${DATEINC}/ \
		--user=${USER} --password=${PASS}
	logger -t ${LOGTAG} "finished the ${BKTYPE} backup"
	echo "$(date) finished the ${BKTYPE} backup"
fi

# Clean old
OLD=$(date --date="-${KEEP} days" +%Y-%m-%d)
if [ -d ${BASEDIR}/${OLD} ]; then 
	echo "removing ${BASEDIR}/${OLD}"
	logger -t ${LOGTAG} "removing ${BASEDIR}/${OLD}"
	rm -rf ${BASEDIR}/${OLD}
fi
