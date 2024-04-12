#!/usr/bin/bash

# timeout with SIGKILL to force exit
# on forced exit return code will be 137


# default call
timeout --signal=SIGKILL 5s caprice
[ $? -eq 137 ]  || exit 1

# call with search term
timeout --signal=SIGKILL 5s caprice "Rock"
[ $? -eq 137 ]  || exit 1

# call with unambiguous channel
timeout --signal=SIGKILL 5s caprice "Art Rock"
[ $? -eq 137 ]  || exit 1

# call with invalid channel name
timeout --signal=SIGKILL 5s caprice "46542654"
[ $? -eq 137 ]  || exit 1

# call with finder arguments
timeout --signal=SIGKILL 5s caprice -f "+s"
[ $? -eq 137 ]  || exit 1

# call with finder and player arguments
timeout --signal=SIGKILL 5s caprice -p "--mute=yes" -f "+s" "Blues Rock"
[ $? -eq 137 ]  || exit 1

