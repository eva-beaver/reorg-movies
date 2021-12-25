#!/bin/bash


# ./checkit.sh /mnt/share/allmovies/Alphabetical/X X
# ./checkit.sh /mnt/share/movies/2021-01-January-1/ xx

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

cnt=0

ls $1 -xN1 > files-$2.txt

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

done < files-$2.txt

echo "========================================="
echo "Number of movie directories $cnt"
echo "Number of movie directories with issues $errcnt"
echo "========================================="

echo "Complete"
