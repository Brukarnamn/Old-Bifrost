# Bifrost / Askeladden v2
#class BifrostBot
=begin
  Requires the discordrb module and its dependencies.
    https://github.com/meew0/discordrb
  Requires json module to read in personal server keys.
  Requires nokogiri to parse the web pages.
  Requires imgkit and its dependencies to convert from html to image.

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
    MANAGE_ROLES          0x10000000	Allows management and editing of roles

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

# Is the bot running on the test server or the live server.
@TEST = (ARGV.length > 0 ? false.freeze : true.freeze)

# The Discord Bot object
@BOT_OBJ = nil

# Accept only space
# dot .
# unicode letters    \p{L}
# unicode diacritics \p{M}  and
# unicode digits     \p{N}
@ILLEGAL_DICTIONARY_SEARCH_CHARACTERS = /[^ \.\p{L}\p{M}]/.freeze

# The settings read from the configuration files.
# And other global variables.
@GLOBAL_SETTINGS_HASH = {}

# Hash containing user ids and when they last issued a bot command. To prevent them spamming commands.
@USERS_BOT_INVOKES = {}

# Hash containing user ids and the current exercise they are doing.
@USERS_EXERCISE_HASH = {}

# Hash containing the dictionary responses. To prevent asking about the same stuff multiple times.
@ORDBOK_DICTIONARY_WORD_RESPONSES_LOOKUP_TABLE = {}




# Read in the settings in the two configuration files.
# Fill in the global variables (for easier use and less error handling and modifications later.)
# @return [true] Returns true if everything went as planned.
def load_settings command_line_arguments
  Debug.trace if @DEBUG
  returnval = true
  Debug.inspect command_line_arguments if @DEBUG

  bot_settings_filename = './bot_settings' + (@TEST ? '_dev' : '') + '.json'
  file_contents = File.read(bot_settings_filename)
  bot_settings_hash = JSON.parse(file_contents)

  file_contents = File.read('./server_settings.json')
  all_server_settings_hash = JSON.parse(file_contents)

  this_server_settings_hash = {}
  # Copy over all the non-specific server settings to the server specific one.
  all_server_settings_hash.each do |key,value|
    case key
    when /^\d+$/
      # Ignore. Settings for a specific server id.
    else
      this_server_settings_hash[:"#{key}"] = value
    end
  end

  # Find out the server id the bot will run on.
  test_server_id = this_server_settings_hash[:test_server]
  live_server_id = this_server_settings_hash[:live_server]
  if @TEST
    bot_runs_on_server_id = test_server_id
    #Debug.inspect 'Bot will run on the Test-Server: ' + bot_runs_on_server_id.to_s
  else
    bot_runs_on_server_id = live_server_id
    Debug.inspect 'Bot will run on the LIVE-server: ' + bot_runs_on_server_id.to_s
  end
  this_server_settings_hash[:bot_runs_on_server_id] = bot_runs_on_server_id

  admin_system_code = generate_new_system_code
  Debug.inspect admin_system_code, 0, true, 'Starting system code: '
  
  # Copy over the settings for the server the bot should respond on.
  # Don't want our testing to interfere on the live servers.
  # Server-id needs to be converted to a string, since the JSON key can't be a number. Might get nil otherwise.
  all_server_settings_hash[bot_runs_on_server_id.to_s].each { |key,value| this_server_settings_hash[:"#{key}"] = value }

  # Copy over the bot secret keys.
  bot_settings_hash.each { |key,value| this_server_settings_hash[:"#{key}"] = value }
  
  # The CSS used for the generation of html-to-image.
  ordbok_dictionary_css = File.read(this_server_settings_hash[:ordbok_dictionary_css_file_path])
  this_server_settings_hash[:ordbok_dictionary_css] = ordbok_dictionary_css

  # The text for the help texts, faqs, and so on.
  bot_text_contents = load_text_contents_file this_server_settings_hash[:bot_texts_file]
  if bot_text_contents[:status]
    bot_text_contents = bot_text_contents[:contents]
    this_server_settings_hash[:bot_texts] = bot_text_contents
  else
    raise bot_text_contents[:error]
  end
  
  # Some sanity checking, maybe.
  #Debug.inspect bot_text_contents if @DEBUG
  #Debug.inspect this_server_settings_hash if @DEBUG

  # Loop over the active server id and the data in it.
  [1].each do
    #Debug.divider if @DEBUG
    user_role_commands = {}
    # User commands and the corresponding user role.
    if this_server_settings_hash[:roles].nil?
      returnval = false
    else
      this_server_settings_hash[:roles].each do |key,value|
        #puts "#{key} => #{value}" if @DEBUG
        user_role_commands[key.upcase] = value.upcase
      end
      this_server_settings_hash[:uc_user_role_commands] = user_role_commands
    end

    user_exclusive_roles = []
    # User roles the user can only have one of at the same time.
    if this_server_settings_hash[:exclusive_roles].nil?
      returnval = false
    else
      this_server_settings_hash[:exclusive_roles].each do |key|
        #puts "#{key}" if @DEBUG
        user_exclusive_roles.push key.upcase
      end
      this_server_settings_hash[:uc_user_exclusive_roles] = user_exclusive_roles
    end

    # Default chat channel for the bot.
    if this_server_settings_hash[:default_channel_id].nil? || this_server_settings_hash[:default_channel_id] < 1
      puts 'WARNING: Bot is missing a default channel to send messages to.'
      returnval = false
    else
    end

    # Channel for role modification responses.
    if this_server_settings_hash[:role_spam_channel_id].nil? || this_server_settings_hash[:role_spam_channel_id] < 1
      this_server_settings_hash[:role_spam_channel_id] = this_server_settings_hash[:default_channel_id]
    else
    end

    # Channel for role modification responses.
    if this_server_settings_hash[:exercises_channel_id].nil? || this_server_settings_hash[:exercises_channel_id] < 1
      this_server_settings_hash[:exercises_channel_id] = this_server_settings_hash[:default_channel_id]
    else
    end
  end

  @GLOBAL_SETTINGS_HASH = this_server_settings_hash
  if @DEBUG && false
    Debug.divider if @DEBUG
    Debug.inspect @GLOBAL_SETTINGS_HASH
  end

  return returnval
