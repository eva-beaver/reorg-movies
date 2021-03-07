#!/bin/bash


# ./doit.sh /mnt/share/allmovies/Alphabetical/X X

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

ls $1 -xN1 > files-$2.txt

cnt=0

while IFS="" read -r p || [ -n "$p" ]
do
  found=0

  for i in {1910..2022}
  do

    if [[ "$p" == *"($i)"* ]]; then

        from="$1/$p"
        found=1
        break 

    fi

  done

    if [ $found -ne 1 ]
    then
        ((cnt=cnt+1))
        echo "Not copied $p" >> FilesNOTProcessed-$2.txt
    fi

done < files-$2.txt

echo "========================================="
echo "Number movie directories with issues $cnt"

echo "Complete"
