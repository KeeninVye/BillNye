#!/bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PDF_DIR="$CWD/../pdf/"
TXT_DIR="$CWD/../text/"
LOG_DIR="$CWD/../log/"
DATA_DIR="$CWD/../data/"
LOG_FILE="$LOG_DIR$(date +%Y%m%d)_log.txt"
TIMESTAMP=$(env TZ=America/Los_Angeles date)
IS_FILE=0
IS_DIR=0
isCHECKINGS=1

function show_help {
	echo "Help!"
}
function tester {
	echo "$IS_FILE"
}

function logToFile() {
	if [ "$isCHECKINGS" -eq 1 ]; then
		echo $1 >> "$DATA_DIR$(date +%Y%m%d)_checkings_data.csv"
	else
		echo $1 >> "$DATA_DIR$(date +%Y%m%d)_savings_data.csv"
	fi
}

function parsePurchase {
	local STRING=("$@")
	local PROCESSDATE="${STRING[1]//,}"
	local TYPE="${STRING[2]//,}"
	local USAGEDATE="${STRING[3]//,}"
	local SOURCE="${STRING[4]//,}"
	local AMOUNT="${STRING[5]//,}"
	local BALANCE="${STRING[6]//,}"
	local RETURN_STRING="$PROCESSDATE,$TYPE,$USAGEDATE,$SOURCE,$AMOUNT,$BALANCE"
	logToFile "${RETURN_STRING}"
}

function parseTransfer {
local STRING=("$@")
	local PROCESSDATE="${STRING[1]}"
	local TYPE="Transfer"
	local USAGEDATE=$PROCESSDATE
	local SOURCE="${STRING[2]//,}"
	local AMOUNT="${STRING[3]//,}"
	local BALANCE="${STRING[4]//,}"
	local RETURN_STRING="$PROCESSDATE,$TYPE,$USAGEDATE,$SOURCE,$AMOUNT,$BALANCE"
	logToFile "${RETURN_STRING}"
}

function parseRecurring {
	local STRING=("$@")
	local PROCESSDATE="${STRING[1]//,}"
	local TYPE="${STRING[2]//,}"
	local USAGEDATE="${STRING[3]//,}"
	local SOURCE="${STRING[4]//,}"
	local AMOUNT="${STRING[5]//,}"
	local BALANCE="${STRING[6]//,}"
	local RETURN_STRING="$PROCESSDATE,$TYPE,$USAGEDATE,$SOURCE,$AMOUNT,$BALANCE"
	logToFile "${RETURN_STRING}"
}

function parseReturn {
	local STRING=("$@")
	local PROCESSDATE="${STRING[1]//,}"
	local TYPE="${STRING[2]//,}"
	local USAGEDATE="${STRING[3]//,}"
	local SOURCE="${STRING[4]//,}"
	local AMOUNT="${STRING[5]//,}"
	local BALANCE="${STRING[6]//,}"
	local RETURN_STRING="$PROCESSDATE,$TYPE,$USAGEDATE,$SOURCE,$AMOUNT,$BALANCE"
	logToFile "${RETURN_STRING}"
}

function parseATMWith {
	local STRING=("$@")
	local PROCESSDATE="${STRING[1]//,}"
	local TYPE="${STRING[2]//,}"
	local USAGEDATE="${STRING[3]//,}"
	local SOURCE="${STRING[4]//,}"
	local AMOUNT="${STRING[5]//,}"
	local BALANCE="${STRING[6]//,}"
	local RETURN_STRING="$PROCESSDATE,$TYPE,$USAGEDATE,$SOURCE,$AMOUNT,$BALANCE"
	logToFile "${RETURN_STRING}"
}

