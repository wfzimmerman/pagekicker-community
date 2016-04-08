#!/bin/bash

# extracts, analyzes, and summarizes images from permissioned PDF documents

# requires pdfimages, imagemagick, fdupes

# confpath is hard-coded to /opt/bitnami ...

# input: PDF file
# output: unique jpgs, zip, montage

starttime=$(( `date +%s` ))

# parse the command-line very stupidly

echo "-M-M-M-M-M-M-M-M-M-M-M-M-M-M" | tee --append $xform_log
echo "starting montageur"| tee --append $xform_log




while :
do
case $1 in
--help | -\?)
echo "requires PDF filename; example: montageur.sh filename"
exit 0  # This is not an error, the user requested help, so do not exit status 1.
;;
--pdfinfile)
pdfinfile=$2
shift 2
;;
--pdfinfile=*)
pdfinfile=${1#*=}
shift
;;
--stopimagefolder)
stopimagefolder=$2
shift 2
;;
--stopimagefolder=*)
stopimagefolder=${1#*=}
shift
;;
--maximages)
maximages=$2
shift 2
;;
--maximages=*)
maximages=${1#*=}
shift
;;
--outfile)
outfile=$2
shift 2
;;
--outfile=*)
outfile=${1#*=}
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
--montageurdir)
montageurdir=$2
shift 2
;;
--montageurdir=*)
montageurdir=${1#*=}
shift
;;
--passuuid)
passuuid=$2
shift 2
;;
--passuuid=*)
passuuid=${1#*=}
shift
;;
--tmpdir)
tmpdir=$2
shift 2
;;
--tmpdir=*)
tmpdir=${1#*=}
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

if [ ! "$pdfinfile" ]; then
  echo "ERROR: option '--pdfinfile[pdfinfile]' not given. See --help" >&2
   exit 1
fi

if [ ! "$passuuid" ] ; then
	echo "creating uuid"
	uuid=$(python  -c 'import uuid; print uuid.uuid1()')
	echo "uuid is" $uuid | tee --append $xform_log
	mkdir -m 755 $TMPDIR$uuid
	mkdir -m 755 $TMPDIR$uuid/montageur
else
	uuid=$passuuid
	echo "received uuid " $uuid
fi


if [ "$environment" = "Production" ] ; then

	confpath="/opt/bitnami/apache2/htdocs/pk-production/production/"
        . $confpath"conf/config.txt"
        echo "running prod config" | tee --append $xform_log


if [ "$environment" = "Staging" ] ; then

	confpath="/opt/bitnami/apache2/htdocs/pk-staging/development/"
        . $confpath"conf/config.txt"
        echo "running prod config" | tee --append $xform_log

else
	confpath="/opt/bitnami/apache2/htdocs/pk-new/development/"
        . "$confpath"conf/config.txt
        echo "running dev config"  | tee --append $xform_log

fi

. $scriptpath"includes/set-variables"

# get bzr revision
bazaar_revision=`bzr revno`
echo "bazaar revision number in" "$environment" "is" $bazaar_revision

cd $scriptpath
echo "scriptpath is" $scriptpath

export PATH=$PATH:/opt/bitnami/java/bin

echo "PATH is" $PATH
# default values

stopimagefolder="none" #default
maximages="3" #default
thumbxsize=120 #default
thumbysize=120 #default
outfile="montage.jpg"
montageurdir="montageur"


pdfimages -j "$pdfinfile" $TMPDIR$uuid/"$montageurdir"/extracted_images

if [ ls *.pbm &> /dev/null ] ; then
	echo "pbm files exist so converting to ppm" | tee --append $xform_log
	for f in $TMPDIR$uuid/"$montageurdir"/extracted_images*.pbm; do
	  convert ./"$f" ./"${f%.pbm}.ppm"
	done
else 
	echo "no pbm files" | tee --append $xform_log
fi

if test -n "$(shopt -s nullglob; echo $TMPDIR$uuid/"$montageurdir"/extracted_images*.ppm)"
then
    echo "image files were found in the target pdf" | tee --append $xform_log
else
    echo "montageur exiting, no image files were found in the target pdf" | tee --append $xform_log
    exit 1
fi


 # convert ppms to jpegs

echo "about to mogrify ppms into jpgs"

mogrify -format jpg $TMPDIR$uuid/"$montageurdir"/extracted_images*.ppm
echo "removing ppm files"
# rm $TMPDIR$uuid/"$montageurdir"/extracted_images*.ppm
if [ ls *.pbm &> /dev/null ] ; then
	echo "removing pbm files"
	# rm $TMPDIR$uuid/"$montageurdir"/extracted_images*.pbm
else 
	echo "no pbm files" | tee --append $xform_log
fi


# remove small images

for i in $TMPDIR$uuid/"$montageurdir"/extracted_images*.jpg
do
	bytes=`identify -format "%b" $i | cut -dB -f1`
	echo $bytes
	if [ "$bytes" -lt 1000 ] ; then
		rm $i
		echo "removed small image" $i
	else
		true
	fi
done

# count images and create metadata

# if maximages is provided then create a separate montage at the end using just those images

imagecount=$(ls $TMPDIR$uuid/"$montageurdir"/*.jpg | wc -l)
echo "imagecount is" $imagecount
ls -S $TMPDIR$uuid/"$montageurdir"/*.jpg > $TMPDIR$uuid/"$montageurdir"/listbysize.txt


# delete dupes
fdupes -dN $TMPDIR$uuid/.

# kluge move stop images into working directory

if [ "$stopimagefolder" != "none" ] ; then

	echo "stopimagefolder was" $stopimagefolder | tee --append $xform_log
	cp $stopimagefolder/* .
	fdupes -r . > $TMPDIR$uuid/"$montageurdir"/dupelist.txt
	sed -i '/^$/d' $TMPDIR$uuid/"$montageurdir"/dupelist.txt
	while read -r filename; do
	 rm "$filename"
	done <$TMPDIR$uuid/"$montageurdir"/dupelist.txt

else

	echo "no stopimage folder" | tee --append $xform_log

fi

zip $TMPDIR$uuid/"$montageurdir"/extracted_images.zip $TMPDIR$uuid/"$montageurdir"/extracted_images*.jpg 

pdftk "$pdfinfile" dump_data output | grep -E "Figure*|Table*|Map*|Illustration*" | sed 's/BookmarkTitle//' > $TMPDIR$uuid/"$montageurdir"/figures_metadata.txt

# build montage image

montage -density 300 -units pixelsperinch $TMPDIR$uuid/"$montageurdir"/extracted_images*.jpg -geometry '800x800>+4+3' $TMPDIR$uuid/"$montageurdir"/$outfile
cp $TMPDIR$uuid/"$montageurdir"/$outfile $TMPDIR$uuid/$outfile

montage -density 300 -units pixelsperinch $TMPDIR$uuid/"$montageurdir"/extracted_images*.jpg -tile 3x4 -geometry '800x800>+3+4' $TMPDIR$uuid/"$montageurdir"/portrait_%d.jpg 
cp -R $TMPDIR$uuid/"$montageurdir"/portrait* tmp/$uuid

# build optional top N images montage

if [ "$maximages" != "no" ] ; then

	echo "building additional image from top N"
	mkdir -m 755 $TMPDIR$uuid/montageurtopn

	# put N files in tmp directory
	cd $TMPDIR$uuid/"$montageurdir"
	cp `find ./extr*.jpg -maxdepth 1 -printf '%s %p\n'|sort -nr|head -n "$maximages" | cut -d/ -f2` ../montageurtopn
	cd $scriptpath
	# build the montage

	montage -density 300 -units pixelsperinch $TMPDIR$uuid/montageurtopn/extracted_images*.jpg -geometry '2150x900>+4+3' -tile 1x"$maximages" $TMPDIR$uuid/montageurtopn/montagetopn.jpg

else 
	echo "not building top N images montage" | tee --append $xform_log

fi

echo "montageur complete"  | tee --append $xform_log
