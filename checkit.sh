#!/bin/bash


# ./checkit.sh /mnt/share/allmovies/Alphabetical/X X
# ./checkit.sh /mnt/share/movies/2021-01-January-1/ xx

UNIQID=$2

logDir="./log"
fileDir="./files"

#////////////////////////////////
function _writeLog {

    echo $1
    echo $1 >> ./log/checkit-log-$UNIQID.txt

}

#////////////////////////////////
function _writeErrorLog {

    echo $1 >> ./log/checkit-error-movies-$UNIQID.txt

}

PASSED=$1

if [ -d "${PASSED}" ] ; then
    echo "$PASSED is a directory";
else
    if [ -f "${PASSED}" ]; then
        echo "${PASSED} is a file";
    else
        echo "${PASSED} is not valid";
        exit 1
    fi
fi

# Check files directory
if [ -d "${logDir}" ] ; then
    echo "$logDir directory exists";
else
    echo "$logDir does exist, creating";
    mkdir $logDir
fi

# Check log directory
if [ -d "${fileDir}" ] ; then
    echo "$fileDir directory exists";
else
    echo "$fileDir does exist, creating";
    mkdir $fileDir
fi

_writeLog "Starting"
_writeLog "========================================="

ls $1 -xN1 > ./files/files-$2.txt

cnt=0
errcnt=0

while IFS="" read -r p || [ -n "$p" ]
do
  
    found=0

    ((cnt=cnt+1))

    for i in {1900..2025}
    do

        if [[ "$p" == *"($i)"* ]]; then

            from="$1/$p"
            found=1
            break 

        fi

    done

    if [ $found -ne 1 ]
    then
        ((errcnt=errcnt+1))
        _writeLog "No year found $p" >> FilesNOTProcessed-$2.txt
        _writeLog "No year found $p"
    fi

done < ./files/files-$2.txt

_writeLog "========================================="
_writeLog "Number of movie directories $cnt"
_writeLog "#########################################"
_writeLog "Number of movie directories with issues $errcnt"
_writeLog "========================================="

_writeLog "Complete"
