# Bifrost / Askeladden v2
#class BifrostBot
=begin
  Requires the discordrb module and its dependencies.
    https://github.com/meew0/discordrb
  Requires json module to read in personal server keys.

  In Windows, open "Command Prompt with Ruby".

    gem install json --platform=ruby
    gem install discordrb --platform=ruby       # http://www.rubydoc.info/github/meew0/discordrb/toplevel
    gem install nokogiri --platform=ruby        # http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Node
                                                # https://wkhtmltopdf.org/downloads.html
    gem install imgkit --platform=ruby          # https://github.com/csquared/IMGKit

  Log in on your existing account (or register a normal account and log in) then go to
    https://discordapp.com/developers/applications/me
  to get the Discord token (The bot's password). 
  Press + for a new app.

  Find the permissions the bot should have and
    https://discordapi.com/permissions.html#335612928
    https://discordapp.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags

    READ_MESSAGES         0x00000400	Allows reading messages in a channel. The channel will not appear for users without this permission
    SEND_MESSAGES         0x00000800	Allows for sending messages in a channel
    READ_MESSAGE_HISTORY  0x00010000	Allows for reading of message history
    CHANGE_NICKNAME       0x04000000	Allows for modification of own nickname
    MANAGE_ROLES *        0x10000000	Allows management and editing of roles

  then a server owner/admin have to invite the bot:
    https://discordapp.com/oauth2/authorize?client_id=YOUR_CLIENT_ID&scope=bot&permissions=0
    https://discordapp.com/oauth2/authorize?client_id=361253623881269258&scope=bot&permissions=335612928 - livebot
    https://discordapp.com/oauth2/authorize?client_id=361603350975741952&scope=bot&permissions=335612928 - testbot

  Run the program with
    ruby -I. bifrost-bot.rb
    ruby -TI. -w bifrost-bot.rb
  or for more interactive purposes
    irb -I. -r bifrost-bot.rb

  Invite link to the Testserver
    https://discord.gg/qTG4GQH
  Invite link to the English-Norwegian server
    https://discordapp.com/invite/scTV7aV

    <Server name=English-Norwegian Language Exchange id=202189706383982605 large=true region=us-east owner=#<Discordrb::User:0x0000000002f163f8> afk_channel_id=0 afk_timeout=300>
      serverid: 202189706383982605
    <Channel name=conversation id=202189706383982605 topic="English preferred in this channel, thanks. :)" type=0 position=4 server=#<Discordrb::Server:0x0000000003351698>>
      channelid: 202189706383982605

  https://leovoel.github.io/embed-visualizer/
=end
# Json must be loaded first, or strange things happens.
begin
  require 'json'          or raise 'json'
  require 'discordrb'     or raise 'discordrb'
  require 'debug'         or raise 'debug'
  require 'open-uri'      or raise 'open-uri'
  require 'nokogiri'      or raise 'nokogiri'
  require 'imgkit'        or raise 'imgkit'
rescue LoadError => e
  # What to do if it fails.
  # Have to explicitly define which error we want to rescue from.
  # The file is most probably missing.
  raise
rescue Exception => e
  # Some other error.
  raise
ensure
  # This will always be done.
end

@DEBUG = true.freeze
@DEBUG_SPAMMY = false.freeze

@TEST = true.freeze;
@BOT_RUNS_ON_SERVER_ID = (@TEST ? '348172070947127306'.freeze :   #MinEgenTestserver
                                  '202189706383982605'.freeze)    #ENLE-server

# The folder where the bot should store the images fetched from the web.
@WORD_INFLECTION_IMAGE_PATH = (@TEST ? 'd:/bifrost-discordbot'.freeze :
                                       'c:/bifrost-discordbot'.freeze)

# The location of the html-to-image executable. Needed if the bot is running on Windows.
@WKHTMLTOIMAGE_EXE_PATH = 'C:/bin/wkhtmltopdf/bin/wkhtmltoimage.exe'.freeze

# The character that all the bot commands must start with.
@BOT_INVOKE_CHARACTER = '!'.freeze

# Accept only space
# dot .
# unicode letters    \p{L}
# unicode diacritics \p{M}  and
# unicode digits     \p{N}
@ILLEGAL_DICTIONARY_SEARCH_CHARACTERS = /[^ \.\p{L}\p{M}]/.freeze

#
# The settings read from the configuration files.
# And other global variables.
#
@BOT_SETTINGS_HASH = {}
@THIS_SERVER_SETTINGS_HASH = {}
@ALL_SERVER_SETTINGS_HASH = {}

# The Discord Bot object
@BOT_OBJ = nil

# Hash containing user ids and when they last issued a bot command. To prevent them spamming commands.
@USER_BOT_INVOKES = {}

# Maximum commands per time frame. Need to be greater than 2, or some if tests fail. ;-)
@USER_MAX_BOT_INVOKES_PER_TIME_LIMIT = 5.freeze

# Maximum commands during this time frame.
@BOT_INVOKES_TIME_FRAME_LIMIT = 60.freeze

# Hash container the dictionary responses. To prevent asking about the same stuff multiple times.
@ORDBOK_DICTIONARY_WORD_RESPONSES_LOOKUP_TABLE = {}

# The CSS used for the generation of html-to-image.
@ORDBOK_DICTIONARY_CSS = nil;

# Hash containing the user command name for adding/removing a role, and its corresponding Discord server's role name.
# Will be changed to all uppercase letters.
@USER_ROLE_COMMANDS = {}

# Array containing a list of the server roles the user can only have one of at the same time. Setting one of them should remove the others.
# Will be changed to all uppercase letters.
@USER_EXCLUSIVE_ROLES = []

# The channel id of the default channel the bot should send messages to. Like join and leave messages and other future stuff.
@SERVER_DEFAULT_CHANNEL_ID = nil

# The channel id of the channel the bot should send all its role modification messages to.
# @SERVER_DEFAULT_CHANNEL_ID will be used if this one is not set.
@SERVER_ROLE_SPAM_CHANNEL_ID = nil

# List of commands for the help text.
# Might or might not actually correspond to the commands the bot itself responds to.
@BOT_COMMANDS_LIST = <<'MULTI_LINE_HELP_TEXT'
Currently supported commands are:
`!help`         This text.
`!beginner`     Set/remove the beginner-role for you. If you have just started learning Norwegian.
`!intermediate` Set/remove the intermediate-role for you. If you know all the basics of Norwegian, but still lack vocabulary and the occasional grammar.
`!advanced`     Ask a moderator. This role is if you are near-fluent in Norwegian.
`!native`       Set/remove the native-role. If Norwegian is your native language.
`!nsfw`         Set/remove the NSFW-role. If you are interested in off-topic meme-postings.
`!comp`         Set/remove the Computer-Wannabe-role. If you are above average interested in computer stuff.
MULTI_LINE_HELP_TEXT



# Read in the settings in the two configuration files.
# Fill in the global variables (for easier use and less error handling and modifications later.)
#
# @return [true] Returns true if everything went as planned.
def load_settings
  Debug.trace if @DEBUG
  returnval = true

  bot_settings_filename = './bot_settings' + (@TEST ? '_dev' : '') + '.json'
  file_contents = File.read(bot_settings_filename)
  @BOT_SETTINGS_HASH = JSON.parse(file_contents)

  file_contents = File.read('./server_settings.json')
  @ALL_SERVER_SETTINGS_HASH = JSON.parse(file_contents)

  @ORDBOK_DICTIONARY_CSS = File.read('./ordbok_uib_no.css')

  # Only get the settings for the server the bot should respond on.
  # Don't want our testing to interfere on the live servers.
  @THIS_SERVER_SETTINGS_HASH = @ALL_SERVER_SETTINGS_HASH[@BOT_RUNS_ON_SERVER_ID]

  # Some sanity checking, maybe.
  #   if @DEBUG
  #   if @DEBUG && false
  # Change if it really should be shown after all.
  if @DEBUG && false
    #Debug.divider if @DEBUG

    @BOT_SETTINGS_HASH.each do |key,value|
      puts "#{key} => #{value}"
    end

    @THIS_SERVER_SETTINGS_HASH.each do |key,value|
      puts "#{key} => #{value}"
    end
  end

  # Loop over all the server ids and the data in them.
  #
  #@ALL_SERVER_SETTINGS_HASH.each do |server_id,server_data|
  [1].each do
    #Debug.divider if @DEBUG
    #puts "#{server_id} => #{server_data}"

    # User commands and the corresponding user role.
    if !@THIS_SERVER_SETTINGS_HASH['roles'].nil?
      @THIS_SERVER_SETTINGS_HASH['roles'].each do |key,value|
        #puts "#{key} => #{value}"
        @USER_ROLE_COMMANDS[key.upcase] = value.upcase
      end
    else
      returnval = false
    end

    # User roles the user can only have one of at the same time.
    if !@THIS_SERVER_SETTINGS_HASH['exclusive_roles'].nil?
      #puts @THIS_SERVER_SETTINGS_HASH['exclusive_roles'].inspect
      @THIS_SERVER_SETTINGS_HASH['exclusive_roles'].each do |key|
        @USER_EXCLUSIVE_ROLES.push key.upcase
      end
    else
      returnval = false
    end

    # Default chat channel for the bot.
    if @THIS_SERVER_SETTINGS_HASH['default_channel_id'].nil?
      puts 'WARNING: Bot is missing a default channel to send messages to.'
      returnval = false
    else
      @SERVER_DEFAULT_CHANNEL_ID = @THIS_SERVER_SETTINGS_HASH['default_channel_id']
    end

    # Channel for role modification responses.
    if @THIS_SERVER_SETTINGS_HASH['role_spam_channel_id'].nil?
      @SERVER_ROLE_SPAM_CHANNEL_ID = @SERVER_DEFAULT_CHANNEL_ID
    else
      @SERVER_ROLE_SPAM_CHANNEL_ID = @THIS_SERVER_SETTINGS_HASH['role_spam_channel_id']
    end
  end

  if @DEBUG
    Debug.divider if @DEBUG
    puts @USER_ROLE_COMMANDS.inspect
    puts @USER_EXCLUSIVE_ROLES.inspect
    puts @SERVER_DEFAULT_CHANNEL_ID
    puts @SERVER_ROLE_SPAM_CHANNEL_ID
  end

  return returnval
end



=begin
  <Message
    content="!ping"
    id=361285849020891140
    timestamp=2017-09-23 23:00:58 +0000
    author=#<Discordrb::User:0x00000000046cd1e0>
    channel=#<Discordrb::Channel:0x00000000046c73f8>
  >
  <Channel
    name=generelt
    id=348172071412563971
    topic="Nothing to see here."
    type=0
    position=0
    server=#<Discordrb::Server:0x00000000046ec360>
  >
  <Member
    user=<User
      username=Noko
      id=210866460950659072
      discriminator=1335>
    server=<Server
      name=MinEgenTestserver
      id=348172070947127306
      large=false
      region=eu-central
      owner=#<Discordrb::User:0x00000000046cd1e0>
      afk_channel_id=0
      afk_timeout=300>
    joined_at=2017-08-18 18:31:30 +0000
    roles=[<Role name=Eier permissions=#<Discordrb::Permissions:0x00000000046e7770 @writer=<RoleWriter role=#<Discordrb::Role:0x00000000046e77e8> token=...>, @bits=2146958591, @create_instant_invite=true, @kick_members=true, @ban_members=true, @administrator=true, @manage_channels=true, @manage_server=true, @add_reactions=true, @read_messages=true, @send_messages=true, @send_tts_messages=true, @manage_messages=true, @embed_links=true, @attach_files=true, @read_message_history=true, @mention_everyone=true, @use_external_emoji=true, @connect=true, @speak=true, @mute_members=true, @deafen_members=true, @move_members=true, @use_voice_activity=true, @change_nickname=true, @manage_nicknames=true, @manage_roles=true, @manage_webhooks=true, @manage_emojis=true> hoist=true colour=#<Discordrb::ColourRGB:0x00000000046e6a50 @combined=10181046, @red=155, @green=89, @blue=182> server=<Server name=MinEgenTestserver id=348172070947127306 large=false region=eu-central owner=#<Discordrb::User:0x00000000046cd1e0> afk_channel_id=0 afk_timeout=300>>]
    voice_channel=nil
    mute=
    deaf=
    self_mute=
    self_deaf=
  >
=end
# Fetch some common information about the user from the event object.
# @param [EventObject]
# @return [Hash<UserData>]
def get_user_from_event event_obj
  Debug.trace if @DEBUG

  user_obj = nil;
  user_roles = {}
  returnval = {
    username: '<Someone>',
    discriminator: -1,
    id: -1,
    mention: '',
    roles: user_roles,
    obj: nil,
  }

  case event_obj
  when Discordrb::Events::MessageEvent
    user_obj = event_obj.author
  when Discordrb::Events::ServerMemberAddEvent,       # Someone joins
       Discordrb::Events::ServerMemberUpdateEvent,    # Roles gets added/deleted
       Discordrb::Events::ServerMemberDeleteEvent     # Someone leaves
       user_obj = event_obj.user
  else
    puts 'Unknown event type! ' + event_obj.class.to_s
  end
  #puts user_obj.inspect

  if !user_obj.nil?
    returnval[:nick] = user_obj.username.to_s
    returnval[:discriminator] = user_obj.discriminator.to_s
    returnval[:username] = user_obj.username.to_s + '#' + user_obj.discriminator.to_s
    returnval[:id] = user_obj.id.to_s
    returnval[:mention] = user_obj.mention.to_s

    # Loop over the current roles this user has, and add them in an upper case text
    if user_obj.respond_to?('roles') && !user_obj.roles.nil?
      user_obj.roles.each do |role_obj|
        user_roles[role_obj.name.upcase] = true
      end
      returnval[:roles] = user_roles
    end

    #returnval[:obj] = user_obj
  end

  puts returnval.inspect if @DEBUG
  return returnval
end



# Fetch some common information about the channel from the event object.
# @param [EventObject]
# @return [Hash<ChannelData>]
def get_channel_from_event event_obj
  Debug.trace if @DEBUG

  channel_obj = event_obj.channel
  returnval = {
    channelname: '<Somewhere>',
    id: -1,
    obj: nil,
  }
  #puts channel_obj.inspect

  if !channel_obj.nil?
    returnval[:channelname] = channel_obj.name.to_s
    returnval[:id] = channel_obj.id.to_s
    #returnval[:obj] = channel_obj
  end

  puts returnval.inspect if @DEBUG
  return returnval
end



# Fetch some common information about the server from the event object.
# @param [EventObject]
# @return [Hash<ServerData>]
def get_server_from_event event_obj
  Debug.trace if @DEBUG
  
  server_obj = event_obj.server
  returnval = {
    servername: '<SomeServer>',
    id: -1,
    default_channel_id: -1,
    role_spam_channel_id: -1,
    obj: nil,
  }
  #puts server_obj.inspect

  if !server_obj.nil?
    server_id_data = @ALL_SERVER_SETTINGS_HASH[server_obj.id.to_s]
    #puts @ALL_SERVER_SETTINGS_HASH.inspect
    #puts server_obj.id.to_s
    #puts server_id_data.inspect

    returnval[:servername] = server_obj.name.to_s
    returnval[:id] = server_obj.id.to_s
    returnval[:default_channel_id] = server_id_data['default_channel_id']
    returnval[:role_spam_channel_id] = server_id_data['role_spam_channel_id'] || server_id_data['default_channel_id']
    #returnval[:obj] = server_obj
  end

  puts returnval.inspect if @DEBUG
  return returnval
end



# Extracts the text message from the event object and checks if it could have been a bot command.
# If it might be a bot command, then remove the first character and upcase the rest of the string.
# @param [EventObject]
# @return [Hash<TextMessageData>]
def get_message_from_event event_obj
  Debug.trace if @DEBUG

  text_message_obj = event_obj.message
  text_message_content = event_obj.message.content
  returnval = {
    text: 'HELP',
    args: [],
    typed_channel_id: -1,
    orig_text: text_message_content,
  }
  puts text_message_obj.inspect

  if !text_message_content.nil? && (text_message_content.length > 0) && text_message_content[0] == @BOT_INVOKE_CHARACTER
    # Remove the first character and turn it all into upper case letters.
    text_string = text_message_content[1..-1] || ''
    text_array = text_string.split(/\s+/)
    #puts text_string.inspect
    #puts text_array.inspect

    returnval[:text] = text_array[0].upcase || 'HELP'
    returnval[:args] = text_array[1..-1]    || ''
    returnval[:typed_channel_id] = text_message_obj.channel.id.to_s
  end

  puts returnval.inspect if @DEBUG
  return returnval
end



# Extracts all the server roles available on the server from the event object.
# @param [EventObject]
# @return [Hash<RoleData>]
def get_server_roles_from_event event_obj
  Debug.trace if @DEBUG

  server_roles = event_obj.server.roles
  returnval = {}

  if !server_roles.nil?
    # Loop over all of them and uppercase the role name.
    server_roles.each do |rolename_obj|
      returnval[rolename_obj.name.to_s.upcase] = {
        name: rolename_obj.name.to_s,
        obj: rolename_obj,
      }
    end
  end

  if @DEBUG
    returnval.each do |key,value|
      #puts "#{key} => #{value}"
      puts "#{key} => "+
        "{ :name => #{value[:name]},"+
        " :obj => #{value[:obj].class.to_s}"+
        " }"
    end
  end
  return returnval
end



# Check if the role should be added or removed from the user.
# @param [UserHash]
# @param [PermissionRole<String>]
# @return [true,false]
def add_role_to_user? user_hash, permission_role
  Debug.trace if @DEBUG

  # If the user does not have the permission role, then add it - return true
  # Otherwise, remove it - return false
  returnval = (user_hash[:roles][permission_role].nil? ? true : false)

  return returnval
end



# Add a role to a user.
# @param [EventObject]
# @param [PermissionRoleHash]
# @return [true]
def add_role_to_user event_obj, single_permission_role_hash, is_temp = false, timeout = 60
  Debug.trace if @DEBUG
  returnval = true

  user_hash = get_user_from_event event_obj
  server_hash = get_server_from_event event_obj

  event_obj.server.member(user_hash[:id]).add_role(single_permission_role_hash[:obj])
  message = 'Added the ' + single_permission_role_hash[:name] + ' role to you, ' + user_hash[:mention]

  if is_temp
    # Timeout is in seconds.
    @BOT_OBJ.send_temporary_message(server_hash[:role_spam_channel_id], message, timeout)
  else
    @BOT_OBJ.send_message(server_hash[:role_spam_channel_id], message)
  end

  return returnval
end



# Remove a role from a user.
# @param [EventObject]
# @param [PermissionRoleHash]
# @return [true]
def remove_role_from_user event_obj, single_permission_role_hash, is_temp = false, timeout = 60
  Debug.trace if @DEBUG
  returnval = true

  user_hash = get_user_from_event event_obj
  server_hash = get_server_from_event event_obj

  event_obj.server.member(user_hash[:id]).remove_role(single_permission_role_hash[:obj])
  message = 'Removed the ' + single_permission_role_hash[:name] + ' role from you, ' + user_hash[:mention]

  if is_temp
    # Timeout is in seconds.
    @BOT_OBJ.send_temporary_message(server_hash[:role_spam_channel_id], message, timeout)
  else
    @BOT_OBJ.send_message(server_hash[:role_spam_channel_id], message)
  end

  return returnval
end



# Send a message if the role change isn't possible for whatever reason.
# @param [EventObject]
# @return [true]
def role_change_not_possible event_obj
  Debug.trace if @DEBUG

  user_hash = get_user_from_event event_obj
  server_hash = get_server_from_event event_obj

  @BOT_OBJ.send_message(server_hash[:role_spam_channel_id],
    user_hash[:mention] + ', what are you trying to do?' +"\n"+
    'This role does not exist for some reason. You might want to contact a moderator. :thinking:')

  return true
end



# Add or remove a role permission from a user.
# Check if in doing so, the user should have other role permissions removed.
# @param [EventObject]
# @param [PermissionRoleObject]
# @param [true,false]
# @return [true,false]
def change_role_permission_on_user event_obj, permission_role, remove_conflicting_roles = false
  Debug.trace if @DEBUG
  returnval = false

  user_hash = get_user_from_event event_obj
  server_hash = get_server_from_event event_obj
  server_roles_hash = get_server_roles_from_event event_obj
  puts permission_role.inspect if @DEBUG
  #puts server_roles_hash[permission_role].inspect if @DEBUG

  # Check if the permission role exist on the server.
  if server_roles_hash[permission_role].nil?
    # The roles doesn't exist.
    # A bug somewhere? Spelling error in the configuration file?
    role_change_not_possible event_obj
    returnval = false
  else
    # The role exists on the server.
    # Figure out if it should be added or removed from the user.
    if add_role_to_user? user_hash, permission_role
      # Add the role to the user.
      user_hash[:roles][permission_role] = true
      returnval = add_role_to_user event_obj, server_roles_hash[permission_role]

      # If it is one of the roles that you can only have one of, then go through them all
      # and make sure the user only has one of them.
      if remove_conflicting_roles
        @USER_EXCLUSIVE_ROLES.each do |role_name|
          next if role_name == permission_role
          #puts role_name if @DEBUG
          if user_hash[:roles][role_name].nil? || user_hash[:roles][role_name] == false
            next
          else
            user_hash[:roles][role_name] = false
            remove_role_from_user event_obj, server_roles_hash[role_name], true
          end
        end
      end
    else
      # Remove the role from the user.
      user_hash[:roles][permission_role] = false
      returnval = remove_role_from_user event_obj, server_roles_hash[permission_role]
    end
  end

  return returnval
end



# Lookup a word in ordbok.uib.no and parse and fetch the inflection pattern for a word.
# @param [SearchString<String>]
# @param [true,false] - true if bokmål, false if nynorsk
# @return [WordHash]
def ordbok_uib_no_dictionary_lookup search_string, is_bokmål = true
  Debug.trace if @DEBUG
  returnval = nil
  word_hash = { length: 0 }
  @max_results = 10.freeze

  ordbok_base_uri = 'http://ordbok.uib.no/perl/ordbok.cgi?'
  #ordbok_base_uri = 'https://www.google.no/?'

  # Removing strange characters.
  if search_string.match(@ILLEGAL_DICTIONARY_SEARCH_CHARACTERS)
    puts "#{__LINE__}"+'BAD BOY/GIRL! Illegal characters: ' + search_string
    search_string = search_string.gsub(@ILLEGAL_DICTIONARY_SEARCH_CHARACTERS, '')
    puts 'Changed it into>> ' + search_string + ' <<'
  end
  if search_string.length < 1
    return returnval
  end

  #&nynorsk=+&ordbok=bokmaal&
  #&bokmaal=+&ordbok=nynorsk&
  word_hash[:url] = dictionary_url = URI::encode(ordbok_base_uri + [
    #'OPP=^' + search_string + '$',
    'OPP=' + search_string + '',
    'ant_bokmaal=' + @max_results.to_s,
    'ant_nynorsk=' + @max_results.to_s,
    (is_bokmål ? 'bokmaal' : 'nynorsk') + '=+',
    'ordbok=' + (is_bokmål ? 'bokmaal' : 'nynorsk'),
    #'ava=ava',
    'type=bare_oppslag',
    #'soeketype=r',  # RegExp search
    'soeketype=v',   # Normal search
  ].join('&'))

  word_hash[:url_simple] = dictionary_url_simple = URI::encode(ordbok_base_uri + [
    'OPP=' + search_string + '',
  ].join('&'))

  ordbok_word_html_page_name = @WORD_INFLECTION_IMAGE_PATH + '/' +
    'ordbok_' + search_string.to_s + '_'+ (is_bokmål ? 'nb' : 'nn') + '.html'

  puts dictionary_url.inspect if @DEBUG
  
  begin
    if File.file?(ordbok_word_html_page_name)
      puts('Found cached dictionary word page: ' + ordbok_word_html_page_name) if @DEBUG
      dictionary_page_contents = File.read(ordbok_word_html_page_name)
    else
      dictionary_page_contents_fh = open(dictionary_url, 'User-Agent' => 'Discord-bot for the English-Norwegian language exchange.')
      dictionary_page_contents = dictionary_page_contents_fh.read
      #dictionary_page_contents = File.read('N:/Ruby/Discordbot/test/ordbok_blåbærsyltetøy_nb.html')
      #dictionary_page_contents = File.read('N:/Ruby/Discordbot/test/ordbok_jogurt_nb.html')
      #dictionary_page_contents = File.read('N:/Ruby/Discordbot/test/ordbok_plan_nb.html')
      #dictionary_page_contents = File.read('N:/Ruby/Discordbot/test/ordbok_tro_nb.html')
      #dictionary_page_contents = File.read('N:/Ruby/Discordbot/test/ordbok_være_nb.html')
      #dictionary_page_contents = File.read('N:/Ruby/Discordbot/test/ordbok_vere_nn.html')

      puts('Saving dictionary word html page... ' +  ordbok_word_html_page_name) if @DEBUG
      File.write(ordbok_word_html_page_name, dictionary_page_contents)
    end
    dictionary_page_html = Nokogiri::HTML(dictionary_page_contents) do |config|
      config.nonet.recover
    end
    
  rescue Exception => e
    # Some error.
    #<Errno::ENOENT: No such file or directory @ rb_sysopen - N:/Ruby/Dis...bot.rb>
    #<URI::InvalidURIError: URI must be ascii only "https://...shg\u00F8wle...type=r">
    puts e.inspect
    return returnval
  ensure
    # This will always be done.
  end
  #puts dictionary_page_contents.inspect if @DEBUG

  dictionary_page_html_table_id = 'byttut' + (is_bokmål ? 'BM' : 'NN')
  
  i = 1
  search_result = dictionary_page_html.css('table#'+dictionary_page_html_table_id+' tr/td.oppslagtd/div.oppslagdiv')
  #puts search_result.inspect
  search_result.each do |keywords|
    #puts keywords.inspect
    keywords_text_hash = parse_dictionary_body_from_nokogiri_nodes keywords
    word_hash[i] = {
      timestamp: Time.now,
      keyword: keywords_text_hash[:value].strip.gsub(/\|$/, ''),
      art_id: '',
      word_ids: {},
      roman_numerals: {},
      word_spellings: {},
      word_classes: {},
      word_synonyms: '',
      word_definitions_header: '',
      word_definitions_array: [],
      word_etymology: '',
    }
    word_hash[:length] += 1
    i += 1
  end

  i = 1
  search_result = dictionary_page_html.css('table#'+dictionary_page_html_table_id+' tr/td/div.artikkel')
  #puts search_result.inspect
  search_result.each do |articletops|
    word_hash[i].merge!( art_id: articletops.attributes['id'].value )
    i += 1
  end

  i = 1
  search_result = dictionary_page_html.css('table#'+dictionary_page_html_table_id+' tr/td/div.artikkel/div.artikkelinnhold')
  search_result.each do |word_article_content|
    #Debug.divider
    # Remove double text elements in the source that are used if you have different compact display preference.
    word_article_content.css('span.tydingC.kompakt').remove
    word_article_content.css('span.doemeliste.kompakt').remove
    word_article_content.css('div.doemeliste.utvidet').remove

    # Remove the link to the element for inflection window.
    word_article_content.css('span.oppsgramordklassevindu').remove

    # Remove more double text elements for the compact display preference.
    word_article_content.css('span.utvidet/span.tydingC.kompakt').remove
    word_article_content.css('span.utvidet/span.doeme.kompakt').remove

    # Remove own word article texts inside the current word.
    word_article_content.css('span.utvidet/div.artikkelinnhold').remove
    word_article_content.css('span.utvidet/div.tyding.utvidet/div.tyding.utvidet').remove
    word_article_content.css('span.utvidet/div.tyding.utvidet/div.artikkelinnhold').remove

    #puts word_article_content.to_html if @DEBUG

    # Messy html (and code).
    # The tag isn't always there, so need to be sure we don't fetch information from the wrong element.
    roman_numeral_hash = {}
    current_word_id = 0
    
    word_roman_numeral_counter = word_article_content.css('span/style')
    if word_roman_numeral_counter.length > 0
      word_roman_numeral_counter.each do |single_roman_numeral_counter|
        single_roman_numeral_counter_parent = single_roman_numeral_counter.parent
        #puts single_roman_numeral_counter.inspect
        oppslagsord_node = single_roman_numeral_counter_parent.next_element
        #puts oppslagsord_node.inspect
        if !oppslagsord_node['class'].nil? && oppslagsord_node['class'] =~ /oppslagsord/ && !oppslagsord_node['id'].nil?
          current_word_id = oppslagsord_node.attributes['id'].value

          if word_hash[i][:word_ids]
            word_hash[i][:word_ids][current_word_id] = true
          else
            word_hash[i][:word_ids] = { current_word_id => true }
          end

          # Remove the <style> element that is in front of the numbers.
          single_roman_numeral_counter.remove

          if roman_numeral_hash[current_word_id]
            roman_numeral_hash[current_word_id].push( single_roman_numeral_counter_parent.text )
          else
            roman_numeral_hash[current_word_id] = [ single_roman_numeral_counter_parent.text ]
          end

          single_roman_numeral_counter_parent['class'] = 'roman'
        else
          puts "#{__LINE__}: BRAINFART! Or some changes have been done on the source web page..."
        end
      end
    end
    word_hash[i].merge!( roman_numerals: roman_numeral_hash )

    multiple_keywords = {}
    word_keywords = word_article_content.css('span.oppslagsord')
    word_keywords.each do |single_keyword|
      current_word_id = single_keyword.attributes['id'].value
      #word_inflection_image = dictionary_inflection_lookup current_word_id, is_bokmål

      if word_hash[i][:word_ids]
        word_hash[i][:word_ids][current_word_id] = true
      else
        word_hash[i][:word_ids] = { current_word_id => true }
      end

      if multiple_keywords[current_word_id]
        multiple_keywords[current_word_id].push(
          single_keyword.text
        )
      else
        multiple_keywords[current_word_id] = [ single_keyword.text ]
      end
    end
    word_hash[i].merge!( word_spellings: multiple_keywords )
    #puts multiple_keywords.inspect
    
    multiple_wordclasses = {}
    word_wordclasses = word_article_content.css('span.oppsgramordklasse')
    word_wordclasses.each do |single_wordclass|
      word_id_ref_string = single_wordclass.attributes['onclick'].to_s
      word_id_regexp_res = /vise_fullformer\("(\d+)".*\)/.match(word_id_ref_string)
      if word_id_regexp_res
        current_word_id = word_id_regexp_res[1]

        word_inflection_image = ordbok_uib_no_dictionary_inflection_lookup current_word_id, is_bokmål
        
        if multiple_wordclasses[current_word_id]
          multiple_wordclasses[current_word_id][:classes].push(
            single_wordclass.text
          )
        else
          multiple_wordclasses[current_word_id] = {
            inflection_image: word_inflection_image,
            classes: [ single_wordclass.text ],
          }
        end
      else
        puts "#{__LINE__}: BRAINFART!"
      end
    end
    word_hash[i].merge!( word_classes: multiple_wordclasses )
    #puts multiple_wordclasses.inspect

    dictionary_body = word_article_content.css('span.utvidet').first
    word_definitions_hash = parse_dictionary_body_from_nokogiri_nodes dictionary_body

    word_hash[i].merge!( word_definitions_header: word_definitions_hash[:header].strip )

    if !word_definitions_hash[:defs].nil? && word_definitions_hash[:defs].length > 0
      word_hash[i].merge!( word_definitions_array: word_definitions_hash[:defs] )
    else
      word_hash[i].merge!( word_synonyms: word_definitions_hash[:value].strip )
    end

    # Now that the definitions are fetched, remove these nodes to easier parse and fetch other stuff.
    word_article_content.css('span.roman').remove
    word_article_content.css('span.oppslagsord').remove
    word_article_content.css('span.oppsgramordklasse').remove
    word_article_content.css('span.utvidet').first.remove

    #puts word_article_content.to_html

    word_etymology_hash = parse_dictionary_body_from_nokogiri_nodes word_article_content
    if word_etymology_hash[:value].strip.length > 0
      word_etymology_hash[:value] = word_etymology_hash[:value].gsub(/^([,;.\s]|el)+/, '').gsub(/[,:\s]+$/, '')
      word_hash[i].merge!( word_etymology: word_etymology_hash[:value].gsub(/\s+/, ' ').strip )
    else
      word_hash[i].merge!( word_etymology: '' )
    end

    sleep 0.5  # Wait half a second so we don't spam the ordbok.uib.no site too much.
    i += 1
  end

  if @DEBUG && false
    word_hash.each do |index,word_data|
      if word_data.is_a?(Integer) ||
        word_data.is_a?(String) ||
        word_data.is_a?(Time)
       puts "----- #{index}: #{word_data}"
      elsif word_data.is_a?(Hash)
        puts "----- #{index} -----"
        word_data.each do |key,value|
          puts "#{key}: #{value}"
        end
      else
        puts word_data.class
      end
    end
  end

  returnval = word_hash
  return returnval
end



def parse_dictionary_body_from_nokogiri_nodes nokogiri_node_obj
  #Debug.trace if @DEBUG && @DEBUG_SPAMMY
  returnval = {
    type: nil,
    prefix: '',
    postfix: '',
    value: nil,
    header: '',
    defs: [],
  }
  #puts nokogiri_node_obj.inspect if @DEBUG && @DEBUG_SPAMMY
  
  if nokogiri_node_obj.is_a?(Nokogiri::XML::Element) && !nokogiri_node_obj.name.nil?
    #puts 'ELE-----'+nokogiri_node_obj.to_html if @DEBUG && @DEBUG_SPAMMY

    case nokogiri_node_obj.name
    when 'span', 'div', 'a'
      returnval.merge!( type: 'text' )

      node_attributes = nokogiri_node_obj.attributes
      if !node_attributes.nil?
        node_attribute_class = node_attributes['class']
        node_attribute_style = node_attributes['style']
      end

      if !node_attribute_style.nil?
        case node_attribute_style.value
        when /font-style:.*italic/
          returnval.merge!( type: 'css', prefix: '*', postfix: '*' )
        when /font-weight:.*(bold|900)/
          returnval.merge!( type: 'css', prefix: '**', postfix: '**' )
        when /font-weight:.*normal/
          returnval.merge!( type: 'css' )
        when /font-family/
          returnval.merge!( type: 'css' )
        when /margin/
          returnval.merge!( type: 'css' )
        else
          puts '!!__ELE-ATTRI-STYLEVAL: '+node_attribute_style.to_s
        end
      end

      if !node_attribute_class.nil?
        case node_attribute_class.value
        when /tyding/
          returnval.merge!( type: 'definition' )
        when /henvisning/, /etymtilvising/
          returnval.merge!( type: 'text', prefix: '*', postfix: '*' )
        when /utvidet/, /tilvising/
          returnval.merge!( type: 'text' )
        when /artikkelinnhold/, /oppslagdiv/, /tiptip/
          returnval.merge!( type: 'text' )
        else
          puts '!!__ELE-ATTRI-CLASSVAL: '+node_attribute_class.to_s
        end
      end

    when 'br'
      # Adding | so the word lookups can be divided easier.
      returnval.merge!( type: 'text', postfix: '|' )
      
    else
      puts '!!__ELE-TYPE: '+nokogiri_node_obj.name.to_s
      
    end

    merged_text = ''
    nokogiri_node_obj.children.each do |single_node_obj|
      child_node = parse_dictionary_body_from_nokogiri_nodes single_node_obj

      if child_node.nil?
        raise 'Unexpected return value from parse_dictionary_body_from_nokogiri_nodes(...)'
      else
        case child_node[:type]
        when 'text', 'css'
          merged_text += child_node[:prefix] + child_node[:value] + child_node[:postfix]
        when 'definition'
          #puts '_______________________________________________________________' if @DEBUG && @DEBUG_SPAMMY
          #puts merged_text if @DEBUG && @DEBUG_SPAMMY
          #puts child_node.inspect if @DEBUG && @DEBUG_SPAMMY

          if merged_text.strip.length > 1 && returnval[:defs].length < 1
            returnval.merge!( header: merged_text.gsub(/\s+/, ' ').strip )
          end
          merged_text = child_node[:prefix] + child_node[:value] + child_node[:postfix]
          #puts merged_text if @DEBUG && @DEBUG_SPAMMY

          returnval.merge!( defs: returnval[:defs].push(merged_text.gsub(/\s+/, ' ').strip) )
        else
          puts '!!__ELE-RECU'
          puts child_node.inspect
          puts returnval.merge!( type: 'text' )
        end
      end
    end
    #puts '___MERGE___: '+merged_text if @DEBUG && @DEBUG_SPAMMY
    returnval.merge!( value: merged_text )

  elsif nokogiri_node_obj.is_a?(Nokogiri::XML::Text)
    #puts 'TXT----->>>>'+nokogiri_node_obj.to_html+'<<<<' if @DEBUG && @DEBUG_SPAMMY

    returnval.merge!(
      type: 'text',
      value: nokogiri_node_obj.text
    )

  else
    puts nokogiri_node_obj.inspect
    puts 'UNON-----'+nokogiri_node_obj.class.to_s

  end

  if returnval[:type].nil?
    puts '!!__UNON-----NIL!!'
    puts nokogiri_node_obj.inspect
    puts returnval.inspect
  end

  return returnval
end



# Fetch the inflection pattern of the word.
# First check if we already have it, if not,
# fetch it from the ordbok.uib.no site. Then make a picture of it.
# @param [word_id<Interger>]
# @param [true,false] - True if bokmål, false if nynorsk.
# @param [DefaultImageWidth<Integer>] - For nouns around (stringlength x 10 x 5)
# @return [nil] | [image_path<String>]
def ordbok_uib_no_dictionary_inflection_lookup word_id, is_bokmål = true, default_image_width = 1024
  Debug.trace if @DEBUG
  returnval = nil

  dictionary_inflection_url = URI::encode('http://ordbok.uib.no/perl/' +
    (is_bokmål ? 'bob' : 'nob') + '_hente_paradigme.cgi?' +
    'lid=' + word_id.to_s)

  inflection_image_name = @WORD_INFLECTION_IMAGE_PATH + '/' +
    (is_bokmål ? 'nb' : 'nn') + '_bøyningsmønster_' + word_id.to_s + '.jpg'

  inflection_html_page_name = @WORD_INFLECTION_IMAGE_PATH + '/' +
    (is_bokmål ? 'nb' : 'nn') + '_bøyningsmønster_' + word_id.to_s + '.html'

  puts "LOOKUP: #{inflection_image_name} | #{dictionary_inflection_url}" if @DEBUG

  if File.file?(inflection_image_name)
    puts('Found cached image: ' + inflection_image_name) if @DEBUG
    return inflection_image_name
  else
    puts('Fetching inflection pattern from the web... ' + dictionary_inflection_url) if @DEBUG
  end

  begin
    if File.file?(inflection_html_page_name)
      puts('Found cached inflection page: ' + inflection_html_page_name) if @DEBUG
      dictionary_inflection_page_raw_contents = File.read(inflection_html_page_name)
    else
      dictionary_inflection_page_raw_contents = open(dictionary_inflection_url).read
      #dictionary_inflection_page_contents = File.read('N:/Ruby/Discordbot/test/ordbok_nb_blåbærsyltetøy7578.html')
    end
  rescue Exception => e
    # Some error.
    #<Errno::ENOENT: No such file or directory @ rb_sysopen - N:/Ruby/Dis...bot.rb>
    #<URI::InvalidURIError: URI must be ascii only "https://...shg\u00F8wle...type=r">
    puts e.inspect
    return returnval
  ensure
    # This will always be done.
  end

  dictionary_inflection_page_css = @ORDBOK_DICTIONARY_CSS
  #  dictionary_inflection_page_css = <<'PAGE_CSS'
  #PAGE_CSS

  dictionary_inflection_page_contents = '<!DOCTYPE html>'+"\n"+
    '<html lang="no">'+"\n"+
    '<head>'+"\n"+
    '  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>'+"\n"+
    '  <title></title>'+"\n"+
    '  <style type="text/css">'+"\n"+
    dictionary_inflection_page_css +
    '  </style>'+"\n"+
    '</head>'+"\n"+
    '<body><div class="container">'+"\n"+
    dictionary_inflection_page_raw_contents +
    '</div></body>'+"\n"+
    '</html>'
  #puts dictionary_inflection_page_raw_contents.inspect if @DEBUG

  # config/initializers/imgkit.rb
  IMGKit.configure do |config|
    config.wkhtmltoimage = @WKHTMLTOIMAGE_EXE_PATH
    config.default_options = {
      width:    default_image_width,
      'enable-smart-width': 1,
      format:   :jpg,
      quality:  90,
    }
  end

  inflection_image_obj = IMGKit.new(dictionary_inflection_page_contents)
  #inflection_image_png = inflection_image_obj.to_img(:jpg)
  #puts inflection_image_png.inspect if @DEBUG

  begin
    puts('Saving inflection html page... ' +  inflection_html_page_name) if @DEBUG
    File.write(inflection_html_page_name, dictionary_inflection_page_raw_contents)

    puts('Saving inflection image file... ' +  inflection_image_name) if @DEBUG
    file = inflection_image_obj.to_file(inflection_image_name)
    returnval = inflection_image_name
  rescue Exception => e
    # Some error.
    return returnval
  ensure
    # This will always be done.
  end

  return returnval
end



# Do some preliminary checking on the search word.
# Then look up this word in the dictionary and format it as en embedded Discord text-ball.
# @param [EventObject]
# @param [SearchWords]
# @param [true,false] - True if bokmål, false if nynorsk.
# @param [true,false] - True if show more than just the words and their word classes.
# @return [true,yes]
def ordbok_uib_no_dictionary_lookup_wrapper event_obj, search_string, is_bokmål = true, is_expanded = false
  Debug.trace if @DEBUG
  # Removing strange characters.
  # Thank you @High Tide, @Kaos  ;-)
  if search_string.match(@ILLEGAL_DICTIONARY_SEARCH_CHARACTERS)
    puts "#{__LINE__}"+'BAD BOY/GIRL! Illegal characters: ' + search_string
    search_string = search_string.gsub(@ILLEGAL_DICTIONARY_SEARCH_CHARACTERS, '')
    puts 'Changed it into>> ' + search_string + ' <<'
  end

  # If downcasing the search string then dictionary entries that do in fact
  # contain upper case letters can't be found.
  # Unless regular search is turn on, but then you get multiple search hits for words.
  search_string = search_string.downcase
  encoded_search_string = (is_bokmål ? 'nb' : 'nn') + '_' + URI::encode(search_string).downcase
  
  if @ORDBOK_DICTIONARY_WORD_RESPONSES_LOOKUP_TABLE[encoded_search_string].nil?
    word_response_hash = ordbok_uib_no_dictionary_lookup search_string, is_bokmål
    #word_response_hash = ordbok_uib_no_dictionary_lookup search_string, is_bokmål

    if word_response_hash.nil?
      puts 'Search error. Ignoring.'
      return false
    end

    word_response_hash.merge!( timestamp: Time.now )
    @ORDBOK_DICTIONARY_WORD_RESPONSES_LOOKUP_TABLE[encoded_search_string] = word_response_hash
  else
    puts 'Using cached dictionary values.' if @DEBUG
    word_response_hash = @ORDBOK_DICTIONARY_WORD_RESPONSES_LOOKUP_TABLE[encoded_search_string]
  end

  if @DEBUG
    word_response_hash.each do |index,word_data|
      if word_data.is_a?(Integer) ||
         word_data.is_a?(String) ||
         word_data.is_a?(Time)
        puts "----- #{index}: #{word_data}"
      elsif word_data.is_a?(Hash)
        puts "----- #{index} -----"
        word_data.each do |key,value|
          puts "#{key}: #{value}"
        end
      else
        puts word_data.class
      end
    end
  end

  word_count = word_response_hash[:length] || 0
  ordbok_url = word_response_hash[:url] || ''
  ordbok_url_simple = word_response_hash[:url_simple] || ''
  timestamp = word_response_hash[:timestamp] || Time.now
  #puts "There should be #{word_count} words..." if @DEBUG
  
  author_str = (is_bokmål ? 'Bokmålsordboka' : 'Nynorskordboka')
  base_ordbok_url = 'http://ordbok.uib.no/'
  ordbok_info_url = base_ordbok_url + 'info/'
  footer_str = 'Universitetet i Bergen og Språkrådet © 2017'

  description_str = ''
  fields_array = []

  if word_count < 1
    description_str += 'No search results for ['+search_string+']('+ordbok_url+'). You might want to modify your search.' #+"\n"+
      #'    ['+ordbok_url_simple+']('+ordbok_url+')'
  else
    description_str += "[#{word_count}]("+ordbok_url+') ' + (word_count > 1 ? 'entries were' : 'entry was') +
      ' found for [`'+search_string+'` (click me)]('+ordbok_url+').' +
      ' [Help](' + (ordbok_info_url + (is_bokmål ? 'bob' : 'nob') + '_forkl.html') + ').'

    #puts description_str

    (1..word_count).each do |i_counter|
      single_word_hash = word_response_hash[i_counter]
      single_word_ids = single_word_hash[:word_ids].keys
      puts single_word_hash.inspect if @DEBUG && @DEBUG_SPAMMY
      
      word_header = '`'+ single_word_hash[:keyword].gsub('|', '` | `') + '`'
      word_intro = ''
      word_text = ''

      w_counter = 0
      single_word_ids.each do |id|
        word_intro += (single_word_hash[:roman_numerals][id] ? '**' + single_word_hash[:roman_numerals][id].join('**, **') + '** ' : '')
        word_intro += (single_word_hash[:word_spellings][id] ?
          '**' + single_word_hash[:word_spellings][id].join('**, **') + '**' :
          '<Internal error>'
        ) + ' '
        word_intro += (single_word_hash[:word_classes][id] ?
          '*' + single_word_hash[:word_classes][id][:classes].join('*, *') + '*' :
          ''
        ) + ' '

        w_counter += 1
        word_intro += (w_counter < single_word_ids.length ? '; *eller* ' : '')
      end
      word_intro += "\n"
      
      if is_expanded
        word_intro += (single_word_hash[:word_etymology].length > 0 ? single_word_hash[:word_etymology] + "\n" : '')
        word_text += (single_word_hash[:word_synonyms].length > 0 ? single_word_hash[:word_synonyms] + "\n" : '')
        word_text += (single_word_hash[:word_definitions_header].length > 0 ? single_word_hash[:word_definitions_header] + "\n" : '')
        single_word_hash[:word_definitions_array].each { |single_word_def| word_text += single_word_def + "\n" }
      else
      end
      
      word_text = word_intro + word_text

      # Discord's max length
      if word_text.length > 1024
        word_text = word_text[0..1017] + ' [...]'
      end
      
      fields_array.push({ name: word_header, value: word_text })
    end #counter
  end #if

  event_obj.channel.send_embed( '**' + author_str + '**: Official spellings and inflections:' +"\n"+ordbok_url_simple ) do |embed|
    embed.colour = 0x490506
    #embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: search_string + ' (click me)', url: ordbok_url)
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: footer_str)
    #embed.timestamp = timestamp

    #embed.title = ordbok_url_simple
    #embed.url = ordbok_url

    embed.description = description_str
    fields_array.each { |word| embed.add_field(name: word[:name], value: word[:value]) }
  end

  return true
end



# Dumps the hash table for the dictionary entries from memory to the screen/log file.
# TODO: Ability to read it back in.
def save_ordbok_dictionary_word_responses_lookup_table
  Debug.trace if @DEBUG
  Debug.divider
  
  puts @ORDBOK_DICTIONARY_WORD_RESPONSES_LOOKUP_TABLE.inspect

  return true
end



# Adds/remembers the timestamp the user did a command.
# Return true if the user can do the command.
# Return false otherwise.
# Thank you @High Tide ;-)
# @param [EventObject]
# @return [true,false]
def check_if_user_spam_commands event_obj, command, needed_time_since_last_command = 1
  Debug.trace if @DEBUG
  returnval = true
  is_spamming = false

  user_hash = get_user_from_event event_obj
  user_id = user_hash[:id]
  
  remember_me = { cmd: command, time: Time.now }
  timediff_since_last_command = @BOT_INVOKES_TIME_FRAME_LIMIT + 1

  #puts @USER_BOT_INVOKES.inspect if @DEBUG && @DEBUG_SPAMMY
  
  if @USER_BOT_INVOKES.has_key? user_id
    if @USER_BOT_INVOKES[user_id].length > 0
      timediff_since_last_command = Time.now - @USER_BOT_INVOKES[user_id][-1][:time]
    end

    # Check the time since any similar command.
    (0..@USER_BOT_INVOKES[user_id].length-1).each do |i_counter|
      #puts "før: #{timediff_since_last_command}" if @DEBUG && @DEBUG_SPAMMY
      #puts "#{i_counter}: #{@USER_BOT_INVOKES[user_id][i_counter][:cmd]} ==? #{command}" if @DEBUG && @DEBUG_SPAMMY
      # If the command used matches a command previously used, recalculate the time difference.
      if @USER_BOT_INVOKES[user_id][i_counter][:cmd] == command
        timediff_since_last_command = Time.now - @USER_BOT_INVOKES[user_id][i_counter][:time]
      end
      #puts "ett: #{timediff_since_last_command}" if @DEBUG && @DEBUG_SPAMMY
    end

    # Add the latest user command to the array.
    @USER_BOT_INVOKES[user_id].push( remember_me )

    # Loop over all of the user commands and see if of them are old and should be removed.
    (0..@USER_BOT_INVOKES[user_id].length-1).each do |i_counter|
      #puts i_counter if @DEBUG && @DEBUG_SPAMMY
      #puts @USER_BOT_INVOKES[user_id].inspect if @DEBUG && @DEBUG_SPAMMY

      if i_counter > @USER_BOT_INVOKES[user_id].length-1
        break
      end
      timediff = Time.now - @USER_BOT_INVOKES[user_id][i_counter][:time]

      if timediff > @BOT_INVOKES_TIME_FRAME_LIMIT
        @USER_BOT_INVOKES[user_id].shift
        # Redo the loop from the current index.
        redo
      end
    end #loop

    user_invokes = @USER_BOT_INVOKES[user_id]
    #puts user_invokes.length if @DEBUG

    # Give the user a warning before they are over the edge.
    # Timeout is in seconds.
    if user_invokes.length > (@USER_MAX_BOT_INVOKES_PER_TIME_LIMIT + 1)
      returnval = false
    elsif user_invokes.length > @USER_MAX_BOT_INVOKES_PER_TIME_LIMIT
      event_obj.channel.send_temporary_message( user_hash[:mention] + ', you are now **ignored**. Ask the other people here what works.', 5*@BOT_INVOKES_TIME_FRAME_LIMIT)
      returnval = false
    elsif (user_invokes.length + 1) > @USER_MAX_BOT_INVOKES_PER_TIME_LIMIT
      event_obj.channel.send_temporary_message( user_hash[:mention] + ', you **really** need to **calm down**! Try `!help` to see valid commands. Or ask someone else here.', 5*@BOT_INVOKES_TIME_FRAME_LIMIT)
      returnval = true
    #elsif (user_invokes.length + 2) > @USER_MAX_BOT_INVOKES_PER_TIME_LIMIT
    #  returnval = true
    else
      if timediff_since_last_command < needed_time_since_last_command
        event_obj.channel.send_temporary_message('**Ignored**. ' + user_hash[:mention] + ', you should **calm down**.', 5)
        returnval = false
      else
        returnval = true
      end
    end

  else
    @USER_BOT_INVOKES[user_id] = [ remember_me ]
  end

  return returnval
end



# Print outs a message when a new user joins the server.
# @param [EventObject]
# @return [true]
def member_join event_obj
  Debug.trace if @DEBUG

  user_hash = get_user_from_event event_obj
  server_hash = get_server_from_event event_obj

  @BOT_OBJ.send_message(server_hash[:default_channel_id],
    'Hei ' + user_hash[:mention] + ' (id: *'+ user_hash[:id] +'*) og velkommen til **' + server_hash[:servername] + '**!' +"\n"+
    'Feel free to assign yourself an applicable role by typing `!beginner`, `!intermediate`, or `!native`.' +"\n"+
    'We hope you enjoy your stay.')

  return true
end



# Prints out a message when a user leaves the server.
# @param [EventObject]
# @return [true]
def member_leave event_obj
  Debug.trace if @DEBUG

  user_hash = get_user_from_event event_obj
  server_hash = get_server_from_event event_obj

  @BOT_OBJ.send_message(server_hash[:default_channel_id],
    '**' + user_hash[:nick] + '** forlot nettopp serveren. Adjø og ha det bra, **' + user_hash[:nick] + '**!' +"\n"+
    '(Id: *' + user_hash[:id] + '*)')

  return true
end



# Prints out the discord object ids for the server and the current channel to the console.
# @param [EventObject]
# @return [true]
def output_server_and_channel_info event_obj
  Debug.trace if @DEBUG

  Debug.divider
  server_obj = event_obj.server
  puts server_obj.inspect
  puts "serverid: #{server_obj.id}"

  channel_obj = event_obj.channel
  puts channel_obj.inspect
  puts "channelid: #{channel_obj.id}"

  return true
end



# Show the help text.
# @param [EventObject]
# @return [true]
def show_help_text event_obj
  Debug.trace if @DEBUG

  server_hash = get_server_from_event event_obj
  
  event_obj.respond 'Created by **Noko** for the **' + server_hash[:servername] + '** server, with inspiration from **Yoshi**.' +"\n"+
    'Source code for the bot can be found at:' +"\n"+
    '  https://github.com/Brukarnamn/Bifrost' +"\n"+
    @BOT_COMMANDS_LIST+
    'In loving memory of **Askeladden** (2016-2017). Hvil i fred. :sob:'

  return true
end  



# Show the help text.
# @param [EventObject]
# @return [true]
def show_expanded_help_text event_obj
  Debug.trace if @DEBUG

  server_hash = get_server_from_event event_obj
  
  event_obj.respond 'Created by **Noko** for the **' + server_hash[:servername] + '** server, with inspiration from **Yoshi**.' +"\n"+
    'Source code for the bot can be found at:' +"\n"+
    '  https://github.com/Brukarnamn/Bifrost' +"\n"+
    @BOT_COMMANDS_LIST+
    'In loving memory of **Askeladden** (2016-2017). Hvil i fred. :sob:'

  return true
end  



# Check what the user typed as a simple one-word command and do appropriately.
# These are one-word commands that do not parse any arguments.
# @param [EventObject]
# @return [true,false]
def handle_simple_messages event_obj
  Debug.trace if @DEBUG

  command_hash = get_message_from_event event_obj
  user_hash = get_user_from_event event_obj
  #channel_hash = get_channel_from_event event_obj

  text_command = command_hash[:text]

  ## Spam control
  #if check_if_user_spam_commands(event_obj, text_command)
  #else
  #  # Too spammy.
  #  return false
  #end
  
  case text_command
  when 'PING'
    # Shows -1.8 or whatever because the PC-clock is out of sync with Discord's clock.
    #event_obj.respond 'Pong ' + user_hash[:mention] + '! ' + (Time.now - event_obj.timestamp).to_s + ' (Id = ' + user_hash[:id] + ')'
    # Wait 60 seconds before removing the message.
    event_obj.channel.send_temporary_message('Pong ' + user_hash[:mention] + '! (Id = ' + user_hash[:id] + ')', 60) if check_if_user_spam_commands(event_obj, text_command, 5)
  when 'HELP', 'HJELP'
    show_help_text(event_obj) if check_if_user_spam_commands(event_obj, text_command, 60)
  when 'BEGINNER', 'INTERMEDIATE',
    'NATIVE', 'NORSK',
    'SVENSK', 'DANSK', 'DANSKER'
    change_role_permission_on_user(event_obj, @USER_ROLE_COMMANDS[text_command], true) if check_if_user_spam_commands(event_obj, text_command)
  when 'ADVANCED'
    event_obj.respond('Dette nivået må du spørre en moderator om, ' + user_hash[:mention]) if check_if_user_spam_commands(event_obj, text_command)
  when 'NSFW', 'COMP'
    #change_simple_permission_on_user event_obj, @USER_ROLE_COMMANDS[text_command]
    change_role_permission_on_user(event_obj, @USER_ROLE_COMMANDS[text_command]) if check_if_user_spam_commands(event_obj, text_command)
  when 'CHANNELINFO'
    output_server_and_channel_info(event_obj) if check_if_user_spam_commands(event_obj, text_command)
  when 'SAVE_LOOKUP_TABLE'
    save_ordbok_dictionary_word_responses_lookup_table if check_if_user_spam_commands(event_obj, text_command, 60)
  else
    puts 'Unknown command: ' + command_hash[:orig_text]
  end

  return true
end



def handle_complex_messages event_obj
  Debug.trace if @DEBUG
  
  command_hash = get_message_from_event event_obj
  user_hash = get_user_from_event event_obj
  #channel_hash = get_channel_from_event event_obj

  text_command = command_hash[:text]

  ## Spam control
  #if check_if_user_spam_commands event_obj, text_command
  #else
  #  # Too spammy.
  #  return false
  #end

  case text_command
  when 'NB', 'BM', 'BOKMÅL', 'BOKMAL', 'BOKMAAL'
    ordbok_uib_no_dictionary_lookup_wrapper(event_obj, command_hash[:args].join(' '), true, true) if check_if_user_spam_commands(event_obj, text_command, 5)
  when 'NBK', 'BMK', 'BOKMÅL-KORT', 'BOKMAL-KORT', 'BOKMAAL_KORT', 'BOKMÅL_KORT', 'BOKMAL_KORT', 'BOKMAAL_KORT', 'BOKMÅLKORT', 'BOKMALKORT', 'BOKMAALKORT'
    ordbok_uib_no_dictionary_lookup_wrapper(event_obj, command_hash[:args].join(' '), true) if check_if_user_spam_commands(event_obj, text_command, 5)
  when 'NN', 'NYNORSK'
    ordbok_uib_no_dictionary_lookup_wrapper(event_obj, command_hash[:args].join(' '), false, true) if check_if_user_spam_commands(event_obj, text_command, 5)
  when 'NNK', 'NYNORSK-KORT', 'NYNORSK_KORT', 'NYNORSKKORT'
    ordbok_uib_no_dictionary_lookup_wrapper(event_obj, command_hash[:args].join(' '), false) if check_if_user_spam_commands(event_obj, text_command, 5)
  else
    puts 'Unknown command: ' + command_hash[:orig_text]
  end

  return true
end



# Initialize the bot.
# Set up the events it should respond to.
# @return [Discordrb::Bot]
def init_bot
  Debug.trace if @DEBUG
  @BOT_OBJ = Discordrb::Bot.new token: @BOT_SETTINGS_HASH['token'], client_id: @BOT_SETTINGS_HASH['client_id']

  raise 'Unable to start the bot!' if @BOT_OBJ.nil?

  @BOT_OBJ.member_join do |event_obj|
    member_join event_obj
  end

  @BOT_OBJ.member_leave do |event_obj|
    member_leave event_obj
  end

  bot_command_regexp_roles = (@BOT_INVOKE_CHARACTER+'[a-zA-Z\-_]+').freeze
  @BOT_OBJ.message(exact_text: %r{^#{bot_command_regexp_roles}$}) do |event_obj|
    handle_simple_messages event_obj
  end

  bot_command_regexp_dictionary_lookup = (@BOT_INVOKE_CHARACTER+'[a-zA-ZæøåÆØÅ\-_]+(\s+\S+)+').freeze
  @BOT_OBJ.message(exact_text: %r{^#{bot_command_regexp_dictionary_lookup}$}) do |event_obj|
    handle_complex_messages event_obj
  end
    
  return @BOT_OBJ
end



# "Main" part of the program.
# With its own little variable scope.
def main
  Debug.trace if @DEBUG
  load_settings

  @BOT_OBJ = init_bot
  @BOT_OBJ.run
end



# Call the main function.
main


#end



