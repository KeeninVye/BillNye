#!/bin/bash

PDF_DIR="pdf/"
TXT_DIR="text/"
LOG_DIR="log/"
LOG_FILE="$LOG_DIR$(date +%Y%m%d)_log.txt"
TIMESTAMP=$(env TZ=America/Los_Angeles date)
IS_FILE=0
IS_DIR=0

function show_help {
	echo "Help!"
}
function tester {
	echo "$IS_FILE"
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
		echo "File Convert on $BASE."
		echo "[$TIMESTAMP] [INFO]:pdf to text" $1 $TXT_DIR$FILE".billing.txt" >> $LOG_FILE
		pdftotext "-layout" $1 $TXT_DIR$FILE".billing.txt"
	else
		echo "File or Directory not found."
	fi
}

function parsePurchase {
	local STRING=$1
	local PROCESSDATE=$1[0]
	local TYPE=$STRING[1]
	local USAGEDATE=$STRING[2]
	local SOURCE=$STRING[3]
	local AMOUNT=$STRING[4]
	local BALANCE=$STRING[5]
	local RETURN_STRING="$PROCESSDATE','$TYPE','$USAGEDATE','$SOURCE','$AMOUNT','$BALANCE"
	echo $RETURN_STRING
}

function parseTransfer {
	local STRING=$1
	local PROCESSDATE=$STRING[0]
	local TYPE="Transfer"
	local USAGEDATE=$PROCESSDATE
	local SOURCE=$STRING[1]
	local AMOUNT=$STRING[2]
	local BALANCE=$STRING[3]
	local RETURN_STRING="$PROCESSDATE','$TYPE','$USAGEDATE','$SOURCE','$AMOUNT','$BALANCE"
	echo $RETURN_STRING
}

function parseRecurring {
	local STRING=$1
	local PROCESSDATE=$STRING[0]
	local TYPE=$STRING[1]
	local USAGEDATE=$STRING[2]
	local SOURCE=$STRING[3]
	local AMOUNT=$STRING[4]
	local BALANCE=$STRING[5]
	local RETURN_STRING="$PROCESSDATE','$TYPE','$USAGEDATE','$SOURCE','$AMOUNT','$BALANCE"
	echo $RETURN_STRING
}

function parseReturn {
	local STRING=$1
	local PROCESSDATE=$STRING[0]
	local TYPE=$STRING[1]
	local USAGEDATE=$STRING[2]
	local SOURCE=$STRING[3]
	local AMOUNT=$STRING[4]
	local BALANCE=$STRING[5]
	local RETURN_STRING="$PROCESSDATE','$TYPE','$USAGEDATE','$SOURCE','$AMOUNT','$BALANCE"
	echo $RETURN_STRING
}

function parseATMWith {
	local STRING=$1
	local PROCESSDATE=$STRING[0]
	local TYPE=$STRING[1]
	local USAGEDATE=$STRING[2]
	local SOURCE=$STRING[3]
	local AMOUNT=$STRING[4]
	local BALANCE=$STRING[5]
	local RETURN_STRING="$PROCESSDATE','$TYPE','$USAGEDATE','$SOURCE','$AMOUNT','$BALANCE"
	echo $RETURN_STRING
}

function parseATMFee {
	local STRING=$1
	local PROCESSDATE=$STRING[0]
	local TYPE=$STRING[1]
	local USAGEDATE=$PROCESSDATE
	local SOURCE="ATM Fee"
	local AMOUNT=$STRING[2]
	local BALANCE=""
	local RETURN_STRING="$PROCESSDATE','$TYPE','$USAGEDATE','$SOURCE','$AMOUNT','$BALANCE"
	echo $RETURN_STRING
}

function parseText {

	REX_PUR=' +([0-9]{2}\/[0-9]{2}) +(Card Purchase[a-zA-Z ]+)([0-9]{2}\/[0-9]{2}) (.+)(-[0-9]+.[0-9]{2}) +([,0-9]+\.[0-9]{2})'
	REX_TRANSFER=' +([0-9]{2}\/[0-9]{2}) +([a-zA-Z .0-9#:]+) +([-0-9,]+.[0-9]{2}) +([0-9,]+.[0-9]{2})'
	REX_PUR_RECUR=' +([0-9]{2}\/[0-9]{2}) +(Recurring Card Purchase) ([0-9]{2}\/[0-9]{2}) (.+)  ([-0-9]+.[0-9]{2}) +([,0-9]+\.[0-9]{2})'
	REX_PUR_RETURN=' +([0-9]{2}\/[0-9]{2}) +(Purchase Return) +([0-9]{2}\/[0-9]{2}) (.+)  ([0-9]*.[0-9]{2}) +([,0-9]+\.[0-9]{2})'
	REX_ATM_WITH=' +([0-9]{2}\/[0-9]{2}) +(Non-Chase ATM Withdraw) +([0-9]{2}\/[0-9]{2}) (.+)  (-[0-9]+.[0-9]{2}) +([0-9]+.[0-9]{2})'
	REX_ATM_FEE=' +([0-9]{2}\/[0-9]{2}) +(Non-Chase ATM Fee-With) +(-[0-9]*.[0-9]{2}) +(-[0-9]*.[0-9]{2})'

	if [ "$IS_DIR" -eq 1 ]; then
		COUNT=0
		for i in $( ls $TXT_DIR) ; do
			FILE="${i%%.*}"
			while IFS='' read -r line || [[ -n "$line" ]]; do
				if [[ $line =~ $REX_PUR ]]; then
				    COUNT=$((COUNT+1))
				    RETURN_STRING=$(parsePurchase $BASH_REMATCH)
				elif [[ $line =~ $REX_TRANSFER ]]; then
				    COUNT=$((COUNT+1))
					parseTransfer $BASH_REMATCH
				elif [[ $line =~ $REX_PUR_RECUR ]]; then
				    COUNT=$((COUNT+1))
				elif [[ $line =~ $REX_PUR_RETURN ]]; then
				    COUNT=$((COUNT+1))
				elif [[ $line =~ $REX_ATM_WITH ]]; then
				    COUNT=$((COUNT+1))
				elif [[ $line =~ $REX_ATM_FEE ]]; then
				    COUNT=$((COUNT+1))

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
				parsePurchase ${BASH_REMATCH[@]}
			elif [[ $line =~ $REX_TRANSFER ]]; then
			    COUNT=$((COUNT+1))
				RETURN_STRING=$(parseTransfer ${BASH_REMATCH[@]})
			elif [[ $line =~ $REX_PUR_RECUR ]]; then
			    COUNT=$((COUNT+1))
			    RETURN_STRING=$(parseRecurring $BASH_REMATCH[@])
			elif [[ $line =~ $REX_PUR_RETURN ]]; then
			    COUNT=$((COUNT+1))
			    RETURN_STRING=$(parseReturn $BASH_REMATCH[@])
			elif [[ $line =~ $REX_ATM_WITH ]]; then
			    COUNT=$((COUNT+1))
			    RETURN_STRING=$(parseATMWith $BASH_REMATCH[@])
			elif [[ $line =~ $REX_ATM_FEE ]]; then
			    COUNT=$((COUNT+1))
			    RETURN_STRING=$(parseATMFee $BASH_REMATCH[@])
			fi
			echo $RETURN_STRING

			shift
		done < "$1"
	echo $COUNT
	fi
}

# A POSIX variable
#OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
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
