#!/bin/bash

# accepts book topic and book type definition, then builds book
# must be run from apache2/htdocs/pk-new/development/scripts or same for prod

echo "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"

CANON=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename -- "$0")")

if [ "$CANON" = "/opt/bitnami/apache2/htdocs/pk-new/development/scripts/bin/builder-relative.sh" ] ; then
	scriptpath="/opt/bitnami/apache2/htdocs/pk-new/development/scripts/"
	echo "my startup scriptpath is" $scriptpath
else
	scriptpath="/opt/bitnami/apache2/htdocs/pk-production/scripts/"
	echo "my startup scriptpath is" $scriptpath
fi

cd $scriptpath
. ../conf/config.txt

. includes/set-variables.sh
#echo "set variables, now echoing them"
# . includes/echo-variables.sh

bazaar_revision=`cat /home/bitnami/bzr_dev_rev`
echo "bazaar revision number is" $bazaar_revision

echo "sfb_log is" $sfb_log

echo "completed reading config file and  beginning logging at" `date +'%m/%d/%y%n %H:%M:%S'` 

jobprofile="default"
jobprofilename="default"
buildtarget=$TMPDIR"test"
singleseed="none"
sample_tweets="yes"
todaysdate=`date`
wikilang="en"
summary="false"
truncate_seed="yes"
coverfont="Minion"
covercolor="RosyBrown"

export PERL_SIGNALS="unsafe"
echo "PERL_SIGNALS" is $PERL_SIGNALS

while :
do
case $1 in
--help | -\?)
echo "for help review source code for now"
exit 0  # This is not an error, the user requested help, so do not exit status 1.
;;
--passuuid)
passuuid=$2
shift 2
;;
--passuuid=*)
passuuid=${1#*=}
shift
;;
--seedfile)
seedfile=$2
shift 2
;;
--seedfile=*)
seedfile=${1#*=}
shift
;;
--booktype)
booktype=$2
shift 2
;;
--booktype=*)
booktype=${1#*=}
shift
;;
--booktitle)
booktitle=$2
shift 2
;;
--booktitle=*)
booktitle=${1#*=}
shift
;;
--buildtarget)
buildtarget=$2
shift 2
;;
--buildtarget=*)
buildtarget=${1#*=}
shift
;;
--singleseed)
singleseed=$2
shift 2
;;
--singleseed=*)
singleseed=${1#*=}
shift
;;
--truncate_seed)
truncate_seed=$2
shift 2
;;
--truncate_seed=*)
shift
truncate_seed=${1#*=}
;;
--sample_tweets)
sample_tweets=$2
shift 2
;;
--sample_tweets=*)
shift
sample_tweets=${1#*=}
;;
--ebook_format)
ebook_format=$2
shift 2
;;
--ebook_format=*)
shift
ebook_format=${1#*=}
;;
--jobprofile)
jobprofile=$2
shift 2
;;
--jobprofile=*)
jobprofile=${1#*=}
shift
;;
--jobprofilename)
jobprofilename=$2
shift 2
;;
--jobprofilename=*)
jobprofilename=${1#*=}
shift
;;
--wikilang)
wikilang=$2
shift 2
;;
--wikilang=*)
wikilang=${1#*=}
shift
;;
--summary)
summary=$2
shift 2
;;
--summary=*)
summary=${1#*=}
shift
;;
--safe_product_name)
safe_product_name=$2
shift 2
;;
--safe_product_name=*)
safe_product_name=${1#*=}
shift
;;
--coverfont)
coverfont=$2
shift 2
;;
--coverfont=*)
coverfont=${1#*=}
shift
;;
--covercolor)
covercolor=$2
shift 2
;;
--covercolor=*)
covercolor=${1#*=}
shift
;;
--fromccc)
fromccc=$2
shift 2
;;
--fromccc=*)
fromccc=${1#*=}
shift
;;
--editedby)
editedby=$2
shift 2
;;
--editedby=*)
editedby=${1#*=}
shift
;;
--yourname)
yourname=$2
shift 2
;;
--yourname=*)
yourname=${1#*=}
shift
;;
--customername)
customername=$2
shift 2
;;
--customername=*)
customername=${1#*=}
shift
;;
--storecode)
storecode=$2
shift 2
;;
--storecode=*)
storecode=${1#*=}
shift
;;
--environment)
environment=$2
shift 2
;;
--environment=*)
environment=${1#*=}
shift
;;
--shortform)
shortform=$2
shift 2
;;
--shortform=*)
shortform=${1#*=}
shift
;;
--flickr)
flickr=$2
shift 2
;;
--flickr=*)
flickr=${1#*=}
shift
;;
--dontcleanupseeds)
dontcleanupseeds=$2
shift 2
;;
--dontcleanupseeds=*)
dontcleanupseeds=${1#*=}
shift
;;
  --) # End of all options
            shift
            break
            ;;
        -*)
            echo "WARN: Unknown option (ignored): $1" >&2
            shift
            ;;
        *)  # no more options. Stop while loop
            break
            ;;

