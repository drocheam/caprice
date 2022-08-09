#!/bin/bash

# define player and finder
PLAYER='mpv --msg-level=cplayer=warn'
FINDER='fzf -i -e --cycle --with-nth ..-2 --preview "previewer {}"'

# add query string if this script got parameters
query="" && [ -n "$1" ] && query=" -1 -q '$*'"

# decide which path to radios.json to use, use current folder if available, otherwise installation path
radio_path='/usr/local/share/caprice/radios.json' && [ -f './radios.json' ] && radio_path='./radios.json'

# get name and link list from json
# string before | holds channel name, followed by the shoutcast link and lastly the stream link
list=$(sed -r -n 's/.*name":"([^"]+)","style.*shoutcast":"([^"]+)","url":"([^"]+)".*/\1 |\2|\3/p' "$radio_path")

# fix forwards slashes and replace ports 8000 with 8002 for better caching
list=$(echo "$list" | sed 's|\\/|/|g' | sed 's|:8000/|:8002/|')

# sort list alphabetically
list=$(echo "$list" | sort)

# preview function
previewer()
{
	name=$(echo "$*" | cut -d "|" -f 1)
	link=$(echo "$*" | cut -d "|" -f 2)
	stream=$(echo "$*" | cut -d "|" -f 3)

	# get last-played-table
	curl_cmd='curl -s -A "Mozilla" --max-time 0.5 -G "$link/played.html"'
	table=$(eval "$curl_cmd" || eval "$curl_cmd") # try twice
	
	if [ -z "$table" ]; then
		printf '\n   Timeout getting data\n\n'
	else
		# make a line per source code table, choose the one with played songs
		table=$(echo "${table//<table/$'\n'<table}" | grep -a "Played @")

		# eye candy
		table=${table//<td>/   }
		table=${table//<\/tr>/$'\n'}
		table=$(echo "$table" | sed -e 's/<[^>]*>//g')
		table=$(echo "$table" | sed -r 's/\s+(.*)\s*Current\sSong/>> \1/')

		printf '\n   RADIO CAPRICE - %s\n\n\n   Previously Played Tracks:\n\n%s' "$name" "$table"
	fi
}

export -f previewer
export PLAYER

# let user pick a genre
choice=$(echo "$list" | eval "$FINDER $query")

# exit if nothing was chosen
[ -n "$choice" ] || exit

# extract stream link and channel name
stream=$(echo "$choice" | cut -d "|" -f 3)
name=$(echo "$choice" | cut -d "|" -f 1)

# print channel
printf '\nRADIO CAPRICE - %s\n\n' "$name"

# play and restart on errors
while : 
do
	$PLAYER "$stream"
	echo 'Error, waiting and retrying...'
	sleep 2
done
