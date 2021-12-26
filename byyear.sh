#!/bin/bash

###################### NOT USED

# This script will copy all movies from one directory to another and organise by year
# it assumes the directory name has the year in it like this (xxxx) e.g. (1956)
#
# param $1 is from directory
# param $2 set to 1 to acutally copy or 0 to pre-check
# param $3 is the unquie id for this run
#
#                      $1                            $2     $3 
# ./byyear.sh /mnt/share/allmovies/Alphabetical/X     1     X
# ./byyear.sh /mnt/share/movies/2020-11-November-1/   0     20111

# Need to add validation for input here

targetDrive=""

function _calcTargetDrive {

    #echo $1

    if [[ "$1" -ge 1900 ]]; then
        if [[ "$1" -le 1979 ]]; then
            #echo "MovieMaster1";
            targetDrive="/media/eva/MovieMaster1"
            return 
        fi
        if [[ "$1" -le 2025 ]]; then
            #echo "MovieMaster2";
            targetDrive="/media/eva/MovieMaster2"
            return
        fi
    else
        targetDrive="error";
    fi
}

#_calcTargetDrive "1920"
#echo $targetDrive
#_calcTargetDrive "1950"
#echo $targetDrive
#_calcTargetDrive "2000"
#echo $targetDrive
#_calcTargetDrive "2020"
#echo $targetDrive
#_calcTargetDrive "1974"
#echo $targetDrive

#exit 0

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

echo "Starting"
echo "========================================="

errcnt=0
cnt=0
dups=0

ls $1 -xN1 > files-$3.txt

while IFS="" read -r p || [ -n "$p" ]
do

    found=0

    # loop through each year that movie could be 
    # (I know this is crap can do it with regex if I can work it out, laters....)
    for i in {1910..2025}
    do

        if [[ "$p" == *"($i)"* ]]; then

            _calcTargetDrive $i

            #echo $targetDrive

            # set to and from directories
            from="$1/$p"
            to="$targetDrive/$i/$p"

            ((cnt=cnt+1))

            # check if year directory exists
            if [ ! -d "$targetDrive/$i" ] 
            then
                # is it a test run?
                if [ $2 -eq 1 ]
                then
                    # nope
                    echo "Creating Directory $targetDrive/$i"
                    mkdir "$targetDrive"/"$i"
                fi
            fi
            
            # check if destination direct is already there (already copied?)
            if [ -d "$to" ] 
            then
            
                echo "$cnt >>>>>>>>>>>>>> file $to already exists." 
                echo "$cnt >>>>>>>>>>>>>> file $to exists." >> ErrorExists-$3.txt
                ((dups=dups+1))
           
            else

                echo "$cnt coping file $from -> $to "
            
                # is it a test run?
                if [ $2 -eq 1 ]
                then
                    # nope
                    cp -R -- "$from" "$to"
                else
                    # yep
                    echo "$cnt Skipped $from -> $to"
                fi

                # did we get an error
                if [ $? -ne 0 ]
                then
                    echo "$cnt Error copying $from" >> Erroroutputfile-$3.txt
                else
                    echo "$cnt copied $from" >> FilesProcessed-$3.txt
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
        echo "Not copied $p" >> FilesNOTProcessed-$3.txt
    fi

done < files-$3.txt

echo "========================================="
echo "Number movie directories that already exist $dups"
echo "Number movie directories with issues $errcnt"

echo "Complete"

exit 0
