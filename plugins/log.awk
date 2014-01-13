#!/usr/bin/awk -f
#
# logs channel contents to a file
#
# the resulting files will be in the pwd with the filename corresponding to the
# channel.

BEGIN {
	# define rooms to be logged here
	# for example, below will log pms to the bot:
	rooms["digmbot"] = "digmbot"
}
/^endload/ {
	# matches everything
	print "^"
}
/^user/ {
	user = $2
}
/^room/ {
	room = $2
}
/^message/ {
	msg = $2
}
/^endtrigger/ {
	# log to file
	if (room in rooms) {
		"date +%Y-%m-%d-%H%M" | getline time
		close("date +%Y-%m-%d-%H%M")
		print time" "user": "msg >> room
	}
}
