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
# ./copyit.sh /mnt/share/allmovies/Alphabetical/X /media/eva/Movie-Backup-1 1 X
# ./copyit.sh /mnt/share/movies/2020-11-November-1/ /media/eva/MovieWork/ 0 20111

# sudo mount.cifs //192.168.1.130/downloadedmovies /mnt/share/movies -o user=xxx,pass=xxx

# Need to add validation for input here

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

yearcnt=0

ls $1 -xN1 > files-$2-year.txt

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
        echo "No year found $p" >> FilesNOTProcessed-$2.txt
        echo "No year found $p"
    fi

done < files-$2-year.txt

echo "========================================="
echo "Number of movie year directories $yearcnt"
echo "Number of movie directories with issues $errcnt"
echo "========================================="

echo "Complete"