end



# Read in the content of the additional text file that contains the help texts, faqs, exercises, and more.
# @return [true] Returns true if everything went as planned.
def load_text_contents_file input_file
  Debug.trace if @DEBUG
  returnval = {
    status: false,
    error: '',
    contents: {},
  }

  begin
    if !File.file?(input_file)
      raise 'No such file or directory: ' + input_file
    else
      file_contents = File.read(input_file)
      returnval[:contents] = JSON.parse(file_contents)
    end
  rescue JSON::ParserError => e
    #<JSON::ParserError: 765: unexpected token at ''>
    returnval[:error] = 'JSON::ParserError in: ' + input_file
    return returnval
  rescue Exception => e
    # Some error.
    #<Errno::ENOENT: No such file or directory @ rb_sysopen - N:/Ruby/Dis...bot.rb>
    puts e.inspect
    returnval[:error] = e.inspect.to_s
    return returnval
  ensure
    # This will always be done.
  end

  returnval[:status] = true
  #Debug.inspect returnval if @DEBUG
  return returnval
end



# Read in the content of the additional text file that contains the help texts, faqs, exercises, and more.
# @return [true] Returns true if everything went as planned.
def reload_text_contents_file_and_merge input_file, hash_key_symbol_to_overwrite
  Debug.trace if @DEBUG
  returnval = {
    status: false,
    error: '',
  }

  begin
    if !File.file?(input_file)
      raise 'No such file or directory: ' + input_file
    else
      file_contents = File.read(input_file)
      file_contents_hash = JSON.parse(file_contents)
    end
  rescue JSON::ParserError => e
    #<JSON::ParserError: 765: unexpected token at ''>
    returnval[:error] = 'JSON::ParserError in: ' + input_file
    return returnval
  rescue Exception => e
    # Some error.
    #<Errno::ENOENT: No such file or directory @ rb_sysopen - N:/Ruby/Dis...bot.rb>
    puts e.inspect
    returnval[:error] = e.inspect.to_s
    return returnval
  ensure
    # This will always be done.
  end

  @GLOBAL_SETTINGS_HASH[:"#{hash_key_symbol_to_overwrite}"] = file_contents_hash

  returnval[:status] = true
  if @DEBUG && false
    Debug.divider
    Debug.inspect @GLOBAL_SETTINGS_HASH
    #Debug.inspect returnval
  end
  return returnval
end



