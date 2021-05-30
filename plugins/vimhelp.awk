#!/usr/bin/gawk -f
#
# returns url corresponding to requested vim ":help"

BEGIN {
	vim_cmd = "vim"
	website = "vimhelp"
	#website = "vimdoc"
	debug = 0
	regex = "(^| )(;|:)he?l?p?"
	surroundchars["'"] = "'"
	surroundchars["\""] = "\""
	surroundchars["“"] = "”" # fancy unicode quotes
	surroundchars["\\("] = "\\)"
	surroundchars["{"] = "}"
	surroundchars["\\["] = "\\]"

	tmpfile = "/dev/shm/.vimhelpout"
}

/^owner/ {
	owner = $0
}

/^message/ {
	$1 = ""
	msg = $0
}

/^endload/ {
	# regex to match to trigger this plugin
	print regex" ."
}

function get_key() {
	do {
		$1="";$0=$0
	} while ($1 !~ regex && NF > 1)
	for (k in surroundchars) {
		if ($1 ~ k""regex) {
			sub(surroundchars[k]".*$", "", $2)
		}
	}
	return ""$2
}

function strip_action() {
	if ($0 ~ "\x01""ACTION .*""\x01") {
		$0 = substr($0, index($0, $2))
		$0 = substr($0, 1, length($0)-1)
	}
}

function percent_encode(str) {
	# have to encode "%" first
	gsub("%", "%25", str)
	# everything else to encode
	p[" "]   = "%20"; p["!"]   = "%21"; p["\""]  = "%22"; p["#"]   = "%23";
	p["\\$"] = "%24"; p["&"]   = "%26"; p["'"]   = "%27"; p["\\("] = "%28";
	p[")"]   = "%29"; p["\\*"] = "%2A"; p["\\+"] = "%2B"; p[","]   = "%2C";
	p["\\."] = "%2E"; p["\\/"] = "%2F"; p[":"]   = "%3A";
	p[";"]   = "%3B"; p["<"]   = "%3C"; p["="]   = "%3D"; p[">"]   = "%3E";
	p["\\?"] = "%3F"; p["@"]   = "%40"; p["\\["] = "%5B"; p["\\\\"]  = "%5C";
	p["]"]   = "%5D"; p["\\^"] = "%5E";  p["`"]   = "%60";
	p["\\{"] = "%7B"; p["\\|"] = "%7C"; p["}"]   = "%7D"; p["~"]   = "%7E";
	# p["_"]   = "%5F";
	# p["-"]   = "%2D";
	for (k in p)
		gsub(k, p[k], str)
	return str
}

function escape_shell(key) {
	# if changing, test against `:help /\c`
	gsub("\\\\","\\\\\\\\\\\\", key)
	gsub("\"","\\\"", key)
	gsub("'","'\"'\"'", key)
	return key
}

function get_page(key) {
	# remove any previous runs
	system("rm "tmpfile" 2>/dev/null")
	# get the relevant :help page and tag from vim
	getline page < tmpfile
	system("echo 'e "tmpfile" |" \
		"execute \":help "key"\" |" \
		"let @f = expand(\"%:t\") |" \
		"q |" \
		"execute \"normal i\\<c-r>f\\<esc>\" |" \
		"wqa!' |" \
		vim_cmd " -Z -u NONE -e")
	getline page < tmpfile
	close(tmpfile)

	if (website == "vimdoc") {
		# remove .txt
		sub("....$", "", page)
	}
	return page
}

function get_tag(key) {
	# remove any previous runs
	system("rm "tmpfile" 2>/dev/null")
	# get the relevant :help page and tag from vim
	system("echo 'e "tmpfile" |" \
		"execute \"help "key"\" |" \
		"execute \"normal lyt*\" |" \
		"q |" \
		"put! |" \
		"wqa!' |" \
		"/bedrock/bin/strat -r arch /usr/bin/vim -Z -u NONE -e")
	getline tag < tmpfile
	close(tmpfile)
	system("rm "tmpfile" 2>/dev/null")

	if (website == "vimhelp") {
		tag = percent_encode(tag)
	}
	return tag
}

/^endtrigger/ {
	strip_action()
	$0 = "ignore-me " msg
	output = ""
	if ($(NF-1) == ">") {
		redirect = 1
		target_nick = $NF
	}

	while (key = get_key()) {
		debug_store_key = key
		escapedkey = escape_shell(key)
		page = get_page(escapedkey)
		tag = get_tag(escapedkey)

		if (page == "") {
			continue
			#url = "E149: Sorry, no help for "key
		} else {
			if (website == "vimhelp") {
				url = "http://vimhelp.appspot.com/"page".html#"tag
			} else if (website == "vimdoc") {
				url = " http://vimdoc.sourceforge.net/htmldoc/"page".html#"tag
			}
		}

		if (output == "") {
			output = ":help "key" -> "url
		} else {
			output = output" | :help "key" -> "url
		}
	}

	if (!redirect) {
		print output
	} else if (debug && target_nick == owner) {
		printf "debug: <%s> <%s> <%s> <%s> <%s>\n", output, debug_store_key, escapedkey, page, tag
	} else {
		print target_nick ": " output
	}
}
