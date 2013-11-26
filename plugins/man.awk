#!/usr/bin/gawk -f
#
# returns url to vim documentation
BEGIN {
	pagecache = "/tmp/manpagecache"
	if (system("[ -d "pagecache" ]") != 0) {
		system("mkdir /tmp/manpagecache")
	}
}
/^endload/ {
	print "^;man "
}
/^message/ {
	$1=""
	msg=$0
}
/^endtrigger/ {
	$0 = msg
	$1 = ""

	# provided specific item
	if (length($2) == 1) {
		printf "man%s -> http://linux.die.net/man/%d/%s\n", $0, $2, $3
		exit
	}

	msg = $0
	term = $2
	letter = substr($2,1,1)
	page = pagecache"/"letter

	# have to lookup which man page it is in

	# if we don't have offline copy of index page for letter, get it
	if (system("[ -r "page" ]") != 0) {
		system("wget -O"page" http://linux.die.net/man/"letter".html 2>/dev/null")
	}

	while ((getline < page) > 0) {
		if ($0 ~ "^<dt><a href=\"[^\"]+\">"term"</a>") {
			split($0, a, "\"")
			printf "man%s -> http://linux.die.net/man/%s\n", msg, a[2]
			exit
		}
	}

	# couldn't find it
	printf "man%s -> could not find match on linux.die.net\n", msg
}
