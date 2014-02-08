#!/usr/bin/gawk -f
#
# returns url corresponding to requested vim ":help"

BEGIN {
	tmpfile = "/dev/shm/.vimhelpout"
}

function percentencode(str) {
	# have to encode "%" first
	gsub("%", "%25", str)
	# everything else to encode
	p[" "]   = "%20"; p["!"]   = "%21"; p["\""]  = "%22"; p["#"]   = "%23";
	p["\\$"] = "%24"; p["&"]   = "%26"; p["'"]   = "%27"; p["\\("] = "%28";
	p[")"]   = "%29"; p["\\*"] = "%2A"; p["\\+"] = "%2B"; p[","]   = "%2C";
	p["-"]   = "%2D"; p["\\."] = "%2E"; p["\\/"] = "%2F"; p[":"]   = "%3A";
	p[";"]   = "%3B"; p["<"]   = "%3C"; p["="]   = "%3D"; p[">"]   = "%3E";
	p["\\?"] = "%3F"; p["@"]   = "%40"; p["\\["] = "%5B"; p["\\"]  = "%5C";
	p["]"]   = "%5D"; p["\\^"] = "%5E"; p["_"]   = "%5F"; p["`"]   = "%60";
	p["\\{"] = "%7B"; p["\\|"] = "%7C"; p["}"]   = "%7D"; p["~"]   = "%7E";
	for (k in p)
		gsub(k, p[k], str)
	return str
}

function escapeshell(key) {
	gsub("\\\\","\\\\", key)
	gsub("\"","\\\"", key)
	gsub("'","'\"'\"'", key)
	return key
}

function getpage(key) {
	# remove any previous runs
	system("rm "tmpfile" 2>/dev/null")
	# get the relevant :help page and tag from vim
	system("echo 'e "tmpfile" |" \
		"execute \":help "key"\" |" \
		"let @f = expand(\"%:t\") |" \
		"q |" \
		"execute \"normal i\\<c-r>f\\<esc>\" |" \
		"wqa!' |" \
		"vim -u NONE -e")
	getline page < tmpfile
	close(tmpfile)
	return page
}

function gettag(key) {
	# remove any previous runs
	system("rm "tmpfile" 2>/dev/null")
	# get the relevant :help page and tag from vim
	system("echo 'e "tmpfile" |" \
		"execute \":help "key"\" |" \
		"execute \":normal l\\\"tyt*\" |" \
		"q |" \
		"execute \"normal i\\<c-r>t\\<esc>\" |" \
		"wqa!' |" \
		"vim -u NONE -e")
	getline tag < tmpfile
	close(tmpfile)
	return tag
}

/^endload/ {
	# regex to match to trigger this plugin
	print ";(h|he|hel|help)( |$)"
}

/^message/ {
	# store the actual message content for when we hit endtrigger
	$1 = ""
	msg = $0
}

/^endtrigger/ {
	# get key from msg, defaulting to no key (i.e. just ":help")
	$0 = msg
	key = ""
	# Turn an ACTION (/me) into a normal message
	if ($0 ~ "\x01""ACTION .*""\x01") {
		$0 = substr($0, index($0, $2))
		$0 = substr($0, 1, length($0)-1)
	}
	for (i=1; i<NF; i++)
		if ($i ~ "^;(h|he|hel|help)$" && i != NF)
			key = $(i+1)

	# escape the key for the shell
	escapedkey = escapeshell(key)
	# get page and tag from vim
	page = getpage(escapedkey)
	tag = percentencode(gettag(escapedkey))

	# check for no output from vim
	if (page == "") {
		# If the trigger was at the beginning of the message, set the output as an
		# error message in case vim doesn't find anything.  If the trigger was
		# inline, don't say anything, as it could be people discussing ";help".
		if ($1 ~ "^;(h|he|hel|help)$" && $2 == key)
			$0 = ":help "key" -> E149: Sorry, no help for "key
		else
			$0 = ""
	} else {
		# build output string
		$0 = ":help "key" -> http://vimhelp.appspot.com/"page".html#"tag
	}
	# output to user
	print
}
