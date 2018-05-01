#!/usr/bin/env bash

if command -v gstat > /dev/null
then
	stat=gstat
else 
	stat=stat
fi

if command -v gdate > /dev/null
then
	date=gdate
else 
	date=date
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo $DIR

while read line
do
	echo "Processing $line"
	folder="$DIR/data/${line//[^0-9a-zA-Z]/_}"
	test -d $folder || mkdir -p $folder

	target_file=$($date -u +"%Y-%m-%dT%H:%M:%S.%3NZ").txt
  
	wget -O "$folder/current.txt" $line
	newest=$(ls $folder | sort -r -n | head -n1)
	echo "Last backup: $newest"
	if [ $newest = "current.txt" ]
	then 
		echo "Initial run"
		echo "Copying to: $target_file"
		cp "$folder/current.txt" "$folder/$target_file"
		continue
	fi

	latest_size=$($stat -c %s $folder/$newest)
	current_size=$($stat -c %s $folder/current.txt)
	if [ $latest_size -ne $current_size ]
	then
		echo "Changed $latest_size -> $current_size"
		echo "Copying to: $target_file"
		cp "$folder/current.txt" "$folder/$target_file"
	else
		echo "Unchanged $latest_size"
	fi
	echo -e "\n\n\n"
done < "$DIR/targets"


