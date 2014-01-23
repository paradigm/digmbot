#!/usr/bin/gawk -f
#
# returns url corresponding to requested vim ":help"

/^endload/ {
	# regex to match to trigger this plugin
	print ";(h|he|hel|help) "
}
/^message/ {
	# store the actual message content for when we hit endtrigger
	$1=""
	msg=$0
}
/^endtrigger/ {
	# get key from msg
	$0=msg
	for (i=1; i<NF; i++)
		if ($i ~ "^;(h|he|hel|help)$")
			key = $(i+1)
	# escape the key for the shell
	escapedkey = key
	gsub("\\\\","\\\\", escapedkey)
	gsub("\"","\\\"", escapedkey)
	gsub("'","'\"'\"'", escapedkey)
	# remove any previous runs
	system("rm /dev/shm/vimhelpout 2>/dev/null")
	# get the relevant :help page and tag from vim
	system("echo 'e /dev/shm/vimhelpout | execute \":help "escapedkey"\" | let @f = expand(\"%:t\") | execute \":normal l\\\"tyt*\" | q | execute \"normal ddihttp://vimhelp.appspot.com/\\<c-r>f.html#\\<c-r>t\\<esc>\" | wqa!' | vim -u NONE -e")
	# set a default error message in case vim didn't return anything
	$0 = "E149: Sorry, no help for "key
	# read what vim kicked out
	getline < "/dev/shm/vimhelpout"
	# output to user
	printf ":help %s -> %s", key, $0
}
