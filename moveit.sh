#!/bin/bash

# This script will move all movies from one directory to another.
#
# param $1 is from directory
# param $2 is to directory
# param $3 is the unquie id for this run
#
#                      $1                                 $2                       $3 
# ./moveit.sh /mnt/share/allmovies/Alphabetical/X     /media/eva/Movie-Backup-1    X
# ./moveit.sh /mnt/share/movies/2020-11-November-1/   /media/eva/MovieWork/        20111

# sudo mount.cifs //192.168.1.130/downloadedmovies /mnt/share/movies -o user=xxx,pass=xxx

UNIQID=$3

logDir="./log"
fileDir="./files"

#////////////////////////////////
function _writeLog {

    echo $1
    echo $1 >> ./log/moveit-log-$UNIQID.txt

}

#////////////////////////////////
function _writeErrorLog {

    echo $1 >> ./log/moveit-error-movies-$UNIQID.txt

}

echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

# Need to add validation for input here

PASSED=$1

if [ -d "${PASSED}" ] ; then
    echo "$PASSED source is a directory";
else
    if [ -f "${PASSED}" ]; then
        echo "${PASSED} source is a file";
        exit 1
    else
        echo "${PASSED} source is not valid";
        exit 1
    fi
fi

PASSED=$2

if [ -d "${PASSED}" ] ; then
    echo "$PASSED target is a directory";
else
    if [ -f "${PASSED}" ]; then
        echo "${PASSED} target is a file";
        exit 1
    else
        echo "${PASSED} target is not valid";
        exit 1
    fi
fi

echo "Source Directory is valid [$1]"
echo "Target Directory is valid [$2]"

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

errCnt=0
cpCnt=0
existCnt=0

ls $1 -xN1 > ./files/files-$4.txt

while IFS="" read -r p || [ -n "$p" ]
do

    found=0

    # set to and from directories
    from="$1/$p"
    to="$2/$p"

    ((cnt=cnt+1))

    # Check if movie directory already exists
    if [ -d "${to}" ] ; then
        _writeLog ">>>>$to directory exists will refresh";
        ((existCnt=existCnt+1))
        _writeErrorLog "Already a directory $to refreshing"
    fi

    _writeLog "____Moving to $to";
    mv -u "$from" "$to"
    if [ $? -eq 0 ]; then
        _writeLog "____Moved $from";
        ((cpCnt=cpCnt+1))
    else
        _writeLog "****Error moving file $from";
        _writeErrorLog "Error $frm"
        ((errCnt=errCnt+1))
    fi

done < ./files/files-$4.txt

_writeLog "========================================="
_writeLog "Number movie directories processed $cnt"
_writeLog "Number movie directories moved $cpCnt"
_writeLog "#########################################"
_writeLog "Number movie directories that already existed $existCnt"
_writeLog "Number movie directories with issues $errCnt"

_writeLog "Complete"
_writeLog ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
