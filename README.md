digmbot
=======

digmbot is a relatively simple IRC bot written in gawk which supports plugins.

Dependencies
------------

digmbot is primarily written in awk, but it may extend on the following:

- To list plugins, digmbot runs `system()` with shell globing.  In theory
  someone could have `awk` but not `/bin/sh`.
- SSL/TLS support requires `openssl` with `s_client`.
- SASL requires `base64`.

Running
-------

Simply run the executable with the desired arguments specified like so:

    digmbot -v"key=value" -v"key2=value2" -v"key3=value3" etc

Arguments:

- nick
    - The nick you'd like the bot to have when it connects.
- owner
    - The nick the bot will obey for normal commands listed below.
- server
    - The hostname to connect to.
- port
    - The port number to connect to.
- plugindir
    - The directory in which to look for plugins.
- initfile
    - The path to a file which contains commands to run immediately at the
      start, such as for the bot to authenticate with the server or
      automatically join certain channels.
- disable_ssl
    - By default, digmbot connects via SSL via the `openssl` command.  If
      `disable_ssl` is set to `1`, digmbot will instead connect via plaintext.
- sasl
    - The password needed to authenticate with SASL.  NOTE: setting this as an
      argument will make it public to other users in many operating systems,
      such as in Linux via `/proc`.  Instead, consider editing digmbot's source
      to set it in the `BEGIN` block by the corresponding comment .

Any arguments left unspecified will default to the value in the `setup()`
function.  This should be trivial to change by editing the bot directly.

Normal commands
---------------

When digmbot is running, if it receives a PM from the `owner` with one of the
following commands it will act accordingly:

- say
    - In the room/to the user specified by the second term, the bot will say
      everything from the third term onwards.
    - e.g.: /msg digmbot say #room what to say
- action
    - In the room/to the user specified by the second term, the bot will /me
      everything from the third term onwards.
    - e.g.: /msg digmbot action #room what to do
- join
    - The bot will join the room mentioned in the second term.
    - e.g.: /msg digmbot join #room
- part
    - The bot will part the room mentioned in the second term.
    - e.g.: /msg digmbot part #room
- reload
    - The bot will reload all plugins.  Useful for, for example, adding a new
      plugin.
    - e.g.: /msg digmbot reload
- exit
    - The bot will exit.
    - e.g.: /msg digmbot exit

Plugins
-------

The bot will attempt to treat everything found in the `plugindir` as a plugin.
The files in there should be executable.  Upon loading the plugin, digmbot will
send the following information to the plugin via stdin.  The first term will be
the name of the key, then there will be a space, followed by the value
corresponding to the key and finally a newline.

- nick
- owner
- server
- port
- plugindir
- plugin
- endload

While future versions of digmbot may add additional lines before `endload`,
`endload` should always be the final line sent when loading a plugin. After
seeing `endload`, the plugin should return a regular expression which will
trigger the plugin.

When digmbot detects the regular expression matches something someone said, it
sends the following items to the plugin, again via stdin:

- user
- room
- message
- endtrigger

Like when loading, when `endtrigger` is seen this indicates the end of
digmbot's information for the plugin.  The plugin should respond by printing
with the one line of output which digmbot will print in the same room it saw
the trigger message.  Alternatively, the plugin can volunteer itself to be
skipped and print nothing.

See bundled plugins for examples.  Note that while the bundled examples are in
awk, the plugins could be in any language.

Known issues
------------

- digmbot can only have one owner.
- Plugins can only return one line of output.
- Plugins can only trigger upon a message from a user and not external sources
  such as a timer or webpage being updated.

TODO
----

- Since digmbot now uses `openssl` for networking, `gawk` is no longer strictly
  required.  Remove `GNU`-isms to support more portable `awk` versions.
- Implement `base64` natively to remove `base64` dependency.
