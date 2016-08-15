#!/bin/bash

# $1 should be the subreddit

url="https://www.reddit.com/r/$1/comments.json"

time=$(date +%s)
rawInputFile="/tmp/$time-comments-$1.json"
filteredInputFile="/tmp/$time-filtered-comments-$1.json"
wget -q -O $rawInputFile $url

source last-check.sh

jq "[.data.children[].data | select(.created_utc>$lastCheck)]" $rawInputFile > $filteredInputFile

path=`pwd`/last-check.sh
echo "lastCheck=$time" > "$path"

length=$(jq '. | length' $filteredInputFile)

	echo $filteredInputFile
for x in $(seq 0 $(($length - 1))); do
	noP=$(jq ".[$x].body" $filteredInputFile | ./count-paren.sh)
	emoticonResp=$(jq ".[$x].body" $filteredInputFile | grep -o ':(' | sed 's/[()]//g')
	echo "$noP"
	respBody=""
	if [ $noP -gt 15 ]; then
		[ -n "$emoticonResp" ] && respBody+=$'	 ▀  ▀ \n'
		respBody+=$'	▀▄▄▄▄▀\nSeriously, stop spamming'
	elif [ $noP -gt 0 ]; then
		respBody="$emoticonResp$(printf ')%.0s' $(seq 1 $noP))"
	fi
	if [ $noP -gt 0 ]; then
		./post-comment.sh \
			"$(jq -r ".[$x].name" $filteredInputFile)" \
"$respBody

---
This is an autogenerated response. [source](https://github.com/hugonikanor/reddit-parenthesis-bot) | /u/HugoNikanor"
	fi
done