def generate_new_system_code
  #Debug.trace if @DEBUG

  # Generate the alphabet from a - z, æ, ø, å
  alphabet = [*('a'..'z'),"æ","ø","å"]

  admin_system_code = ''

  # Pick a random number number from between 1..29
  # and use thus number as index in the alphabet array to
  # generate a random 3 letter code.
  3.times { |i| admin_system_code += alphabet[Random.new.rand(0..(alphabet.length-1))] }

  @GLOBAL_SETTINGS_HASH[:bot_system_code] = admin_system_code

  return admin_system_code
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
    nick: '<Someone>',
    discriminator: -1,
    username: '<Someone>#-1',
    id: -1,
    mention: '',
    roles: user_roles,
    channel_id: -1,
    server_id: -1,
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

  if !user_obj.nil?
    returnval[:nick] = user_obj.username.to_s
    returnval[:discriminator] = user_obj.discriminator.to_s
    returnval[:username] = user_obj.username.to_s + '#' + user_obj.discriminator.to_s
    returnval[:id] = user_obj.id
    returnval[:mention] = user_obj.mention.to_s

    returnval[:channel_id] = event_obj.channel.id if event_obj.respond_to?('channel') && !event_obj.channel.nil?
    returnval[:server_id] = event_obj.server.id if event_obj.respond_to?('server') && !event_obj.server.nil?
    
    # Loop over the current roles this user has, and add them in an upper case text
    if user_obj.respond_to?('roles') && !user_obj.roles.nil?
      user_obj.roles.each do |role_obj|
        user_roles[role_obj.name.upcase] = true
      end
      returnval[:roles] = user_roles
    end

    #returnval[:obj] = user_obj
  end

  #Debug.inspect returnval if @DEBUG
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
    server_id: -1,
    obj: nil,
  }

  if !channel_obj.nil?
    returnval[:channelname] = channel_obj.name.to_s
    returnval[:id] = channel_obj.id
    returnval[:server_id] = event_obj.server.id if event_obj.respond_to?('server') && !event_obj.server.nil?
    #returnval[:obj] = channel_obj
  end

  #Debug.inspect returnval if @DEBUG
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
    exercises_channel_id: -1,
    obj: nil,
  }

  if !server_obj.nil?
    server_id_data = @GLOBAL_SETTINGS_HASH

    returnval[:servername] = server_obj.name.to_s
    returnval[:id] = server_obj.id.to_s
    returnval[:default_channel_id] = server_id_data[:default_channel_id]
    returnval[:role_spam_channel_id] = server_id_data[:role_spam_channel_id]
    returnval[:exercises_channel_id] = server_id_data[:exercises_channel_id]
    #returnval[:obj] = server_obj
  end

  #Debug.inspect returnval if @DEBUG
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
    text: '',
    args: [],
    user_id: -1,
    channel_id: -1,
    server_id: -1,
    orig_text: text_message_content,
  }

  if !text_message_content.nil? && (text_message_content.length > 0)
    case event_obj
    when Discordrb::Events::MessageEvent
      user_obj = event_obj.author
    when Discordrb::Events::ServerMemberAddEvent,      # Someone joins
        Discordrb::Events::ServerMemberUpdateEvent,    # Roles gets added/deleted
        Discordrb::Events::ServerMemberDeleteEvent     # Someone leaves
      user_obj = event_obj.user
    else
      puts 'Unknown event type! ' + event_obj.class.to_s
    end
    returnval[:user_id] = user_obj.id if !user_obj.nil?
    returnval[:channel_id] = event_obj.channel.id if event_obj.respond_to?('channel') && !event_obj.channel.nil?
    returnval[:server_id] = event_obj.server.id if event_obj.respond_to?('server') && !event_obj.server.nil?

    if @GLOBAL_SETTINGS_HASH[:bot_runs_on_server_id] == returnval[:server_id] &&
       @GLOBAL_SETTINGS_HASH[:bot_invoke_character] == text_message_content[0]
      # If the command was in a server channel, then
      # remove the first character and turn it all into upper case letters.
      text_string = text_message_content[1..-1] || ''
    else
      text_string = text_message_content || ''
    end
    text_array = text_string.split(/\s+/)
    #puts text_string.inspect
    #puts text_array.inspect

    returnval[:text] = text_array[0].upcase || 'HELP'
    returnval[:args] = text_array[1..-1]    || ''
  end

  #Debug.inspect returnval if @DEBUG
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

  #Debug.inspect returnval if @DEBUG
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
  #Debug.inspect permission_role if @DEBUG
  #Debug.inspect server_roles_hash[permission_role] if @DEBUG

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
        @GLOBAL_SETTINGS_HASH[:uc_user_exclusive_roles].each do |role_name|
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

  ordbok_word_html_page_name = @GLOBAL_SETTINGS_HASH[:word_inflection_image_path] + '/' +
    'ordbok_' + search_string.to_s + '_'+ (is_bokmål ? 'nb' : 'nn') + '.html'

  Debug.inspect dictionary_url if @DEBUG
  
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

  returnval = word_hash
  #Debug.inspect returnval if @DEBUG
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

  inflection_image_name = @GLOBAL_SETTINGS_HASH[:word_inflection_image_path] + '/' +
    (is_bokmål ? 'nb' : 'nn') + '_bøyningsmønster_' + word_id.to_s + '.jpg'

  inflection_html_page_name = @GLOBAL_SETTINGS_HASH[:word_inflection_image_path] + '/' +
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

  dictionary_inflection_page_css = @GLOBAL_SETTINGS_HASH[:ordbok_dictionary_css]
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
    config.wkhtmltoimage = @GLOBAL_SETTINGS_HASH[:wkhtmltoimage_exe_path]
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

  Debug.inspect word_response_hash if @DEBUG

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
    embed.colour = @GLOBAL_SETTINGS_HASH[:bot_text_embed_color]
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
# TODO: Have it write to file.
# TODO: Ability to read it back in.
def save_ordbok_dictionary_word_responses_lookup_table
  Debug.trace if @DEBUG
  Debug.divider
  
  #Debug.inspect @ORDBOK_DICTIONARY_WORD_RESPONSES_LOOKUP_TABLE
  puts @ORDBOK_DICTIONARY_WORD_RESPONSES_LOOKUP_TABLE.inspect

  return true
end



# Creates a Discord embedded text blob and shows it.
def create_and_send_discord_embed event_obj, embed_text_info_hash
  Debug.trace if @DEBUG
  #puts embed_text_info_hash.inspect if @DEBUG

  hash_embed_content = embed_text_info_hash['content']
  hash_embed_title = embed_text_info_hash['title']
  hash_embed_title_url = embed_text_info_hash['title_url']
  hash_embed_description = embed_text_info_hash['description']
  hash_embed_fields = embed_text_info_hash['fields']
  hash_embed_footer = embed_text_info_hash['footer']

  event_obj.channel.send_embed(hash_embed_content) do |embed|
    embed.colour = @GLOBAL_SETTINGS_HASH[:bot_text_embed_color]

    #puts hash_embed_title.inspect
    #puts hash_embed_title_url.inspect
    embed.title = hash_embed_title if hash_embed_title
    embed.url = hash_embed_title_url if hash_embed_title_url

    if hash_embed_description && hash_embed_description.is_a?(Array)
      #puts hash_embed_description.join('\n').inspect
      embed.description = hash_embed_description.join("\n")
    end

    #puts hash_embed_fields.inspect
    if hash_embed_fields && hash_embed_fields.length > 0
      hash_embed_fields.each do |single_field|
        #puts single_field.inspect
        if single_field['name'] && single_field['value'] && single_field['value'].is_a?(Array)
          embed.add_field(name: single_field['name'], value: single_field['value'].join("\n"), inline: single_field['inline'])
        end
      end
    end

    #puts hash_embed_footer.inspect
    if hash_embed_footer
      if hash_embed_footer['text']
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: hash_embed_footer['text'], icon_url: hash_embed_footer['icon_url'])
      end
      embed.timestamp = hash_embed_footer['timestamp'] if hash_embed_footer['timestamp']
    end
  end

  return true
end



