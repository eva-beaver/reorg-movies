#!/bin/bash

Move a directory of movies to a directory of the same name without the extension

# ./movefiletodirit.sh /mnt/share/allmovies/backup-3/X 0000 [Red]
# ./movefiletodirit.sh /mnt/share/movies/2021-01-January-1/ 0000 [Red]
# sudo ./movefiletodirit.sh /mnt/share/backup-3/Movies12 0000 [Red]

# sudo movefiletodirit.cifs //192.168.1.130/backup-3 /mnt/share/backup-3/ -o user=xxx,pass=xxx

UNIQID=$2

logDir="./log"
fileDir="./files"

#////////////////////////////////
function _writeLog {

    echo $1
    echo $1 >> ./log/movefiletodirit-log-$UNIQID.txt

}

#////////////////////////////////
function _writeErrorLog {

    echo $1 >> ./log/movefiletodirit-error-$UNIQID.txt

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

# get only file names
ls $1 -phxN1 | grep -v / > ./files/files-tomove-$3.txt

dirCnt=0
movCnt=0
existCnt=0
errCnt=0
cnt=0

while IFS="" read -r p || [ -n "$p" ]
do
  
    found=0

    ((cnt=cnt+1))

    dirName=${p::-4}

    fullDir=$1/$dirName" $3"

    #echo $fullDir
    #exit 0

    # Check if movie directory already exists
    if [ -d "${fullDir}" ] ; then
        _writeLog "****$fullDir directory exists";
        ((existCnt=existCnt+1))
        _writeErrorLog "Already a directory $fullDir"
    else
        _writeLog ">>>>$fullDir does not exist, creating";
        mkdir "$fullDir"
        if [ $? -eq 0 ]; then
            _writeLog "____Created $fullDir";
            ((dirCnt=dirCnt+1))
            _writeLog "____moving to $fullDir";
            mv "$1/$p" "$fullDir"
            if [ $? -eq 0 ]; then
                _writeLog "____Moved $p";
                ((movCnt=movCnt+1))
            else
                _writeLog "****Error moving file $p";
                _writeErrorLog "Error $p"
                ((errCnt=errCnt+1))
            fi
        else
            _writeLog "****Error directory create failed for $fullDir";
            _writeErrorLog "Error $p"
            ((errCnt=errCnt+1))
        fi
    fi

done < ./files/files-tomove-$3.txt

_writeLog "========================================="
_writeLog "Number of input movies $cnt"
_writeLog "Number of directories created $dirCnt"
_writeLog "Number of movies moved $movCnt"
_writeLog "#########################################"
_writeLog "Number of directories with issues $existCnt"
_writeLog "Number of movie directories with issues $errCnt"
_writeLog "========================================="

_writeLog "Complete"
