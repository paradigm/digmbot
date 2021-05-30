#!/usr/bin/awk -f
#
# prints a (pseudo)random number of "beep"s and/or "boops", along with
# punctuation.  Robot baby-talk of sorts.
/^nick/ {
	nick = $2
}
/^endload/ {
	print "^(;beep$|;boop$|digmbot)"
}
/^user/ {
	user = $2
}
/^room/ {
	room = $2
}
/^message/ {
	$1 = ""
	msg = $0
}
/^endtrigger/ {
	srand(systime())
	out = ""
	if (msg ~ nick) {
		out = user ": "
		max = 5
		puncseed = 2
	} else if (msg ~ "beep") {
		max = 3
		puncseed = 1
	} else if (msg ~ "boop") {
		max = 4
		puncseed = 0
	} else {
		out = "Uhh..."
		max = 0
	}

	count = int(rand()*max)+1
	for (i=0; i<count; i++) {
		if (rand() > 0.5) {
			out = out "beep"
		} else {
			out = out "boop"
		}
		if (i != count - 1) {
			if (rand() > 0.1) {
				out = out " "
			} else {
				out = out ", "
			}
		}
	}
	punc[0] = "."
	punc[1] = "..."
	punc[2] = "."
	punc[3] = "...?"
	punc[4] = "!"
	punc[5] = "...!?"
	punc[6] = "!!"
	punc[7] = "...!!"
	punc[8] = "!!"
	punc[9] = "!!!"
	out = out "" punc[int(rand()*(7+puncseed))]
	print out
}