function parseATMFee {
	local STRING=("$@")
	local PROCESSDATE="${STRING[1]//,}"
	local TYPE="${STRING[2]//,}"
	local USAGEDATE=$PROCESSDATE
	local SOURCE="ATM Fee"
	local AMOUNT="${STRING[3]//,}"
	local BALANCE=""
	local RETURN_STRING="$PROCESSDATE,$TYPE,$USAGEDATE,$SOURCE,$AMOUNT,$BALANCE"
	logToFile "${RETURN_STRING}"
}

function convertToText {
	if [ "$IS_DIR" -eq 1 ]; then
		for i in $(ls $1) ; do
			FILE="${i%%.*}"
			echo "Directory Convert."
			echo "[$TIMESTAMP] [INFO]:pdf to text" $i $TXT_DIR$FILE".billing.txt" >> $LOG_FILE
			pdftotext "-layout" $1$i $TXT_DIR$FILE".billing.txt"
		done
	elif [ "$IS_FILE" -eq 1 ]; then
		BASE=`basename $1`
		FILE="${BASE%%.*}"
		echo "[$TIMESTAMP] [INFO]:cmd'pdftotext" $1 $TXT_DIR$FILE".billing.txt'" >> $LOG_FILE
		pdftotext "-layout" $1 $TXT_DIR$FILE".billing.txt"
	else
		echo "File or Directory not found."
	fi
}

function parseText {

	REX_PUR=' +([0-9]{2}\/[0-9]{2}) +(Card Purchase[a-zA-Z ]+)([0-9]{2}\/[0-9]{2}) (.+)(-[0-9]+.[0-9]{2}) +([,0-9]+\.[0-9]{2})'
	REX_TRANSFER=' +([0-9]{2}\/[0-9]{2}) +([a-zA-Z .0-9#:]+) +([-0-9,]+.[0-9]{2}) +([0-9,]+.[0-9]{2})'
	REX_PUR_RECUR=' +([0-9]{2}\/[0-9]{2}) +(Recurring Card Purchase) ([0-9]{2}\/[0-9]{2}) (.+)  ([-0-9]+.[0-9]{2}) +([,0-9]+\.[0-9]{2})'
	REX_PUR_RETURN=' +([0-9]{2}\/[0-9]{2}) +(Purchase Return) +([0-9]{2}\/[0-9]{2}) (.+)  ([0-9]*.[0-9]{2}) +([,0-9]+\.[0-9]{2})'
	REX_ATM_WITH=' +([0-9]{2}\/[0-9]{2}) +(Non-Chase ATM Withdraw) +([0-9]{2}\/[0-9]{2}) (.+)  (-[0-9]+.[0-9]{2}) +([0-9]+.[0-9]{2})'
	REX_ATM_FEE=' +([0-9]{2}\/[0-9]{2}) +(Non-Chase ATM Fee-With) +(-[0-9]*.[0-9]{2}) +(-[0-9]*.[0-9]{2})'
	REX_SAVINGS=' +SAVINGS SUMMARY'

	if [ "$IS_DIR" -eq 1 ]; then
		COUNT=0
		for i in $( ls $1) ; do
			FILE="${i%%.*}"
			while IFS='' read -r line || [[ -n "$line" ]]; do
				RETURN_STRING=""
				if [[ $line =~ $REX_PUR ]]; then
				    COUNT=$((COUNT+1))
				 	parsePurchase "${BASH_REMATCH[@]}"
				elif [[ $line =~ $REX_TRANSFER ]]; then
				    COUNT=$((COUNT+1))
				    parseTransfer "${BASH_REMATCH[@]}"
				elif [[ $line =~ $REX_PUR_RECUR ]]; then
				    COUNT=$((COUNT+1))
				    parseRecurring "${BASH_REMATCH[@]}"
				elif [[ $line =~ $REX_PUR_RETURN ]]; then
				    COUNT=$((COUNT+1))
					parseReturn "${BASH_REMATCH[@]}"
				elif [[ $line =~ $REX_ATM_WITH ]]; then
				    COUNT=$((COUNT+1))
				    parseATMWith "${BASH_REMATCH[@]}"
				elif [[ $line =~ $REX_ATM_FEE ]]; then
				    COUNT=$((COUNT+1))
				    parseATMFee "${BASH_REMATCH[@]}"
				elif [[ $line =~ $REX_SAVINGS ]]; then
					isCHECKINGS=0
				fi
				shift
			done < "$TXT_DIR$i"
		done
		echo $COUNT
	elif [ "$IS_FILE" -eq 1 ]; then
		BASE=`basename $1`
		FILE="${BASE%%.*}"
		COUNT=0
		while IFS='' read -r line || [[ -n "$line" ]]; do
			RETURN_STRING=""
			if [[ $line =~ $REX_PUR ]]; then
			    COUNT=$((COUNT+1))
			 	parsePurchase "${BASH_REMATCH[@]}"
			elif [[ $line =~ $REX_TRANSFER ]]; then
			    COUNT=$((COUNT+1))
			    parseTransfer "${BASH_REMATCH[@]}"
			elif [[ $line =~ $REX_PUR_RECUR ]]; then
			    COUNT=$((COUNT+1))
			    parseRecurring "${BASH_REMATCH[@]}"
			elif [[ $line =~ $REX_PUR_RETURN ]]; then
			    COUNT=$((COUNT+1))
				parseReturn "${BASH_REMATCH[@]}"
			elif [[ $line =~ $REX_ATM_WITH ]]; then
			    COUNT=$((COUNT+1))
			    parseATMWith "${BASH_REMATCH[@]}"
			elif [[ $line =~ $REX_ATM_FEE ]]; then
			    COUNT=$((COUNT+1))
			    parseATMFee "${BASH_REMATCH[@]}"
			elif [[ $line =~ $REX_SAVINGS ]]; then
				isCHECKINGS=0
			fi
			shift
		done < "$1"
	echo $COUNT
	fi
}

