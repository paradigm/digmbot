#!/usr/bin/gawk -f
#
# returns url corresponding to requested vim ":help"

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
	escapedkey = key
	gsub("\\\\","\\\\", escapedkey)
	gsub("\"","\\\"", escapedkey)
	gsub("'","'\"'\"'", escapedkey)
	# remove any previous runs
	system("rm /dev/shm/vimhelpout 2>/dev/null")
	# get the relevant :help page and tag from vim
	system("echo 'e /dev/shm/vimhelpout |" \
		"execute \":help "escapedkey"\" |" \
		"let @f = expand(\"%:t\") |" \
		"execute \":normal l\\\"tyt*\" |" \
		"q |" \
		"execute \"normal i:help "escapedkey" -> http://vimhelp.appspot.com/\\<c-r>f.html#\\<c-r>t\\<esc>\" |" \
		"wqa!' |" \
		"vim -u NONE -e")
	# If the trigger was at the beginning of the message, set the output as an
	# error message in case vim doesn't find anything.  If the trigger was
	# inline, don't say anything.
	if ($1 ~ "^;(h|he|hel|help)$" && $2 == key)
		$0 = ":help "key" -> E149: Sorry, no help for "key
	else
		$0 = ""
	# read what vim kicked out
	getline < "/dev/shm/vimhelpout"
	# output to user
	printf "%s", $0
}
