#!/bin/bash

# change to your player and finder
PLAYER="mpv --msg-level=cplayer=warn,display-tags=status"  # mpv with less verbose output
FINDER="fzf -i -e --cycle"

# add query string if this script has parameters
[[ -n "$1" ]] && FINDER+=" -1 -q '$*'"

# get page with genre database
scode=$(curl -s http://radcap.ru/index-db.html)

# some genre tables are formatted incorrectly, correct to one element per line
scode=$(echo "$scode" | sed -r 's/<\/span><\/a><br>/\n/')

# for some reasons this genre has a newline character in its name
scode=$(echo "$scode" | sed -r -z 's/РУССКИЙ\/ГОРОДСКОЙ\/ЖЕСТОКИЙ\/\s*РОМАНС/РУССКИЙ\/ГОРОДСКОЙ\/ЖЕСТОКИЙ\/РОМАНС/')

# get genre name and page name
# misc genre: class="genre", all other genres: class="genres220"
channel_list=$(echo "$scode" | grep genres | sed -r 's/.*<a href=\"(.*)\" class=\"genres(220)?\">(.*)<span.*/"\3" "\1"/')

# replace breaks and ampersands
channel_list=${channel_list//&amp;/&}
channel_list=${channel_list//<br>/}

# load into associative array
# index is genre name, value is link to genre page
declare -A channels
for i in "${channel_list[*]}"
do
	eval "$(echo "$i" | sed -r 's/(.+") (".*")/channels[\1]=\2/')"
done

# make sorted genre list, let user pick one
list=$(printf '%s\n' "${!channels[@]}" | sort)

# error flag
error=0

# use loop to restart on errors
while : 
do
	# no error -> show selection screen
	if [[ $error  -eq 0 ]]; then
		choice=$(echo "$list" | eval "$FINDER")

		# exit if nothing was chosen
		[[ -n "$choice" ]] || exit

		# get stream link from genre page
		url="http://radcap.ru/${channels[$choice]}"
		radio_url=$(curl -s "$url" | grep "\"title\":\"1\",file:\"" | sed -r 's/.*(http:.+)\"},.*/\1/')

		# print channel
		printf '\nRADIO CAPRICE - %s\n\n' "$choice"

	# else print message and wait
	else
		echo "Error, waiting and retrying..."
		sleep 3
	fi

	# reset error flag
	error=0

	# start stream
	# set error flag on error
	# when PLAYER exits normally,
	# the selection screen will be shown in the next iteration
	$PLAYER "${radio_url}" || error=1
done

