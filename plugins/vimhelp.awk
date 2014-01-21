#!/usr/bin/gawk -f
#
# returns url corresponding to requested vim ":help"

/^endload/ {
	print "^(::|;)(h|he|hel|help) "
}
/^message/ {
	$1=""
	msg=$0
}
/^endtrigger/ {
	# $1 is the ;help, $2 is the requested item
	$0=msg
	key = $2
	# escape the key for the shell
	escapedkey = $2
	gsub("\"","\\\"", escapedkey)
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