def choose_norwegian_exercise event_obj
  Debug.trace if @DEBUG

  command_hash = get_message_from_event event_obj
  user_id = command_hash[:user_id]
  exercises_hash = @GLOBAL_SETTINGS_HASH[:bot_texts]['øvelser']
  #Debug.inspect command_hash
  #Debug.inspect exercises_hash

  exercise_variations = exercises_hash.keys
  variation_number = Random.new.rand(0..(exercise_variations.length-1))

  exercises_to_choose_from = exercises_hash[exercise_variations[variation_number]]
  exercise_number = Random.new.rand(0..(exercises_to_choose_from.length-1))

  chosen_exercise = exercises_to_choose_from[exercise_number]

  case exercise_variations[variation_number]
  when 'preposisjoner'
    title_text = 'Velg riktig preposisjon / Choose the correct preposition'
    task_text = 'Insert the missing preposition in the sentence below.'+"\n"+'(fra | til | i | rundt | for | på | under | over | foran | bak | ved siden av | med)'
  else
    title_text = 'Uncategorized'
    task_text = 'Insert the missing word(s) in the sentence below.'
  end
  
  chosen_exercise['text_header'] = title_text
  chosen_exercise['text_start'] = task_text
  chosen_exercise['text_id'] = 'Seksjon ' + (variation_number+1).to_s + ' oppgave ' + (exercise_number+1).to_s

  @USERS_EXERCISE_HASH[user_id] = chosen_exercise
  #Debug.inspect @USERS_EXERCISE_HASH[user_id]

  show_norwegian_exercise event_obj

  return true
end



def show_norwegian_exercise event_obj
  Debug.trace if @DEBUG

  command_hash = get_message_from_event event_obj
  user_id = command_hash[:user_id]
  #Debug.inspect command_hash
  #Debug.inspect exercises_hash

  chosen_exercise = @USERS_EXERCISE_HASH[user_id]
  #Debug.inspect @USERS_EXERCISE_HASH[user_id]

  if chosen_exercise.nil? || chosen_exercise.keys.length < 1
    event_obj.respond('You have not started on any (new) exercises yet.')
    return false
  end
  
  exercise_text_hash = {}
  exercise_text_hash['title'] = chosen_exercise['text_header']
  exercise_text_hash['description'] = [
    chosen_exercise['text_start'],
    '',
    chosen_exercise['sentence'],
    (chosen_exercise['meaning'] && chosen_exercise['meaning'].length > 0 ? ('*'+chosen_exercise['meaning']+'*') : '*Translation missing.*'),
    '',
    'Answer by either responding in',
    '1) A private message with `svar <your answer>`',
    'or 2) In the server channel with `!svar <your answer>` (note the `!`)',
    'Replace `<your answer>` with the Norwegian word(s) you think is correct.',
    '',
    'To get a new exercise you can type the starting command in here, but without the `!` at the start. For example `test`.',
  ]
  exercise_text_hash['footer'] = chosen_exercise['text_id']
  #create_and_send_discord_embed(event_obj, exercise_text_hash)
  #Debug.inspect exercise_text_hash if @DEBUG
  puts (command_hash[:user_id].to_s) + ' -> ' + chosen_exercise['text_id'] if @DEBUG
  
  message_text = [
    '**'+exercise_text_hash['title']+'**',
    exercise_text_hash['description'].join("\n"),
    '*'+exercise_text_hash['footer']+'*',
  ].join("\n")

  if command_hash[:server_id] == @GLOBAL_SETTINGS_HASH[:bot_runs_on_server_id]
    event_obj.author.pm(message_text)
    event_obj.channel.send_temporary_message('<@'+(command_hash[:user_id].to_s)+'>, please check your private messages.', 10)
  else
    event_obj.respond(message_text)
  end

  return true
end



def user_response_to_norwegian_exercise event_obj, answer_str
  Debug.trace if @DEBUG

  command_hash = get_message_from_event event_obj
  user_id = command_hash[:user_id]
  text_command_args = command_hash[:args].join(' ').downcase.strip
  #Debug.inspect command_hash
  #Debug.inspect exercises_hash

  chosen_exercise = @USERS_EXERCISE_HASH[user_id]
  #Debug.inspect @USERS_EXERCISE_HASH[user_id]

  if chosen_exercise.nil? || chosen_exercise.keys.length < 1
    event_obj.respond('You have not started on any (new) exercises yet.')
    return false
  end

  puts (command_hash[:user_id].to_s) + ' -> ' + chosen_exercise['text_id'] + ' -> '+ text_command_args if @DEBUG

  is_correct_answer = false
  chosen_exercise['correct'].each do |correct|
    #puts correct.inspect
    if text_command_args == correct
      is_correct_answer = true
      break
    end
  end

  if command_hash[:server_id] == @GLOBAL_SETTINGS_HASH[:bot_runs_on_server_id]
    event_obj.channel.send_temporary_message('<@'+(command_hash[:user_id].to_s)+'>, please check your private messages.', 10)
  end

  if is_correct_answer
    event_obj.author.pm('`' + text_command_args + '` is **correct**! Well done. :relieved:')
    @USERS_EXERCISE_HASH[user_id] = {}
  else
    answer_text = '`' + text_command_args + '` is unfortunately **wrong**. :confused:'
    chosen_exercise['wrong'].each do |wrong|
      #puts wrong.inspect
      if text_command_args == wrong['word'] && wrong['reason']
        answer_text += 'In this context `' + wrong['word'] + '` would mean ' + wrong['reason'] + '.'
      end
    end
    event_obj.author.pm(answer_text)
  end
end



