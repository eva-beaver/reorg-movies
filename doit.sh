#!/bin/bash

# This script will copy all movies from one directory to another and organise by year
# it assumes the directory name has the year in it like this (xxxx) e.g. (1956)
#
# param $1 is from directory
# param $2 is to directory
# param $3 set to 1 to acutally copy or 0 to pre-check
# param $4 is the unquie id for this run
#
#                      $1                                 $2             $3 $4
# ./doit.sh /mnt/share/allmovies/Alphabetical/X /media/eva/Movie-Backup-1 1 X
# ./doit.sh /mnt/share/movies/2020-11-November-1/ /media/eva/MovieWork/ 0 20111

# sudo mount.cifs //192.168.1.130/downloadedmovies /mnt/share/movies -o user=xxx,pass=xxx

UNIQID=$4

logDir="./log"
fileDir="./files"

#////////////////////////////////
function _writeLog {

    echo $1
    echo $1 >> ./log/doit-log-$UNIQID.txt

}

#////////////////////////////////
function _writeErrorLog {

    echo $1 >> ./log/doit-error-movies-$UNIQID.txt

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

errcnt=0
cnt=0
dups=0

ls $1 -xN1 > ./files/files-$4.txt

while IFS="" read -r p || [ -n "$p" ]
do

    found=0

    # loop through each year that movie could be 
    # (I know this is crap can do it with regex if I can work it out, laters....)
    for i in {1900..2025}
    do

        if [[ "$p" == *"($i)"* ]]; then

            # set to and from directories
            from="$1/$p"
            to="$2/$i/$p"
            #to="$2/$i/$p [Red]"

            ((cnt=cnt+1))

            # check if year directory exists
            if [ ! -d "$2/$i" ] 
            then
                # is it a test run?
                if [ $3 -eq 1 ]
                then
                    # nope
                    _writeLog "Creating Directory $2/$i"
                    mkdir "$2"/"$i"
                fi
            fi
            
            # check if destination direct is already there (already copied?)
            if [ -d "$to" ] 
            then
            
                _writeErrorLog "$cnt >>>>>>>>>>>>>> file $to already exists." 
                echo "$cnt >>>>>>>>>>>>>> file $to exists." >> ./files/ErrorExists-$4.txt
                ((dups=dups+1))
           
            else

                _writeLog "$cnt coping file $from -> $to "
            
                # is it a test run?
                if [ $3 -eq 1 ]
                then
                    # nope
                    cp -R -- "$from" "$to"
                else
                    # yep
                    _writeLog "Check mode $cnt Skipped $from -> $to"
                fi

                # did we get an error
                if [ $? -ne 0 ]
                then
                    _writeErrorLog "$cnt Error copying $from" >> Erroroutputfile-$4.txt
                else
                    echo "$cnt copied $from" >> ./files/FilesProcessed-$4.txt
                    found=1
                    break 
                fi
            fi
        fi

    done

    # did we actuall copy it?
    if [ $found -ne 1 ]
    then
        # nope
        ((errcnt=errcnt+1))
        _writeErrorLog "Not copied $p"
        echo "Not copied $p" >> ./files/FilesNOTProcessed-$4.txt
        found=0
    fi

done < ./files/files-$4.txt

_writeLog "========================================="
_writeLog "Number movie directories processed $cnt"
_writeLog "#########################################"
_writeLog "Number movie directories that already exist $dups"
_writeLog "Number movie directories with issues $errcnt"

_writeLog "Complete"
_writeLog ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
