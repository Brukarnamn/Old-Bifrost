# Bifrost-bot

  <https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md>

  Written by Noko @ English-Norwegian Language Exchange server.
  Invite link: <https://discord.gg/8ptUM3d>

## Bifrost / Bivrost / Bifröst / Bilröst

Bifrost, also called Åsbroen (Ásbrú) is the name of the rainbow in
Norse mythology. The gods built the rainbow bridge as a pathway from the
earth (Midgard) and into the sky (Asgard), the realm of the gods.

The god Heimdall sits at the edge of Asgard and guards Bifrost from the
mountain jotnar.

The bridge will collapse when the sons of Muspell ride it during Ragnarok.

## Some features

* Change roles with !Role SHORT_ROLE_NAME command or simply !SHORT_ROLE_NAME.
  The check for !SHORT_ROLE_NAME is done after any other normal commands.
  SHORT_ROLE_NAME maps into FULL_ROLE_NAME based on the configuration file.

* Lots of silly one-liner responses based on !SillyStuff SHORT_COMMAND
  or simply !SHORT_COMMAND.
  The check for !SHORT_COMMAND is done after any other normal commands,
  and after any !SHORT_ROLE_NAME commands.
  This can also be regexp based triggers, that will match *any* text any
  user writes.

* Output a custom message when a user join or leaves.

* Output the audit log to a "primary" server channel for the Ban, Kick,
  Username, Nickname, Avatar, MessageDelete events.
  Output the audit log to a "secondary" server channel for the MessageDelete
  event with more detailed information.

## To-do list

* Blacklist of user-ids that will flag the moderators if any of these
  user-id should join.

* Auto-ban of users with username and/or nick spelled as an url.

* Handle the server role events so the bot does not need to be restarted
  if you change any of your role names.
  Your configuration file might still need to be changed though.

## Known issues

* The server's role names need to be uniquely spelled for the mapping from
  role command into role names to work properly.
    Test_123456789012345678 → Test Role Name
    Test_234567890123456789 → Test Role Name

## Installation

The following Ruby gems are required in order to run the bot:

* `discordrb` (and its dependencies).
  * <https://github.com/meew0/discordrb>
  * <http://www.rubydoc.info/github/meew0/discordrb/toplevel>
* `sqlite3` (and its dependencies) for some persistent storage.
  * <https://sqlite.org/download.html>
* `nokogiri` (and its dependencies) to parse web pages.
  * <http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Node>
* `imgkit` and its dependencies to convert from html to image.
  * <https://github.com/csquared/IMGKit>
  * <https://wkhtmltopdf.org/downloads.html>

### 1

Update all installed gems.

  `gem update --platform=ruby`
  `gem dependency openssl`

If and only if you have two versions of openssl:
For example if you get LoadError (... Ruby25-x64/lib/ruby/gems/2.5.0/gems/openssl-2.1.2/lib/openssl.so)

  `gem uninstall openssl` or `gem uninstall openssl -v 2.1.2`

Make sure you have the `bundler` gem installed.
In Windows, open `Command Prompt with Ruby` and type

  `gem install bundle --platform=ruby`

### 2

Download, extract and install `sqlite3` from

  <https://sqlite.org/download.html>

If necessary, modify the PATH-variable or copy the executables into Ruby's executable bin-folder.
Then install the Ruby `sqlite3` gem:

  `gem install sqlite3 --platform=ruby -- --with-sqlite3-dir=c:/path/to/sqlite3/executable --with-sqlite3-include=c:/path/to/sqlite3/c-and-h-sources --with-sqlite3-libc:/path/to/sqlite3/dll-or-o-libraries`

for example:

  `gem install sqlite3 --platform=ruby -- --with-sqlite3-dir=p:/ruby/discordbot/sqlite3 --with-sqlite3-include=p:/ruby/discordbot/sqlite3/sources --with-sqlite3-lib=p:/ruby/discordbot/sqlite3`

Database browser for SQLite:

  <http://sqlitebrowser.org/>

#### With Ruby 2.5 on Windows

Get autoconf version of sqlite3 sources from <https://www.sqlite.org/download.html>
Start msys shell of DevKit:

  `C:\bin\Ruby25-x64\msys64\mingw64.exe`

Cd to unpacked location for your sqlite3

  `cd /p/Ruby/Discordbot/sqlite3/sqlite-autoconf-3250200/`

In unpacked location for your sqlite3 configure static version only to avoid keeping DLL on PATH

  `./configure --disable-shared`

Build and install it

  `make`
  `make install DESTDIR=/c/bin/Ruby25-x64/msys64` OR `make install`

Remove all existing sqlite3 gems

  `gem uninstall sqlite3 --all`

Build and install this gem

  `gem install sqlite3 --platform=ruby -- --with-sqlite3-include=c:/bin/Ruby25-x64/msys64/include --with-sqlite3-lib=c:/bin/Ruby25-x64/msys64/lib`

### 3

Then run `bundle install`

  gem install bundler rake ast ffi unf_ext unf domain_name http-cookie mime-types-data mime-types netrc rest-client --platform=ruby
  gem install discordrb-webhooks opus-ruby rbnacl event_emitter websocket websocket-client-simple discordrb --platform=ruby
  gem install imgkit json mini_portile2 parallel parser powerpack rainbow ruby-progressbar unicode-display_width rubocop --platform=ruby
  gem install thor yard eventmachine reverse_markdown kramdown htmlentities coderay jaro_winkler tilt solargraph --platform=ruby
  gem install awesome_print --platform=ruby
  gem install nokogiri hpricot --platform=ruby

### Ruby 2.5 WARNING

There is a broken dependency in the latest gem (3.2.1) and for Windows Ruby 2.5 users, you'll find the library silently errors out.
This is fixed in the master version, so to fix this, you can either

* use up to date master (We recommend using bundler. See ?ahh bundler for more information)
* install the gem dependency with `gem install rest-client --pre --platform=ruby`
* Use Ruby 2.4 or under.

### 4

Copy the configuration file in the `data` folder:

  `copy server_secrets_example.yml server_secrets.yml`

then edit the new file and fill in your secret keys.

### 5

Edit

  `server_configs.yml`

in the `data` folder and fill in your server's IDs and channel IDs.

### 6

Log in on your existing Discord account (or register a normal Discord account and log in) then go to

  <https://discordapp.com/developers/applications/me>

to get the Discord token (The bot's password).

### 7

Press `+` for a new app.

### 8

Find the permissions the bot should have

  <https://discordapi.com/permissions.html#335612928>
  <https://discordapp.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags>

  READ_MESSAGES         0x00000400  Allows reading messages in a channel. The channel will not appear for users without this permission
  VIEW CHANNELS         0x00000400  Allows
  SEND_MESSAGES         0x00000800  Allows for sending messages in a channel

  EMBED LINKS           0x........  Allows
  READ_MESSAGE_HISTORY  0x00010000  Allows for reading of message history
  ADD REACTIONS         0x........

  VIEW AUDIT LOG        0x........  
  CHANGE_NICKNAME       0x04000000  Allows for modification of own nickname

	= 67194048

  MANAGE_ROLES          0x10000000  Allows management and editing of roles
  BAN MEMBERS           0x........  Allows removing members

	= 335629508

and then a server owner/admin have to invite the bot:

  <https://discordapp.com/oauth2/authorize?client_id=YOUR_CLIENT_ID&scope=bot&permissions=0>

  <https://discordapp.com/oauth2/authorize?client_id=&scope=bot&permissions=335612928> - livebot
  <https://discordapp.com/oauth2/authorize?client_id=&scope=bot&permissions=335612928> - testbot