# Adds/remembers the timestamp the user did a command.
# Return true if the user can do the command.
# Return false otherwise.
# Thank you @High Tide ;-)
# @param [EventObject]
# @return [true,false]
def check_if_user_spam_commands event_obj, command = Time.now.to_s, needed_time_since_last_similar_command = @GLOBAL_SETTINGS_HASH[:user_bot_invokes_minimum_time_frame_limit]
  Debug.trace if @DEBUG
  returnval = true
  is_spamming = false

  user_hash = get_user_from_event event_obj
  user_id = user_hash[:id]
  #puts user_hash.inspect if @DEBUG
  
  remember_me = { cmd: command, time: Time.now }
  timediff_since_last_similar_command = timediff_since_last_command = @GLOBAL_SETTINGS_HASH[:bot_invokes_time_frame_period] + 1
  
  #Debug.inspect @USERS_BOT_INVOKES if @DEBUG
  
  if @USERS_BOT_INVOKES.has_key? user_id
    if @USERS_BOT_INVOKES[user_id].length > 0
      timediff_since_last_command = Time.now - @USERS_BOT_INVOKES[user_id][-1][:time]
    end

    # Check the time since any similar command.
    (0..@USERS_BOT_INVOKES[user_id].length-1).each do |i_counter|
      #puts "før: #{timediff_since_last_similar_command}" if @DEBUG && @DEBUG_SPAMMY
      #puts "#{i_counter}: #{@USERS_BOT_INVOKES[user_id][i_counter][:cmd]} ==? #{command}" if @DEBUG && @DEBUG_SPAMMY
      # If the command used matches a command previously used, recalculate the time difference.
      if @USERS_BOT_INVOKES[user_id][i_counter][:cmd] == command
        timediff_since_last_similar_command = Time.now - @USERS_BOT_INVOKES[user_id][i_counter][:time]
      end
      #puts "ett: #{timediff_since_last_similar_command}" if @DEBUG && @DEBUG_SPAMMY
    end #loop

    # Add the latest user command to the array.
    @USERS_BOT_INVOKES[user_id].push( remember_me )

    # Loop over all of the user commands and see if of them are old and should be removed.
    (0..@USERS_BOT_INVOKES[user_id].length-1).each do |i_counter|
      #puts i_counter if @DEBUG && @DEBUG_SPAMMY
      #puts @USERS_BOT_INVOKES[user_id].inspect if @DEBUG && @DEBUG_SPAMMY

      if i_counter > @USERS_BOT_INVOKES[user_id].length-1
        break
      end
      timediff = Time.now - @USERS_BOT_INVOKES[user_id][i_counter][:time]

      if timediff > @GLOBAL_SETTINGS_HASH[:bot_invokes_time_frame_period]
        @USERS_BOT_INVOKES[user_id].shift
        # Redo the loop from the current index.
        redo
      end
    end #loop

    user_invokes = @USERS_BOT_INVOKES[user_id]
    #puts user_invokes.length if @DEBUG
    max_user_invokes = @GLOBAL_SETTINGS_HASH[:user_max_bot_invokes_per_time_limit]

    # Give the user a warning before they are over the edge.
    # Timeout is in seconds.
    if user_invokes.length > (max_user_invokes + 1)
      returnval = false
    elsif user_invokes.length > max_user_invokes
      event_obj.channel.send_temporary_message(user_hash[:mention] + ', you are now **ignored**. Ask the other people here what works.',
        5 * @GLOBAL_SETTINGS_HASH[:bot_invokes_time_frame_period])
      returnval = false
    elsif (user_invokes.length + 1) > max_user_invokes
      event_obj.channel.send_temporary_message(user_hash[:mention] + ', you **really** need to **calm down**! '+
        'Try `!help` to see valid commands. Or ask someone else here.',
        5 * @GLOBAL_SETTINGS_HASH[:bot_invokes_time_frame_period])
      returnval = true
    #elsif (user_invokes.length + 2) > max_user_invokes
    #  returnval = true
    else
      if timediff_since_last_command < @GLOBAL_SETTINGS_HASH[:user_bot_invokes_minimum_time_frame_limit] || timediff_since_last_similar_command < needed_time_since_last_similar_command
        event_obj.channel.send_temporary_message('**Ignored**. ' + user_hash[:mention] + ', you should **calm down**.', 5)
        returnval = false
      else
        returnval = true
      end
    end

  else
    @USERS_BOT_INVOKES[user_id] = [ remember_me ]
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
    'Hei ' + user_hash[:mention] + ' (id: *'+ (user_hash[:id].to_s) +'*) og velkommen til **' + server_hash[:servername] + '**!' +"\n"+
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
    '(Id: *' + (user_hash[:id].to_s) + '*)')

  return true
end



# Prints out the discord object ids for the server and the current channel to the console.
# @param [EventObject]
# @return [true]
def output_server_and_channel_info event_obj
  Debug.trace if @DEBUG

  Debug.divider
  server_obj = event_obj.server
  Debug.inspect server_obj
  puts 'serverid: ' + (server_obj.nil? ? 'nil' : server_obj.id.to_s)

  channel_obj = event_obj.channel
  Debug.inspect channel_obj
  puts 'channelid: ' + (channel_obj.nil? ? 'nil' : channel_obj.id.to_s)

  return true
end



# Show the help text.
# @param [EventObject]
# @return [true]
def show_help_text event_obj, command
  Debug.trace if @DEBUG

  puts command.inspect if @DEBUG
  bot_text_contents = @GLOBAL_SETTINGS_HASH[:bot_texts]

  case command
  when 'HJELP'
    create_and_send_discord_embed event_obj, bot_text_contents['hjelp'] if bot_text_contents['hjelp']
  when 'HJELP_ROLLER'
    create_and_send_discord_embed event_obj, bot_text_contents['hjelp_roller'] if bot_text_contents['hjelp_roller']
  when 'HJELP_OSS'
    create_and_send_discord_embed event_obj, bot_text_contents['hjelp_oss'] if bot_text_contents['hjelp_oss']
  when 'HJELP_ANNET'
    create_and_send_discord_embed event_obj, bot_text_contents['hjelp_annet'] if bot_text_contents['hjelp_annet']
  else
    event_obj.respond 'Help text is missing. Please contact a moderator to get this fixed.'
  end

  return true
