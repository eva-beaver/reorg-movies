#!/bin/bash


# ./doit.sh /mnt/share/allmovies/Alphabetical/X /media/eva/Movie-Backup-1 1 X

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

PASSED=$2

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

ls $1 -xN1 > files-$4.txt

while IFS="" read -r p || [ -n "$p" ]
do
  found=0
  for i in {1910..2022}
  do

    if [[ "$p" == *"($i)"* ]]; then

        from="$1/$p"
        to="$2/$i/$p"

        if [ ! -d "$2/$i" ] 
        then
            echo "Creating Directory $2/$i"
            mkdir "$2"/"$i"
        fi
        
        if [ -d "$to" ] 
        then
            echo "file $to already exists." 
            echo "file $to exists." >> ErrorExists-$4.txt
        else
            echo "coping file $from -> $to "
            if [ $3 -eq 1 ]
            then
                cp -R -- "$from" "$to"
            else
                echo "Skipped $from -> $to"
            fi
            if [ $? -ne 0 ]
            then
                echo "$from" >> Erroroutputfile-$4.txt
            else
               echo "copied $from" >> FilesProcessed-$4.txt
               found=1
               break 
            fi
        fi
    fi

  done

if [ $found -ne 1 ]
then
    echo "copied $p" >> FilesNOTProcessed-$4.txt
fi
done < files-$4.txt
