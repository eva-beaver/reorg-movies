#!/bin/bash

ls $1 -xN1 > files.txt

while IFS="" read -r p || [ -n "$p" ]
do
  found=0
  for i in {1910..2022}
  do
    # your-unix-command-here
    if [[ "$p" == *"($i)"* ]]; then
        #echo "It's there." $i $p
        #echo cp -R ./$1/$p ./$2
        from="./$1/$p"
        to="./$2/$i/$p"
        #echo cp -R -- "$from" "$to"
        if [ ! -d "./$2/$i" ] 
        then
            echo "Creating Directory ./$2/$i"
            mkdir ./"$2"/"$i"
        fi
        if [ -d "$to" ] 
        then
            echo "file $to already exists." 
            echo "file $to exists." >> ErrorExists.txt
        else
            echo "coping file $to "
            cp -R -- "$from" "$to"
            if [ $? -ne 0 ]
            then
                echo "$from" >> Erroroutputfile.txt
            else
                echo "copied $from" >> FilesProcessed.txt
               found=1
               break 
            fi
        fi
    fi
  done
if [ $found -ne 1 ]
then
    echo "copied $p" >> FilesNOTProcessed.txt
fi
done < files.txt