end  



# Show a faq text.
# @param [EventObject]
# @return [true]
def show_faq_text event_obj, command
  Debug.trace if @DEBUG
  
  puts command.inspect if @DEBUG
  bot_text_contents = @GLOBAL_SETTINGS_HASH[:bot_texts]
  
  create_and_send_discord_embed event_obj, bot_text_contents[command] if bot_text_contents[command]
  
  return true
end



# Handle commands that the bot should respond to in both private messages
# and if written on the server.
# Returns true if the command was handled.
# Returns false otherwise.
# @param [EventObject]
# @param [is_private_message]
# @param [text_command]
# @param [text_command_args]
# @return [true,false]
def handle_server_or_private_messages event_obj, is_private_message, text_command, text_command_args
  Debug.trace if @DEBUG
  returnval = true
  
  # If private messages then you are only spamming yourself.
  # If used on the server channel then limit how often you can do them.

  # Remove the first character if it is a private message.
  if is_private_message && text_command[0] == @GLOBAL_SETTINGS_HASH[:bot_invoke_character]
    #text_command = text_command[1..-1]
  end

  begin
    case text_command
    # Help texts.
    when /^HJ?ELP$/
      case text_command_args.upcase
      when /^ROLES?$/, 'ROLLER'
        is_private_message ? show_help_text(event_obj, 'HJELP_ROLLER') :
                          ( show_help_text(event_obj, 'HJELP_ROLLER') if check_if_user_spam_commands(event_obj, 'HJELP_ROLLER', 60) )
      when /^FAQS?$/, 'OSS', 'OBS'
        is_private_message ? show_help_text(event_obj, 'HJELP_OSS') :
                          ( show_help_text(event_obj, 'HJELP_OSS') if check_if_user_spam_commands(event_obj, 'HJELP_OSS', 60) )
      when /^OTHERS?$/, 'ANNET'
        is_private_message ? show_help_text(event_obj, 'HJELP_ANNET') :
                          ( show_help_text(event_obj, 'HJELP_ANNET') if check_if_user_spam_commands(event_obj, 'HJELP_ANNET', 60) )
      else
        is_private_message ? show_help_text(event_obj, 'HJELP') :
                          ( show_help_text(event_obj, 'HJELP') if check_if_user_spam_commands(event_obj, 'HJELP', 60) )
      end

    when /^HJ?ELP/
      case text_command
      when /^HELP[\-_]?ROLES$/, /^HJELP[\-_]?ROLLER$/
        is_private_message ? show_help_text(event_obj, 'HJELP_ROLLER') :
                          ( show_help_text(event_obj, 'HJELP_ROLLER') if check_if_user_spam_commands(event_obj, 'HJELP_ROLLER', 60) )
      when /^HELP[\-_]?FAQ$/, /^HJELP[\-_]?(OSS|OBS)$/
        is_private_message ? show_help_text(event_obj, 'HJELP_OSS') :
                          ( show_help_text(event_obj, 'HJELP_OSS') if check_if_user_spam_commands(event_obj, 'HJELP_OSS', 60) )
      when /^HELP[\-_]?OTHERS?$/, /^HJELP[\-_]?ANNET$/
        is_private_message ? show_help_text(event_obj, 'HJELP_ANNET') :
                          ( show_help_text(event_obj, 'HJELP_ANNET') if check_if_user_spam_commands(event_obj, 'HJELP_ANNET', 60) )
      else
        is_private_message ? show_help_text(event_obj, 'HJELP') :
                          ( show_help_text(event_obj, 'HJELP') if check_if_user_spam_commands(event_obj, 'HJELP', 60) )
      end

    # Faq texts.
    when 'FAQ', 'OSS', 'OBS'
      faq_text = text_command_args.downcase
      if @GLOBAL_SETTINGS_HASH[:bot_texts]['oss_'+faq_text]
        is_private_message ? show_faq_text(event_obj, 'oss_'+faq_text) :
                          ( show_faq_text(event_obj, 'oss_'+faq_text) if check_if_user_spam_commands(event_obj, 'FAQ_'+text_command_args.upcase, 60) )
      else
        is_private_message ? show_help_text(event_obj, 'HJELP_OSS') :
                          ( show_help_text(event_obj, 'HJELP_OSS') if check_if_user_spam_commands(event_obj, 'HJELP_OSS', 60) )
      end

    when /^OPP(GAVE)?$/, 'ØVELSE', 'TEST', 'PRACTICE', 'PRACTISE', 'EXERCISE'
      choose_norwegian_exercise event_obj

    when 'VIS', 'SHOW'
      show_norwegian_exercise event_obj

    when 'SVAR', 'ANSWER'
      user_response_to_norwegian_exercise event_obj, text_command_args
      
    # Ping. Pong.
    when 'PING'
      # Shows -1.8 or whatever if the PC-clock is out of sync with Discord's clock.
      # Wait 60 seconds before removing the message.
      user_hash = get_user_from_event event_obj
      if check_if_user_spam_commands(event_obj, text_command, 5)
        if is_private_message
          event_obj.channel.send_message('Pong ' + user_hash[:mention] + '! (Id = ' + (user_hash[:id].to_s) + ')')
        else
          event_obj.channel.send_temporary_message('Pong ' + user_hash[:mention] + '! (Id = ' + (user_hash[:id].to_s) + ')', 60)
        end
      end

    when 'CHANNELINFO'
      if check_if_user_spam_commands(event_obj, text_command) && text_command_args == @GLOBAL_SETTINGS_HASH[:bot_system_code]
        output_server_and_channel_info(event_obj)
      end

    else
      puts '`' + text_command + '` not caught by handle_server_and_private_messages()' if @DEBUG
      returnval = false
    end
  rescue Discordrb::Errors::NoPermission => e
    puts 'Discordrb::Errors::NoPermission'
    puts e.inspect
  ensure
    # This will always be done.
  end

  return returnval
