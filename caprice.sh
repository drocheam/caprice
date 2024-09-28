#!/bin/bash

# define player and finder
PLAYER='mpv --msg-level=cplayer=warn'
FINDER='fzf -i -e --cycle --with-nth ..-2 --preview "previewer {}"'

# print usage
usage() 
{ 
	echo "Usage: caprice [-p <additional player options>] [-f <additional finder options>] [<query string>]"
	echo "-h for help"
	echo
	echo "Play channels of Radio Caprice in your terminal."
	echo "Finder and player tool are specified inside the script (mpv and fzf by default)."
	echo
	echo "Exemplary calls:"
	echo "caprice"
	echo "caprice 'blues rock'"
	echo 'caprice -p "--mute=yes" -f "+s"'
	echo 'caprice -f "+s" electronic'
	exit 1
}

# process arguments
while getopts ":p:f:h" o; do
    case "${o}" in
        p)
            PLAYER+=" ${OPTARG}";;
        f)
            FINDER+=" ${OPTARG}";;
        * | h)
            usage;;
    esac
done
shift $((OPTIND-1))

# remaining options are part of the query string
query="" && [ -n "$1" ] && query=" -1 -q '$*'"

# decide which path to radios.json to use, use current folder if available, otherwise installation path
radio_path='/usr/local/share/caprice/radios.json' && [ -f './radios.json' ] && radio_path='./radios.json'

# get name and link list from json
# string before | holds channel name, followed by the shoutcast link and lastly the stream link
list=$(sed -r -n 's/.*name":"([^"]+)","style":"([0-9]+).*shoutcast":"([^"]+)","url":"([^"]+)".*/style\2 \1 |\3|\4/p' "$radio_path")

# fix forwards slashes and replace ports 8000 with 8002 for better caching
list=$(echo "$list" | sed 's|\\/|/|g' | sed 's|:8000/|:8002/|')

# replace style number by genre name
list=$(echo "$list" | sed -r -n ""\
" s|style0 |Blues/Funk/Soul         -   |p; "\
" s|style1 |Classical               -   |p; "\
" s|style2 |Country                 -   |p; "\
" s|style3 |Electronic              -   |p; "\
" s|style4 |Ethinc/Folk/Spiritual   -   |p; "\
" s|style5 |Jazz                    -   |p; "\
" s|style6 |Metal/Hardcore          -   |p; "\
" s|style7 |Miscellaneous           -   |p; "\
" s|style8 |Pop                     -   |p; "\
" s|style9 |Rap/Hip Hop             -   |p; "\
"s|style10 |Reggae/Ska              -   |p; "\
"s|style11 |Rock                    -   |p; "\
"s|style12 |WAHCOH                  -   |p; ")

# sort list alphabetically
list=$(echo "$list" | sort)

# preview function
previewer()
{
    name=$(echo "$*" | cut -d "|" -f 1 | tr -s " ") 
	link=$(echo "$*" | cut -d "|" -f 2)
	stream=$(echo "$*" | cut -d "|" -f 3)

	# get last-played-table
	curl_cmd='curl -s -A "Mozilla" --max-time 0.5 -G "$link/played.html"'
	table=$(eval "$curl_cmd" || eval "$curl_cmd") # try twice
	
	if [ -z "$table" ]; then
		printf '\n   Timeout getting data\n\n'
	else
		# make a line per source code table, choose the desired one with played songs
		table=$(echo "${table//<table/$'\n'<table}" | grep -a "Played @")

		# eye candy
		table=${table//<td>/   }  # replace tabs
		table=${table//<\/tr>/$'\n'}  # add newlines
		table=$(echo "$table" | sed -e 's/<[^>]*>//g')  # remove html tags
		table=$(echo "$table" | sed -r 's/\s+(.*)\s*Current\sSong/>> \1/')  # show current song

		# add header
		printf '\n   RADIO CAPRICE - %s\n\n\n   Previously Played Tracks:\n\n%s' "$name" "$table"
	fi
}

export -f previewer

# selection and play loop
# exit player to reselect a radio, exit finder to exit program
while : 
do
    # let the user pick a genre
    choice=$(echo "$list" | eval "$FINDER $query")

    # exit if nothing was chosen
    [ -n "$choice" ] || exit

    # extract stream link and channel name
    stream=$(echo "$choice" | cut -d "|" -f 3)
    name=$(echo "$choice" | cut -d "|" -f 1 | tr -s " ") 

    # print channel
    printf '\nRADIO CAPRICE - %s\n\n' "$name"

    # play
	$PLAYER "$stream"
done