verbose=0
CONVERT=0
PARSE=0

if [[ "$1" =~ "^((-{1,2})([Hh]$|[Hh][Ee][Ll][Pp])|)$" ]]; then
	usage; exit 1
else
	while [[ $# -gt 1 ]]; do
		opt="$1"
		shift;
		current_arg="$1"
		if [[ "$current_arg" =~ "^-{1,2}.*" ]]; then
			echo "WARNING: You may have left an argument blank. Double check your command." 
		fi
		case "$opt" in
			"-c"|"--C"	) CONVERT=1;;
			"-p"|"--P"	) PARSE=1;;
			*			) echo "ERROR: Invalid option: \""$opt"\"" >&2
						  exit 1
						  ;;
		esac
	done
fi

#if [[ "$APPLE" == "" || "$BANANA" == "" ]]; then
#	echo "ERROR: Options -a and -b require arguments." >&2
#	exit 1
#fi

if [ ! -d $DATA_DIR ]; then
	echo "Making 'data' directory for CSV files."
	mkdir $DATA_DIR
fi

if [ ! -d $TXT_DIR ]; then
	echo "Making 'text' directory for text files."
	mkdir $TXT_DIR
fi

if [ ! -d $LOG_DIR ]; then
	echo "Making 'log' directory for log files."
	mkdir $LOG_DIR
fi

if [ -z "$1" ]; then
    echo "No directory given."
    show_help
else
	[ -f "$1" ] && IS_FILE=1
	[ -d "$1" ] && IS_DIR=1
	if [ "$IS_FILE" -eq 0 ] && [ "$IS_DIR" -eq 0 ]; then
		echo "$IS_FILE $IS_DIR"
		echo "File or Directory, $1, not found."
	else
	    if [ "$CONVERT" -eq 1 ]; then
	    	echo "CONVERT $IS_FILE $IS_DIR"
	    	convertToText "$1"
		elif [ "$PARSE" -eq 1 ]; then
			echo "PARSE $IS_FILE $IS_DIR"
			parseText "$1"
		else
			echo "No flags given, parsing regularly."
		fi
	fi
fi
