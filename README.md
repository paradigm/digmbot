digmbot
=======

digmbot is a relatively simple IRC bot written in gawk with a limited support
for plugins.

Running
-------

Simply run the executable with the desired arguments specified like so:
like so:

    digmbot -v"key=value" -v"key2=value2" -v"key3=value3" etc

Arguments:

- nick
    - The nick you'd like the bot to have when it connects.
- owner
    - The nick the bot will blindly obey
- server
    - The hostname to connect to.
- port
    - The port number to connect to.
- plugindir
    - The directory in which to look for plugins.

Any arguments left unspecified will default to the value in the `setup()`
function.  This should be trivial to change by editing the bot directly.

Normal commands
---------------

When digmbot is running, if it receives a PM from the `owner` with one of the
following commands it will act accordingly:

- say
    - In the room/to the user specified by the second term, the bot will say
      everything from the third term onwards.
- action
    - In the room/to the user specified by the second term, the bot will /me
      everything from the third term onwards.
- join
    - The bot will join the room mentioned in the second term.
- part
    - The bot will part the room mentioned in the second term.
- exit
    - The bot will exit.

Plugins
-------

The bot will attempt to treat everything found in the `plugindir` as a plugin.
The files in there should be executable.  If the files in there are given the
argument "returnregex", they should print out the regular expression that they
want to trigger them.  For example, if a plugin is supposed to return the time
upon the bot seeing ".time" as the (entire) message, when the plugin sees
"returnregex" it should print "^[.]time$".  The regex is limited to whatever gawk
understands.  Whenever digmbot sees that regex (baring normal commands, which
take precidence), it will pass along the entire line to the relevant plugin as
an argument.  Whatever the plugin returns will be printed.

Note the plugin specifics will likely change in the future to support things
such as having the plugin know things such as which user said a given thing.

Known issues
------------

- digmbot relies on the command `ls` to find the plugins.  In theory someone
could have gawk but not ls, in which case this could be problematic.

- The plugin interface is pretty limited at the moment.

- Only has one owner.
