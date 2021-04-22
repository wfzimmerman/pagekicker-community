#expand seeds to valid wiki pages

echo "starting mediawiki looP"

# page expansion restored here

if [ "$expand_seeds_to_pages" = "y" ]; then
    echo "expand is $expand_seeds_to_pages"
    "$PYTHON_BIN" $scriptpath"bin/mwclient_seeds_to_pages_v2.py" --infile "$TMPDIR$uuid/seeds/sorted.seedfile" --outfile "$TMPDIR$uuid/seeds/filtered.pagehits"
    echo "expanded pages are:"
    cat "$TMPDIR$uuid/seeds/filtered.pagehits"

else
  echo "expand is $expand_seeds_to_pages"
	cp "$TMPDIR$uuid/seeds/sorted.seedfile" "$TMPDIR$uuid/seeds/filtered.pagehits"

fi

# fetch by pagehits
echo "wikipath is $wikipath"

<<<<<<< HEAD
=======
echo "$PYTHON_BIN"

>>>>>>> 02c3d39556dd37836a5933188a7b2798d3eada36
case "$summary" in
summaries_only)
	echo "fetching page summaries only"
	"$PYTHON_BIN"  $scriptpath"bin/mwclient_wikifetcher.py" --infile "$TMPDIR$uuid/seeds/filtered.pagehits" --outfile "wikisummariesraw.md" --lang "$wikilocale" --wikipath "$wikipath" --url_prefix "$url_prefix" --mediawiki_api_url "$mediawiki_api_url" --summary  --outdir "$TMPDIR"$uuid"/wiki"  1> /dev/null

  pandoc -o "$TMPDIR"$uuid/wiki/wikisummaries.md --f mediawiki -t markdown "$TMPDIR"$uuid/wiki/wikisummariesraw.md
	cp  "$TMPDIR"$uuid/wiki/wikisummaries.md  "$TMPDIR"$uuid/wiki/wikiall.md
	wordcountsummaries=$(wc -w "$TMPDIR"$uuid/wiki/wikisummaries.md | cut -f1 -d' ')
	cp "$TMPDIR"$uuid"/wiki/wikisummaries.md" "$TMPDIR"$uuid"/wiki/wiki4cloud.md"
;;
complete_pages_only)
	echo "fetching complete pages only"
	"$PYTHON_BIN" $scriptpath"bin/mwclient_wikifetcher.py" --infile "$TMPDIR"$uuid"/seeds/filtered.pagehits" --outfile "wikipagesraw.md" --lang "$wikilocale"  --wikipath "$wikipath" --url_prefix "$url_prefix" --mediawiki_api_url "$mediawiki_api_url" --outdir "$TMPDIR"$uuid"/wiki" 1> /dev/null

  pandoc -o "$TMPDIR"$uuid"/wiki/wikipages.md" -f mediawiki -t markdown "$TMPDIR"$uuid/wiki/wikipagesraw.md
	wordcountpages=$(wc -w "$TMPDIR"$uuid"/wiki/wikipages.md" | cut -f1 -d' ')
	cp "$TMPDIR"$uuid"/wiki/wikipages.md" "$TMPDIR"$uuid"/wiki/wiki4cloud.md"
	cp  "$TMPDIR"$uuid/wiki/wikipages.md  "$TMPDIR"$uuid/wiki/wikiall.md
;;
both)
	echo "fetching both summaries and complete pages"
	echo "fetching page summaries now"
	"$PYTHON_BIN"  $scriptpath"bin/mwclient_wikifetcher.py" --infile "$TMPDIR"$uuid"/seeds/filtered.pagehits" --outfile "wikisummaries1.mw" --lang "$wikilocale"  --wikipath "$wikipath" --url_prefix "$url_prefix" --mediawiki_api_url "$mediawiki_api_url" --summary --outdir "$TMPDIR"$uuid"/wiki"
	echo "fetching complete pages now"
	"$PYTHON_BIN" $scriptpath"bin/mwclient_wikifetcher.py" --infile "$TMPDIR"$uuid"/seeds/filtered.pagehits" --outfile "wikipages1.mw" --lang "$wikilocale"  --wikipath "$wikipath" --url_prefix "$url_prefix" --mediawiki_api_url "$mediawiki_api_url" --outdir "$TMPDIR"$uuid"/wiki"

  pandoc -o "$TMPDIR"$uuid/wiki/wikisummaries.md -f mediawiki -t markdown "$TMPDIR"$uuid/wiki/wikisummaries1.mw


  pandoc -o "$TMPDIR"$uuid"/wiki/wikipages.md"  -t markdown -f mediawiki "$TMPDIR"$uuid"/wiki/wikipages1.mw"

	wordcountpages=1

  wordcountpages=$(cat "$TMPDIR"$uuid"/wiki/wikipages.md" | tr '\n' ' ' | wc -w | tr -d ' ')
	echo "Wordcount pages is" $wordcountpages
		if [ "$wordcountpages" -gt 100000 ] ; then
			cp  "$TMPDIR"$uuid/wiki/wikisummaries.md  "$TMPDIR"$uuid/wiki/wiki4cloud.md
			cp  "$TMPDIR"$uuid/wiki/wikisummaries.md  "$TMPDIR"$uuid/wiki/wiki4chapters.md
			echo "body too big for wordcloud, using abstracts only"
		else
			 cp "$TMPDIR$uuid/wiki/wikipages.md"  "$TMPDIR$uuid/wiki/wiki4cloud.md"
			 cp  "$TMPDIR"$uuid/wiki/wikipages.md  "$TMPDIR"$uuid/wiki/wiki4chapters.md
			echo "building wordcloud from body"
		fi
;;
*)
	echo "unrecognized summary option"
;;
esac
