#!/usr/bin/gawk -f
#
# returns url corresponding to requested vim "::help"

BEGIN {
	tagfile = "/tmp/vimhelptags"
	tagurl = "https://vim.googlecode.com/hg/runtime/doc/tags"
	if (system("[ -r "tagfile" ]") != 0) {
		system("wget \""tagurl"\" -O "tagfile ">/dev/null 2>&1")
	}
}
function geturl(key) {
	# look for an exact match
	while ((getline < tagfile) > 0) {
		if (index($0, key"\t") == 1) {
			sub(".txt", "", $2)
			return "http://vimdoc.sourceforge.net/htmldoc/"$2".html#"key
		}
	}
	close(tagfile)
	# look for case insensitive match
	while ((getline < tagfile) > 0) {
		if (index(tolower($0), tolower(key)"\t") == 1) {
			sub(".txt", "", $2)
			sub("^/\\*", "", $3)
			sub("\\*$", "", $3)
			return "http://vimdoc.sourceforge.net/htmldoc/"$2".html#"$3
		}
	}
	close(tagfile)
	# look for a substring match
	while ((getline < tagfile) > 0) {
		if (index($0, key) > 0 && index($0, key"\t") < index($0, "\t")) {
			sub(".txt", "", $2)
			sub("^/\\*", "", $3)
			sub("\\*$", "", $3)
			return "http://vimdoc.sourceforge.net/htmldoc/"$2".html#"$3
		}
	}
	return "No matches against "tagurl" as of whenever this bot downloaded it"
}
/^endload/ {
	print "^(::|;)(h|he|hel|help) "
}
/^message/ {
	$1=""
	msg=$0
}
/^endtrigger/ {
	$0=msg
	key = $2
	url = geturl(key)
	printf ":help %s -> %s", key, url
}
