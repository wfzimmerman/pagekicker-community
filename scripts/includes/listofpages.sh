echo '\pagenumbering{gobble}' > $TMPDIR$uuid/listofpages.md
echo "  " >>  "$TMPDIR"$uuid/listofpages.md
echo "# Chapters" >>  "$TMPDIR"$uuid/listofpages.md
echo "  " >>  "$TMPDIR"$uuid/listofpages.md
cat "$TMPDIR"$uuid/seeds/filtered.pagehits | sed G >>  "$TMPDIR"$uuid/listofpages.md
echo "  " >>  "$TMPDIR"$uuid/listofpages.md
echo "  " >>  "$TMPDIR"$uuid/listofpages.md
