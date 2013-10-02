#!/usr/bin/gawk -f
#
# digmbot
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
#
# Copyright (c) 2013 Daniel Thau <paradigm@bedrocklinux.org>

BEGIN {
	setup()
	loadplugins()
	net = "/inet/tcp/0/" server "/" port

	print  "Connecting to " server "/" port "..."
	printf "NICK " nick "\r\n"               |& net
	printf "USER " nick " x x :" nick "\r\n" |& net

	while (net |& getline) {
		parse()
	}
}

function setup() {
	if (nick == "")
		nick = "digmbot"
	if (owner == "")
		owner = "paradigm"
	if (server == "")
		server = "chat.freenode.net"
	if (port == "")
		port = 6667
	if (plugindir == "")
		plugindir = "./plugins"
}

function loadplugins() {
	print "Loading plugins..."
	while (("ls "plugindir | getline plugin) > 0) {
		plugindir"/"plugin " returnregex" | getline plugins[plugin]
		print "Plugin "plugin" is looking for regex /" plugins[plugin] "/"
	}
	close("ls "plugindir)
	print "done"
}

function parse() {
	if ($1 == "PING")
		printf "PONG "$2 |& net
	else
		print

	u = substr($0,2,index(substr($0,2),"!")-1) # user
	r = $3                                     # room
	$0 = substr($0,index(substr($0,2),":")+2)  # message

	if (u == owner && r == nick) {
		if ($1 == "say") {
			printf "PRIVMSG " $2 " :" cf(2) "\r\n" |& net
			return
		}
		if ($1 == "action") {
			printf "PRIVMSG " $2 " :%sACTION " cf(2) "\r\n", "\x01" |& net
			return
		}
		if ($1 == "join") {
			printf "JOIN " $2 "\r\n" |& net
			return
		}
		if ($1 == "part") {
			printf "PART " $2 "\r\n" |& net
			return
		}
		if ($1 == "quit")
			exit
	}
	for (plugin in plugins) {
		if ($0 ~ plugins[plugin]) {
			print "TRIGGERED PLUGIN "plugin
			plugindir"/"plugin" "$0 | getline output
			close(plugindir"/"plugin" "$0)
			printf "PRIVMSG " r " :" output "\r\n" |& net
			return
		}
	}
}

# skips first n many fields, then returns the rest
function cf(n) {
	# couldn't get {n} in regex to work for some reason, here's an ugly hack.
	msg = $0
	regex = "^[[:blank:]]*"
	skipfield = "([^[:blank:]]+[[:blank:]]+)"
	for(i=0;i<n;i++)
		regex = regex "" skipfield
	sub(regex,"",msg)
	return msg
}
