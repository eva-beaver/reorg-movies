#!/bin/bash

# This script will copy all movies from one directory to another and organised by year 
# across 3 target directories for use by plex
# it assumes the directory name has the year in it only this xxxx e.g. 1956
#
# param $1 is from directory
# param $2 is the unquie id for this run for log
# param $3 set to 1 to acutally copy or 0 to pre-check
#
#                      $1          $2  $3 
# ./publishit.sh ./test-from-year test 1

# ./publishit.sh /media/downloads/byyear-2021-11-01 20211101 1

# sudo mount.cifs //192.168.1.130/downloadedmovies /mnt/share/movies -o user=xxx,pass=xxx

echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

INPUTDIR=$1
UNIQID=$2

logDir="./log"
fileDir="./files"

# Live
targetDrive1="/mnt/share/movies1/ByYear"
targetDrive2="/mnt/share/movies2/ByYear"
targetDrive3="/mnt/share/movies3/ByYear"

# Testing
#targetDrive1="./test-byyear/MovieMaster1"
#targetDrive2="./test-byyear/MovieMaster2"
#targetDrive3="./test-byyear/MovieMaster3"

targetDrive=""

totMovieCnt=0
totExistCnt=0
totErrCnt=0


#////////////////////////////////
function _calcTargetDrive {

    targetDrive=""

    if [[ "$1" -ge 1900 ]]; then
        if [[ "$1" -le 1985 ]]; then
            targetDrive=$targetDrive1
            return 
        fi
        if [[ "$1" -le 2005 ]]; then
            targetDrive=$targetDrive2
            return
        fi
        if [[ "$1" -le 2025 ]]; then
            targetDrive=$targetDrive3
            return
        fi
    else
        targetDrive="error";
    fi

}

#////////////////////////////////
function _writeLog {

    echo $1
    echo $1 >> ./log/publishit-log-$UNIQID.txt

}

#////////////////////////////////
function _writeErrorLog {

    echo $1 >> ./log/publishit-error-movies-$UNIQID.txt

}


#////////////////////////////////
function _processMoviesForYear {

    local movieCnt=0
    local existCnt=0
    local errCnt=0
    local cnt=0
    
    _writeLog "Processing file $INPUTDIR/$1 into ./files/files-$1-movies.txt"

    ls $INPUTDIR/$1 -xN1 > ./files/files-$1-movies.txt

    # Get a list of movies in the specific year directory
    while IFS="" read -r s || [ -n "$s" ]
    do
 
        ((cnt=cnt+1))

        _writeLog "____."
        _writeLog "____>>>> Processing movie #$cnt $s"

        _calcTargetDrive $1

        _writeLog "____targetDrive = $targetDrive"
        _writeLog "____." 

        local copyTo="$targetDrive/$1"

        # Check if target year directory already exists
        if [ -d "${copyTo}" ] ; then
            _writeLog "____$copyTo directory exists";
        else
            _writeLog "____>>$copyTo does exist, creating";
            mkdir $copyTo
        fi

        local copMovieFrom=$INPUTDIR/$1/$s
        local copyMovieTo="$targetDrive/$1/$s"

        # Check if movie directory already exists
        if [ -d "${copyMovieTo}" ] ; then
            _writeLog "****$copyMovieTo directory exists";
            ((existCnt=existCnt+1))
            ((totExistCnt=totExistCnt+1))
            _writeErrorLog "Duplicate $copMovieFrom"
        else
            _writeLog "____>>$copyMovieTo does not exist, copying";
            cp -R -- "$copMovieFrom" "$copyMovieTo" 
            if [ $? -eq 0 ]; then
                _writeLog "____Copied $s to $copyMovieTo";
                ((movieCnt=movieCnt+1))
                ((totMovieCnt=totMovieCnt+1))
            else
                _writeLog "****Error Copied failed for $s";
                _writeErrorLog "Error $copMovieFrom"
                ((errCnt=errCnt+1))
                ((totErrCnt=totErrCnt+1))
            fi
        fi


    done < ./files/files-$1-movies.txt

    _writeLog "."
    _writeLog "========================================="
    _writeLog "$movieCnt movies copied for $1"
    _writeLog "$existCnt movies already existed at [$targetDrive/$1] for $1"
    _writeLog "$errCnt errors"
    _writeLog "========================================="
    _writeLog "."

}

# validationing
#////////////////////////////////

if [ -d "${INPUTDIR}" ] ; then
    echo "$INPUTDIR is a directory";
else
    if [ -f "${INPUTDIR}" ]; then
        echo "Directory [${INPUTDIR}] is a file";
        exit 1
    else
        echo "Directory [${INPUTDIR}] is not valid";
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

_writeLog "Source Directory is valid [$INPUTDIR]"

#exit 0

# Processing starts
#////////////////////////////////

_writeLog "Starting"
_writeLog "========================================="
_writeLog "."

rm ./log/copyit-log-$UNIQID.txt

yearcnt=0

ls $1 -xN1 > ./files/files-$2-year.txt

errcnt=0

# Generate a file containing all the directories to process in the source directory
# each direct is just a year number
while IFS="" read -r p || [ -n "$p" ]
do

    ((yearcnt=yearcnt+1))

    _processMoviesForYear $p

done < ./files/files-$2-year.txt

_writeLog "========================================="
_writeLog "Number of movie year directories $yearcnt"
_writeLog "Number of movie directories with issues $errcnt"
_writeLog "========================================="
_writeLog "$totMovieCnt movies copied"
_writeLog "$totExistCnt movies already existed"
_writeLog "$totErrCnt errors"
_writeLog "========================================="
_writeLog "."

_writeLog "Complete"
_writeLog ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
