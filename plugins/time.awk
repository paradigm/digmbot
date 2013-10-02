#!/usr/bin/awk -f
#
# reports the time when a user enters ";time"
/^endload/ {
	print "^;time$"
}
/^user/ {
	user = $2
}
/^endtrigger/ {
	print user": The current time is "strftime("%c")
}
