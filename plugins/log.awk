#!/usr/bin/awk -f
#
# logs channel contents to a file
#
# the resulting files will be in the current working directory with the
# filename corresponding to the channel.

BEGIN {
	# define rooms to be logged here
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
	$1=""
	msg = $0
}
/^endtrigger/ {
	cmd = "date +%Y-%m-%d-%H%M"
	if (room in rooms) {
		cmd | getline time
		close(cmd)
		print time" "user":"msg >> room
	}
}
