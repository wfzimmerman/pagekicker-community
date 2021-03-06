#!/bin/bash

echo "*** HOLY CRAP!  BEGINNING TO SCREEN OUT NAUGHTY SEEDS! *** "

if shopt -q  login_shell ; then

	if [ ! -f "$HOME"/.pagekicker/config.txt ]; then
		echo "config file not found, creating /home/<user>/.pagekicker, put config file there"
		mkdir -p -m 755 "$HOME"/.pagekicker
		echo "exiting"
		exit 1
	else
		. "$HOME"/.pagekicker/config.txt
		echo "read config file from login shell $HOME""/.pagekicker/config.txt"
	fi
else
	. /home/$(whoami)/.pagekicker/config.txt #hard-coding /home is a hack
	echo "read config file from nonlogin shell /home/$(whoami)/.pagekicker/config.txt"
fi

cd $scriptpath

. includes/set-variables.sh

# argparse
# $1 is inbound seedphrases file
# $2 is verbose

echo "uuid received is $uuid"

mkdir -p -m 777 $TMPDIR
mkdir -p -m 777 $TMPDIR$uuid
mkdir -p -m 777 $TMPDIR$uuid/seeds

while read -r line; do

if grep -qw "$line" "seeds/disallowed-seeds.txt" ; then

	echo "the seed "$line "was disallowed"
	disallowed="$disallowed""\n ""$line"

else
	if [ "$2" = "v" ] ; then
		echo "$line is not a naughty word -- your momma raised you right!"
	else
		true
		echo "$line is not a naughty word -- your momma raised you right!"
	fi

	echo "$line" >> $TMPDIR$uuid/seeds/allowed_seeds.txt
fi


done <$1

cp $TMPDIR$uuid/seeds/allowed_seeds.txt $TMPDIR$uuid/seeds/seedphrases

if [ -z  ${disallowed+x} ] ; then
	echo "I checked your seeds to be sure there were no naughty words -- your momma raised you right!" >> $TMPDIR$uuid/seeds/process.md

else
	sendemail -t "$customer_email" \
		-m "Disallowed words removed from $booktitle\n: $disallowed" \
		-u "Disallowed words removed from $booktitle." \
		-f "$GMAIL_ID" \
		-f "$GMAIL_ID" \
		-xu "$GMAIL_ID" \
		-xp "$GMAIL_PASSWORD" \
		-s smtp.gmail.com:587 \
		-s smtp.gmail.com:587 \
		-o tls=yes
fi

echo " * * * DONE CHECKING NAUGHTY WORDS * * * "
exit 0
