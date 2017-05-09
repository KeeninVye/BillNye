#!/bin.bash

regex=' +([0-9]{2}\/[0-9]{2}) +(Card Purchase[a-zA-Z ]+)([0-9]{2}\/[0-9]{2}) (.+)(-[0-9]+.[0-9]{2}) +([,0-9]+\.[0-9]{2})'
REX=' +([0-9]{2}\/[0-9]{2}) +(Card Purchase[a-zA-Z ]+)([0-9]{2}\/[0-9]{2}) .+(-[0-9]+.[0-9]{2}) +([,0-9]+\.[0-9]{2})| +([0-9]{2}\/[0-9]{2}) +([a-zA-Z .0-9#:]+) +([-0-9,]+.[0-9]{2}) +([0-9,]+.[0-9]{2})'
TEXT='             03/24                 Card Purchase         03/24 Amazon Mktplace Pmts Amzn.Com/Bill WA                          -67.25                  680.25'
if [[ $TEXT =~ $REX ]]; then
    echo "$TEXT matches"
    i=1
    n=${#BASH_REMATCH[*]}
    echo $BASH_REMATCH
    while [[ $i -lt $n ]]
    do
        echo "  capture[$i]: ${BASH_REMATCH[$i]}"
        let i++
    done
else
    echo "$TEXT does not match"
fi
shift