end



# Check what the user typed as a bot command and do appropriately.
# @param [EventObject]
# @return [true,false]
def handle_complex_messages event_obj
  Debug.trace if @DEBUG
  
  command_hash = get_message_from_event event_obj
  user_hash = get_user_from_event event_obj
  #Debug.inspect command_hash if @DEBUG
  Debug.inspect user_hash if @DEBUG

  is_private_message = (command_hash[:server_id] == @GLOBAL_SETTINGS_HASH[:bot_runs_on_server_id] ? false : true)
  text_command = command_hash[:text]
  text_command_args = command_hash[:args].join(' ')

  return if handle_server_or_private_messages event_obj, is_private_message, text_command, text_command_args
  return if is_private_message
  users_role_commands = @GLOBAL_SETTINGS_HASH[:uc_user_role_commands]

  case text_command
  when 'BEGINNER', 'INTERMEDIATE'
    change_role_permission_on_user(event_obj, users_role_commands[text_command], true) if check_if_user_spam_commands(event_obj, text_command)
  when 'ADVANCED'
    event_obj.respond('Dette nivået må du spørre en moderator om, ' + user_hash[:mention]) if check_if_user_spam_commands(event_obj, text_command)
  when 'NATIVE', 'NORSK'
    change_role_permission_on_user(event_obj, users_role_commands[text_command], true) if check_if_user_spam_commands(event_obj, 'NORSK')
  when 'SVENSK'
    change_role_permission_on_user(event_obj, users_role_commands[text_command], true) if check_if_user_spam_commands(event_obj, 'SVENSK')
  when 'DANSK', 'DANSKER'
    change_role_permission_on_user(event_obj, users_role_commands[text_command], true) if check_if_user_spam_commands(event_obj, 'DANSK')
  when 'NSFW', 'COMP'
    change_role_permission_on_user(event_obj, users_role_commands[text_command]) if check_if_user_spam_commands(event_obj, text_command)
  when 'NB', 'BM', /^BOKM(Å|AA|A)L$/
    ordbok_uib_no_dictionary_lookup_wrapper(event_obj, text_command_args, true, true) if check_if_user_spam_commands(event_obj, 'ORDBOK', 5)
  when /^(NB|BM)[KS]$/, /^BOKM(Å|AA|A)L[\-_]?(KORT|SHORT)$/
    ordbok_uib_no_dictionary_lookup_wrapper(event_obj, text_command_args, true) if check_if_user_spam_commands(event_obj, 'ORDBOK', 5)
  when 'NN', 'NYNORSK'
    ordbok_uib_no_dictionary_lookup_wrapper(event_obj, text_command_args, false, true) if check_if_user_spam_commands(event_obj, 'ORDBOK', 5)
  when /^(NN)[KS]$/, /^NYNORSK[\-_]?(KORT|SHORT)$/
    ordbok_uib_no_dictionary_lookup_wrapper(event_obj, text_command_args, false) if check_if_user_spam_commands(event_obj, 'ORDBOK', 5)
  when 'RELOADTEXT'
    if check_if_user_spam_commands(event_obj, 'RELOAD_TEXT_CONTENTS_FILE', 10) && text_command_args == @GLOBAL_SETTINGS_HASH[:bot_system_code]
      success_status = reload_text_contents_file_and_merge @GLOBAL_SETTINGS_HASH[:bot_texts_file], :bot_texts
      if success_status[:status]
        event_obj.channel.send_temporary_message('Done.', 60) 
      else
        event_obj.channel.send_temporary_message(success_status[:error], 60)
      end
    end
  when 'SAVEDICTIONARYLOOKUPTABLE'
    if check_if_user_spam_commands(event_obj, 'SAVE_DICTIONARY_LOOKUP_TABLE', 10) && text_command_args == @GLOBAL_SETTINGS_HASH[:bot_system_code]
      save_ordbok_dictionary_word_responses_lookup_table
      event_obj.respond('What are you doing, '+user_hash[:mention]+'? :thinking:')
    end
  when 'DEBUGSETTINGS'
    if check_if_user_spam_commands(event_obj, 'DEBUG_SETTINGS', 10) && text_command_args == @GLOBAL_SETTINGS_HASH[:bot_system_code]
      Debug.divider
      Debug.inspect @GLOBAL_SETTINGS_HASH
      event_obj.respond('What are you doing, '+user_hash[:mention]+'? :thinking:')
    end
  else
    puts 'Unknown command: ' + command_hash[:orig_text]
  end

  return true
end



def handle_complex_private_messages event_obj
  Debug.trace if @DEBUG

  command_hash = get_message_from_event event_obj
  user_hash = get_user_from_event event_obj
  #Debug.inspect command_hash if @DEBUG
  Debug.inspect user_hash if @DEBUG

  is_private_message = (command_hash[:server_id] == @GLOBAL_SETTINGS_HASH[:bot_runs_on_server_id] ? false : true)
  text_command = command_hash[:text]
  text_command_args = command_hash[:args].join(' ')

  return if handle_server_or_private_messages event_obj, is_private_message, text_command, command_hash[:args].join(' ')

  case text_command
  when 'HEI'
    event_obj.respond('Hei på deg.')
  else
    event_obj.respond('Unknown command.')
  end

  return true
end



