#!/bin/bash

PDF_DIR="pdf/"
TXT_DIR="text/"
LOG_DIR="log/"
LOG_FILE="$LOG_DIR$(date +%Y%m%d)_log.txt"
TIMESTAMP=$(env TZ=America/Los_Angeles date)

for i in $(ls $PDF_DIR) ; do
	FILE="${i%%.*}"
	echo "[$TIMESTAMP] [INFO]:pdf to text" $i $TXT_DIR$FILE".billing.txt" >> $LOG_FILE
	pdftotext $PDF_DIR$i $TXT_DIR$FILE".billing.txt"
done 