esac
done

# Suppose some options are required. Check that we got them.

if [ ! "$passuuid" ] ; then
	echo "creating uuid"
	uuid=$("$PYTHON_BIN"  -c 'import uuid; print uuid.uuid1()')
	echo "uuid is" $uuid | tee --append $xform_log
	mkdir -p -p -m 777 $TMPDIR$uuid
else
	uuid=$passuuid
	echo "received uuid " $uuid
	mkdir -p -p -m 777 $TMPDIR$uuid
fi

if [ -z "$covercolor" ]; then
	covercolor="RosyBrown"
	echo "no cover color in command line so I set it to "$covercolor
else
	echo "$covercolor"
fi

if [ -z "$coverfont" ]; then
	coverfont="Minion"
	echo "no cover font in command line so I set it to "$coverfont
else
	echo "$coverfont"
fi

if [ -z "$wikilang" ]; then
	wikilang="en"
	echo "no wikilang in command line so I set it to "$wikilang
else
	echo "$wikilang"
fi


TEXTDOMAIN=SFB
echo $"hello, world, I am speaking" $LANG

safe_product_name=$(echo "$booktit
le" | sed -e 's/[^A-Za-z0-9._-]/_/g')
echo "safe product name is" $safe_product_name
echo "jobprofile is" $jobprofile
echo "jobprofilename is" $jobprofilename

. "$confdir"jobprofiles/"$jobprofile"
cat "$confdir"jobprofiles/"$jobprofile"
echo "$authorbio"

#sku=`tail -1 < "$LOCAL_DATA""SKUs/sku_list"`
echo "sku" $sku


echo "test $covercolor" "$coverfont"


if [ "$singleseed" = "none" ] ; then
	echo "no singleseed"
else
	seed="$singleseed"
	echo "seed is now singleseed" "$seed"
	echo "$seed" > "$seedfile"
fi

. $confdir"jobprofiles/imprints/pagekicker/pagekicker.imprint"
. includes/api-manager.sh

echo "test $covercolor" "$coverfont"


# create directories I will need

mkdir -p -m 777 $TMPDIR$uuid/wiki
mkdir -p -m 777 $TMPDIR$uuid/user
mkdir -p -m 777 $TMPDIR$uuid/flickr
mkdir -p -m 777 $TMPDIR$uuid/fetch
mkdir -p -m 777 $TMPDIR$uuid/seeds
mkdir -p -m 777 $TMPDIR$uuid/images
mkdir -p -m 777 $TMPDIR$uuid/mail
mkdir -p -m 755 $TMPDIR$uuid/cover
mkdir -p -m 755 $TMPDIR$uuid/twitter

#move assets into position

if [ "$truncate_seed" = "yes" ] ; then
	echo "truncating"
	echo $seedfile
	seedfile=$(dirname $seedfile)
	seedfile=$seedfile"/seedlist"
	echo "truncated seedfile" $seedfile " as kluge for var customer path"
else
	echo "not truncating seedfile"
fi

echo "test seedfile is " $seedfile
cp $scriptpath"assets/pk35pc.jpg" $TMPDIR$uuid/pk35pc.jpg
cp $seedfile $TMPDIR$uuid/seeds/seedphrases
echo "test copy failed"
cp $confdir"jobprofiles"/imprints/$imprintdir/$imprintlogo  $TMPDIR$uuid
cp $confdir"jobprofiles"/signatures/$sigfile $TMPDIR$uuid
cp $confdir"jobprofiles"/imprints/$imprintdir/$imprintlogo  $TMPDIR$uuid/cover


echo "uuid seed file is supposed to be" "$TMPDIR$uuid/seeds/seedphrases"

ls -la "$TMPDIR$uuid/seeds/"

cat "$TMPDIR$uuid/seeds/seedphrases" | uniq | sort  > "$TMPDIR$uuid/seeds/sorted.seedfile"


echo "seeds are"
cat "$TMPDIR$uuid/seeds/sorted.seedfile"
echo "---"

# fetch data I will need based on seedfile
echo "summary is" $summary

if [ "$summary" = "true" ] ; then
	"$PYTHON_BIN"  $scriptpath"bin/wikifetcher.py" --infile "$TMPDIR$uuid/seeds/sorted.seedfile" --outfile "$TMPDIR$uuid/wiki/wikiraw.md" --lang "$wikilang" --summary 1> /dev/null
else
	"$PYTHON_BIN"   $scriptpath"bin/wikifetcher.py" --infile "$TMPDIR$uuid/seeds/sorted.seedfile" --outfile "$TMPDIR$uuid/wiki/wikiraw.md" --lang "$wikilang"  1> /dev/null
fi

if [ "$sample_tweets" = "yes" ] ; then
	echo "searching for Tweets"
	echo "# Tweets mentioning seed terms at $todaysdate" >> $TMPDIR$uuid/twitter/sample_tweets.md
		while read -r seed ; do
			echo "seed is $seed"
			echo "## Tweets re $seed" >> $TMPDIR$uuid/twitter/sample_tweets.md
			t search all "$seed" >> $TMPDIR$uuid/twitter/sample_tweets.md
			#sed -i G $TMPDIR$uuid/twitter/sample_tweets.md
			echo "  " >> $TMPDIR$uuid/twitter/sample_tweets.md
			echo "  " >> $TMPDIR$uuid/twitter/sample_tweets.md
		done<"$TMPDIR$uuid"/seeds/sorted.seedfile
else
	echo "no sample tweets" >> $sfb_log
fi


if [ "$flickr" = "on" ] ; then

	mkdir -p -m 755 $TMPDIR$uuid/flickr

	
	echo "about to run flickr fetchers"
	while read -r seed ; do
		"$PYTHON_BIN"  includes/Flickr_title_fetcher.py $TMPDIR$uuid/seeds/sorted.seedfile $TMPDIR$uuid/flickr/
		"$PYTHON_BIN"  includes/Flickr_seed_fetcher.py "$seed" $TMPDIR/$uuid/flickr/
	done<"$TMPDIR$uuid"/seeds/sorted.seedfile
else

	echo "flickr search was off" | tee --append $xform_log

fi

video_search="no"
if [ "$video_search" = "yes" ] ; then
	echo "searching for video"
	mkdir -p $TMPDIR$uuid/video
	#videofetcher.py --flags123
else
	echo "no video search" >> $sfb_log
fi
# clean up fetched data
sed -e s/\=\=\=\=\=/JQJQJQJQJQ/g -e s/\=\=\=\=/JQJQJQJQ/g -e s/\=\=\=/JQJQJQ/g -e s/\=\=/JQJQ/g -e s/Edit\ /\ /g -e s/JQJQJQJQJQ/\#\#\#\#\#/g -e s/JQJQJQJQ/\#\#\#\#/g -e s/JQJQJQ/\#\#\#/g -e s/JQJQ/\#\#/g $TMPDIR$uuid/wiki/wikiraw.md | sed G > $TMPDIR$uuid/wiki/wikiall.md

# build cover

if [ "$wikilang" = "en" ] ; then
	stopfile="$scriptpath""lib/IBMcloud/examples/pk-stopwords.txt"
elif [ "$wikilang" = "sv" ] ; then
	stopfile="$scriptpath""locale/stopwords/sv"
elif [ "$wikilang" = "it" ] ; then
	stopfile="$scriptpath""locale/stopwords/it"
else
	stopfile="$scriptpath""lib/IBMcloud/examples/pk-stopwords.txt"
fi

#rotate stopfile

cp "$stopfile" "$scriptpath""lib/IBMcloud/examples/pk-stopwords.txt"
echo "running stopfile $stopfile"
#more "lib/IBMcloud/examples/pk-stopwords.txt"

	/opt/bitnami/java/bin/java -jar $scriptpath"lib/IBMcloud/ibm-word-cloud.jar" -c $scriptpath"lib/IBMcloud/examples/configuration.txt" -w "1800" -h "1800" < $TMPDIR$uuid/wiki/wikiraw.md > $TMPDIR$uuid/cover/wordcloudcover.png
cat "$TMPDIR$uuid/seeds/seedphrases" | uniq | sort  > "$TMPDIR$uuid/seeds/sorted.seedfile"

# set font & color

if [ "$coverfont" = "Random" ] ; then
	coverfont=`./bin/random-line.sh ../conf/fonts.txt`
	echo "random coverfont is " $coverfont 

else
	coverfont=$coverfont
	echo "using specified cover font" $coverfont 
fi


if [ "$covercolor" = "Random" ]; then
	covercolor=`./bin/random-line.sh ../conf/colors.txt`
	echo "random covercolor is " $covercolor 
else
	covercolor=$covercolor
	echo "using specified covercolor "$covercolor 

fi

echo "covercolor is" $covercolor | tee --append $sfb_log
echo "coverfont is" $coverfont  | tee --append $sfb_log

#create base canvases

convert -size 1800x2400 xc:$covercolor  $TMPDIR$uuid/cover/canvas.png
convert -size 1800x800 xc:$covercolor  $TMPDIR$uuid/cover/topcanvas.png
convert -size 1800x400 xc:$covercolor  $TMPDIR$uuid/cover/bottomcanvas.png
convert -size 1800x800 xc:$covercolor  $TMPDIR$uuid/cover/toplabel.png
convert -size 1800x200 xc:$covercolor  $TMPDIR$uuid/cover/bottomlabel.png

# underlay canvas

composite -gravity Center $TMPDIR$uuid/cover/wordcloudcover.png  $TMPDIR$uuid/cover/canvas.png $TMPDIR$uuid/cover/canvas.png

# build top label


convert -background "$covercolor" -fill "$coverfontcolor" -gravity center -size 1800x400 -font "$coverfont" caption:"$booktitle" $TMPDIR$uuid/cover/topcanvas.png +swap -gravity center -composite $TMPDIR$uuid/cover/toplabel.png

#build bottom label

echo "yourname is" $yourname
if [ "$yourname" = "yes" ] ; then
	editedby="$customername"
else
	echo "robot name on cover"
fi

echo "editedby is" $editedby
convert  -background "$covercolor"  -fill "$coverfontcolor" -gravity south -size 1800x394 \
 -font "$coverfont"  caption:"$editedby" \
 $TMPDIR$uuid/cover/bottomcanvas.png  +swap -gravity center -composite $TMPDIR$uuid/cover/bottomlabel.png

# resize imprint logo

convert $TMPDIR$uuid/cover/pklogo.png -resize x200 $TMPDIR$uuid/cover/pklogo.png


# lay the labels on top of the target canvas

composite -geometry +0+0 $TMPDIR$uuid/cover/toplabel.png $TMPDIR$uuid/cover/canvas.png $TMPDIR$uuid/cover/step1.png
composite  -geometry +0+1800 $TMPDIR$uuid/cover/bottomlabel.png $TMPDIR$uuid/cover/step1.png $TMPDIR$uuid/cover/step2.png
composite  -gravity south -geometry +0+0 $TMPDIR$uuid/cover/$imprintlogo $TMPDIR$uuid/cover/step2.png $TMPDIR$uuid/cover/cover.png
convert $TMPDIR$uuid/cover/cover.png -border 36 -bordercolor white $TMPDIR$uuid/cover/bordercover.png
cp $TMPDIR$uuid/cover/bordercover.png $TMPDIR$uuid/cover/$sku"ebookcover.jpg"
cp $TMPDIR$uuid/cover/bordercover.png $TMPDIR$uuid/ebookcover.jpg

if [ "$shortform" = "no" ]; then

	# building front matter
	echo "about to build title page"

	echo "# "$booktitle  > $TMPDIR$uuid/titlepage.md
	echo ""$byline >> $TMPDIR$uuid/titlepage.md
	echo "by PageKicker Robot" $lastname >> $TMPDIR$uuid/titlepage.md
	echo "  " >> $TMPDIR$uuid/titlepage.md
	echo "  " >> $TMPDIR$uuid/titlepage.md
	echo "  " >> $TMPDIR$uuid/titlepage.md
	echo '![PK logo]'"(pk35pc.jpg)" >> $TMPDIR$uuid/titlepage.md
	echo "  " >> $TMPDIR$uuid/titlepage.md
	echo "  " >> $TMPDIR$uuid/titlepage.md
	echo "# About PageKicker Robot $lastname" >> $TMPDIR$uuid/titlepage.md
	cat "$authorbio" >> $TMPDIR$uuid/titlepage.md
	echo "  " >> $TMPDIR$uuid/titlepage.md
	echo "  " >> $TMPDIR$uuid/titlepage.md
	cp $scriptpath"assets/acknowledgements.md" $TMPDIR$uuid/acknowledgements.md
	cp $scriptpath"assets/rebuild.md" $TMPDIR$uuid/rebuild.md
	cp $confdir"jobprofiles/signatures/"$sigfile $TMPDIR$uuid/$sigfile
	echo "  " >> $TMPDIR$uuid/acknowledgements.md
	echo "  " >> $TMPDIR$uuid/acknowledgements.md
	echo "This book was created with revision "$bazaar_revision "of the PageKicker software running on the "$environment "server." >> $TMPDIR$uuid/acknowledgements.md
	echo "  " >> $TMPDIR$uuid/acknowledgements.md
	echo "  " >> $TMPDIR$uuid/acknowledgements.md
	echo '<i>'$lastname'</i>  ' >> $TMPDIR$uuid/acknowledgements.md
	echo '<i>'"Ann Arbor, Michigan, USA"'</i>' >> $TMPDIR$uuid/acknowledgements.md
	echo "  " >> $TMPDIR$uuid/acknowledgements.md
	echo "  " >> $TMPDIR$uuid/acknowledgements.md
	echo '![Author photo]'"($sigfile)" >> $TMPDIR$uuid/acknowledgements.md

	# assemble front matter

	cat $TMPDIR$uuid/titlepage.md $TMPDIR$uuid/acknowledgements.md $TMPDIR$uuid/rebuild.md > $TMPDIR$uuid/tmpfrontmatter.md

	echo "assembled front matter"

else
	echo "short form selected" 
	echo '![cover image]'"(ebookcover.jpg)" > $TMPDIR$uuid/tmpfrontmatter.md
	echo '![PK logo]'"(pk35pc.jpg)" >> $TMPDIR$uuid/tmpfrontmatter.md

fi

	# assemble back matter
	echo "" >>  $TMPDIR$uuid/backmatter.md
	echo "" >>  $TMPDIR$uuid/backmatter.md


	if [ "$sample_tweets" = "yes" ] ; then
		echo "adding Tweets to back matter"
		cat $TMPDIR$uuid/twitter/sample_tweets.md >> $TMPDIR$uuid/backmatter.md
	else
		echo "no sample tweets"
	fi

	if [ "$flickr" = "on" ] ; then

		cd $TMPDIR$uuid/flickr
		for file in *.md
		do
		       cat $file >> allflickr.md
		       echo '\newpage' >> allflickr.md
		       echo "" >> allflickr.md
		done
		cat allflickr.md >> $TMPDIR$uuid/backmatter.md
		#cp *.jpg ..
		# cp allflickr.md ..
		#cd ..
		# $PANDOC -o images.pdf allflickr.md
		# cd $scriptpath
		# echo "converted flickr md files to pdf pages with images" | tee --append $xform_log
		
	else
		echo "didn't  process flickr files" 
	fi

if [ "$shortform" = "no" ] ;then

	echo "# Sources" >> $TMPDIR$uuid/backmatter.md
 	cat includes/wikilicense.md >> $TMPDIR/$uuid/backmatter.md
	echo "# Also by PageKicker Robot" $lastname >>  $TMPDIR$uuid/backmatter.md
	cat $confdir"jobprofiles/bibliography/"$lastname/$lastname"_titles.txt" >> $TMPDIR$uuid/backmatter.md
	echo "assembled back matter"

else
	echo "no back matter" 

fi

	cat $TMPDIR$uuid/wiki/wikiall.md >> $TMPDIR$uuid/tmpfrontmatter.md
	cat $TMPDIR$uuid/backmatter.md >> $TMPDIR$uuid/tmpfrontmatter.md
	cp $TMPDIR$uuid/tmpfrontmatter.md $TMPDIR$uuid/complete.md

# create epub metadata

my_year=`date +'%Y'`

echo "" > $TMPDIR$uuid/yaml-metadata.md
echo "---" >> $TMPDIR$uuid/yaml-metadata.md
echo "title: $booktitle" >> $TMPDIR$uuid/yaml-metadata.md
echo "creator: " >> $TMPDIR$uuid/yaml-metadata.md
echo "- role: author "  >> $TMPDIR$uuid/yaml-metadata.md
echo "  text: "" $editedby"  >> $TMPDIR$uuid/yaml-metadata.md
echo "publisher: $imprintname"  >> $TMPDIR$uuid/yaml-metadata.md
echo "rights:  (c) $my_year $imprintname" >> $TMPDIR$uuid/yaml-metadata.md
echo "---" >> $TMPDIR$uuid/yaml-metadata.md

cat "$TMPDIR$uuid/yaml-metadata.md" >> $TMPDIR$uuid/complete.md

# build ebook in epub


bibliography_title="$booktitle"
safe_product_name=$(echo "$booktitle" | sed -e 's/[^A-Za-z0-9._-]/_/g')
cd $TMPDIR$uuid
"$PANDOC_BIN" -o "$TMPDIR$uuid/"$safe_product_name".epub" --epub-cover-image=$TMPDIR$uuid/cover/$sku"ebookcover.jpg" $TMPDIR$uuid/complete.md
"$PANDOC_BIN" -o "$TMPDIR$uuid/"$safe_product_name".docx"  $TMPDIR$uuid/complete.md
cd $scriptpath
lib/KindleGen/kindlegen "$TMPDIR$uuid/"$safe_product_name".epub" -o "$safe_product_name"".mobi"
ls -lart $TMPDIR$uuid
echo "built epub and mobi"
case $ebook_format in

epub)
# deliver epub to build target
cp $TMPDIR$uuid/$safe_product_name".epub" "$buildtarget"
chmod 755 "$buildtarget"
echo "checking that buildtarget exists"
ls -la $buildtarget
;;