# Initialize the bot.
# Set up the events it should respond to.
# @return [Discordrb::Bot]
def init_bot
  Debug.trace if @DEBUG
  @BOT_OBJ = Discordrb::Bot.new token: @GLOBAL_SETTINGS_HASH[:token], client_id: @GLOBAL_SETTINGS_HASH[:client_id]

  raise 'Unable to start the bot!' if @BOT_OBJ.nil?

  @BOT_OBJ.member_join do |event_obj|
    member_join event_obj
  end

  @BOT_OBJ.member_leave do |event_obj|
    member_leave event_obj
  end

  @BOT_OBJ.ready do |event_obj|
    puts 'Connected...?'
    ready_bot event_obj
  end

  @BOT_OBJ.disconnected do |event_obj|
    puts 'Disconneted...?'
    #save_ordbok_dictionary_word_responses_lookup_table
  end

  @BOT_OBJ.heartbeat do |event_obj|
    admin_system_code = generate_new_system_code
    Debug.inspect admin_system_code, 0, true, 'Heartbeat... '
  end

  bot_invoke_character = @GLOBAL_SETTINGS_HASH[:bot_invoke_character]
  valid_bot_command_characters = '[a-zA-ZæøåÆØÅ\-_]+'

  bot_command_regexp_multi_word = (bot_invoke_character + valid_bot_command_characters + '(\s+\S+)*').freeze
  @BOT_OBJ.message(exact_text: %r{^#{bot_command_regexp_multi_word}$}) do |event_obj|
    handle_complex_messages event_obj
  end

  # A message event also triggers a private message event. But might be stopped depending on the string/regexp to respond on.
  #private_bot_command_regexp_multi_word = (bot_invoke_character+'?' + valid_bot_command_characters + '(\s+\S+)*').freeze
  private_bot_command_regexp_multi_word = (valid_bot_command_characters + '(\s+\S+)*').freeze
  @BOT_OBJ.private_message(exact_text: %r{^#{private_bot_command_regexp_multi_word}$}) do |event_obj|
    handle_complex_private_messages event_obj
  end
    
  return @BOT_OBJ
end



def ready_bot event_obj
  Debug.trace if @DEBUG

  @BOT_OBJ.game = 'Heimdall\'s Bridge'

  return true
end



# "Main" part of the program.
# With its own little variable scope.
def main command_line_arguments
  Debug.trace if @DEBUG

  load_settings command_line_arguments

  @BOT_OBJ = init_bot
  @BOT_OBJ.run

  return true
end



# Call the main function.
main ARGV



#end



=begin
_example_on_how_the_global_settings_variable_could_look_like_ = 
{
  :client_id => "361603350975741952",
  :client_secret => "ejfCgfcK5TN6pXs1BgjfNTIlaiUEdTrq",
  :token => "MzYxNjAzMzUwOTc1NzQxOTUy.DK5egA.W6_YKiC4ld-uaqmxCHwo4f_AGbk",
  :test_server => 348172070947127306,
  :live_server => 202189706383982605,
  :bot_runs_on_server_id => 348172070947127306,
  :default_channel_id => 348172071412563971,
  :role_spam_channel_id => 348172071412563971,
  :exercises_channel_id => 363718468421419008,
  :bot_invoke_character => "!",
  :bot_texts_file => "./bot_texts.json",
  :bot_texts => {
    "hjelp": {
    },
    "hjelp-roller": {
    },
    "hjelp-annet": {
    },
    "hjelp-oss": {
    },
    "oss-roles": {
    },
    "øvelser": {
      "preposisjoner": [
        {
          "sentence": "De bor ___ en leilighet.",
          "meaning": "They live in an apartment.",
          "correct": [ "i" ],
          "wrong": [  ]
        },
        {
          "sentence": "Hvilken farge er det ___ huset?",
          "meaning": "Which colour is (it on) the house.",
          "correct": [ "på" ],
          "wrong": [  ]
        },
        {  }
      ]
    }
  },
  :bot_text_embed_color => "0x490506",
  :user_max_bot_invokes_per_time_limit => 5,
  :user_bot_invokes_minimum_time_frame_limit => 1,
  :bot_invokes_time_frame_period => 60,
  :wkhtmltoimage_exe_path => "c:/bin/wkhtmltopdf/bin/wkhtmltoimage.exe",
  :ordbok_dictionary_css_file_path => "./ordbok_uib_no.css",
  :ordbok_dictionary_css => "...",
  :word_inflection_image_path => "d:/bifrost-discordbot",
  :roles => {
    "beginner": "beginner",
    "intermediate": "intermediate",
    "advanced": "advanced",
    "nsfw": "nsfw",
    "comp": "computer wannabe",
    "native": "norwegian native speaker",
    "norsk": "norwegian native speaker",
    "svensk": "swedish native speaker",
    "dansk": "danish native speaker",
    "dansker": "danish native speaker"
  },
  :exclusive_roles => [
    "beginner",
    "intermediate",
    "advanced",
    "norwegian native speaker",
    "swedish native speaker",
    "danish native speaker"
  ],
  :uc_user_role_commands => {
    "BEGINNER": "BEGINNER",
    "INTERMEDIATE": "INTERMEDIATE",
    "ADVANCED": "ADVANCED",
    "NSFW": "NSFW",
    "COMP": "COMPUTER WANNABE",
    "NATIVE": "NORWEGIAN NATIVE SPEAKER",
    "NORSK": "NORWEGIAN NATIVE SPEAKER",
    "SVENSK": "SWEDISH NATIVE SPEAKER",
    "DANSK": "DANISH NATIVE SPEAKER",
    "DANSKER": "DANISH NATIVE SPEAKER"
  },
  :uc_user_exclusive_roles => [
    "BEGINNER",
    "INTERMEDIATE",
    "ADVANCED",
    "NORWEGIAN NATIVE SPEAKER",
    "SWEDISH NATIVE SPEAKER",
    "DANISH NATIVE SPEAKER"
  ]
}
Debug.inspect _example_on_how_the_global_settings_variable_could_look_like_
=end
