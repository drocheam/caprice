#!/bin/bash

# change to your player and finder
PLAYER='mpv --msg-level=cplayer=warn'
FINDER='fzf -i -e --cycle --with-nth ..-2 --preview "previewer {}"'

# add query string if this script has parameters
query="" && [ -n "$1" ] && query+=" -1 -q '$*'"

# decide with path to radios.json to use, use current folder if available
radio_path='/usr/local/share/caprice/radios.json' && [ -f './radios.json' ] && radio_path='./radios.json'

# get name and link list from json
# string before | holds channel name, next is the shoutcast link and last the stream link
list=$(grep 'name' "$radio_path" | sed -r 's/.*name\":\"(.*)\","style".*shoutcast\":\"(.*)\",\"url\":\"(.*)\".*/\1 |\2|\3/')

# fix forwards slashes
list=$(echo "$list" | sed 's/\\\//\//g')

# replace ports 8000 with 8002 for better caching
list=$(echo "$list" | sed 's/:8000\//:8002\//')

# sort list
list=$(echo "$list" | sort)

# preview function
function previewer(){

	choice="$*"
	name=$( echo "$choice" | cut -d "|" -f 1)
	link=$( echo "$choice" | cut -d "|" -f 2)
	stream=$( echo "$choice" | cut -d "|" -f 3)

	# get last-played-table
	table=$(curl -s -A "Mozilla" --max-time 0.5 -G "$link/played.html")
	
	# sometimes it works at second try
	[ -z "$table" ] && table=$(curl -s -A "Mozilla" --max-time 0.5 -G "$link/played.html")

	if [ -z "$table" ]; then
		printf '\n   Timeout getting data\n\n'
	else	
		table=$(echo "${table//<table/$'\n'<table}" | grep -a "Played @")

		# eye candy
		table=${table//<\/tr>/$'\n'}
		table=${table//<td>/   }
		table=$(echo "$table" | sed -r 's/\s+(.*)\s*Current Song/>> \1/')
		table=$(echo "$table" | sed -e 's/<[^>]*>//g')

		#table=$(echo "$table" | sed -r 's/.*Login(.*)Written.*/\1/')
		printf '\n   RADIO CAPRICE - %s\n\n\n   Previously Played Tracks:\n\n%s' "$name" "$table"
	fi

	echo

	# don't start the player immediately
	# otherwise scrolling or typing in the results would call him multiple times
	sleep 0.2
	$PLAYER "$stream" &> /dev/null
}

export -f previewer
export PLAYER

# error flag
error=0

# use loop to restart on errors
while : 
do
	# no error -> show selection screen
	if [ $error -eq 0 ]; then

		# let user pick a genre
		choice=$(echo "$list" | eval "$FINDER $query")

		# exit if nothing was chosen
		[ -n "$choice" ] || exit

		# remove search query for next iteration
		query=""

		# extract stream link and channel name
		link=$( echo "$choice" | cut -d "|" -f 3)
		name=$( echo "$choice" | cut -d "|" -f 1)

		# print channel
		printf '\nRADIO CAPRICE - %s\n\n' "$name"

	# else print message and wait
	else
		echo 'Error, waiting and retrying...'
		sleep 2
	fi

	# reset error flag
	error=0

	# start stream
	# set error flag on error, when PLAYER exits normally,
	# the selection screen will be shown in the next iteration
	$PLAYER "$link" || error=1
done