mobi)

cp $TMPDIR$uuid/$safe_product_name".mobi" "$buildtarget"
chmod 755 "$buildtarget"
echo "checking that buildtarget exists"
ls -la $buildtarget
;;
docx)

cp $TMPDIR$uuid/$safe_product_name".docx" "$buildtarget"
chmod 755 "$buildtarget"
echo "checking that buildtarget exists"
ls -la $buildtarget
;;
*)

esac

# housecleaning
dontcleanupseeds="yes"
cp "$buildtarget" "/tmp/pagekicker/actual_builds/"

if [ "$dontcleanupseeds" = "yes" ]; then
	echo "leaving seed file in place $seedfile"
else
	echo "removing seedfile"
	rm "$seedfile"
	ls -la $seedfile
fi


echo "* ""$bibliography_title" >> $confdir"jobprofiles/bibliography/"$jobprofilename/$jobprofilename"_titles.txt"
cp $confdir"jobprofiles/bibliography/$jobprofilename/"$jobprofilename"_titles.txt" $confdir"jobprofiles/bibliography/"$jobprofilename/$jobprofilename"_titles.tmp"
sort -u $confdir"jobprofiles/bibliography/"$jobprofilename/$jobprofilename"_titles.tmp" > $confdir"jobprofiles/bibliography/"$jobprofilename/$jobprofilename"_titles.txt"
