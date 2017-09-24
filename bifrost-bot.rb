# Bifrost / Askeladden v2
#class BifrostBot
=begin
  Requires the discordrb module and its dependencies.
    https://github.com/meew0/discordrb
  Requires json module to read in personal server keys.

  In Windows, open "Command Prompt with Ruby".

    gem install discordrb --platform=ruby
    gem install json --platform=ruby

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
    https://discordapp.com/oauth2/authorize?client_id=361253623881269258&scope=bot&permissions=335612928

  Run the program with
    ruby -I. bot.rb
    ruby -I. -w bot.rb
  or for more interactive purposes
    irb -I. -r bot.rb

  Invite link to the Testserver
    https://discord.gg/qTG4GQH
  Invite link to the English-Norwegian server
    https://discordapp.com/invite/scTV7aV

    <Server name=English-Norwegian Language Exchange id=202189706383982605 large=true region=us-east owner=#<Discordrb::User:0x0000000002f163f8> afk_channel_id=0 afk_timeout=300>
      serverid: 202189706383982605
    <Channel name=conversation id=202189706383982605 topic="English preferred in this channel, thanks. :)" type=0 position=4 server=#<Discordrb::Server:0x0000000003351698>>
      channelid: 202189706383982605
=end
# Json must be loaded first, or strange things happens.
begin
  require 'json'        or raise 'json'
  require 'discordrb'   or raise 'discordrb'
  require 'debug'       or raise 'debug'
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
@TEST = false.freeze;
@BOT_RUNS_ON_SERVER_ID = (@TEST ? '348172070947127306'.freeze :  #MinEgenTestserver
                                  '202189706383982605'.freeze)

# The character that all the bot commands must start with.
@BOT_INVOKE_CHARACTER = '!'.freeze

#
# The settings read from the configuration files.
# And other global variables.
#
@BOT_SETTINGS_HASH = {}
@THIS_SERVER_SETTINGS_HASH = {}
@ALL_SERVER_SETTINGS_HASH = {}

# The Discord Bot object
@BOT_OBJ = nil

# Hash containing user ids and when they last issued a bot command that shouldn't be spammed.
@USER_PERMISSION_CHANGES = {}

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

  file_contents = File.read('./bot_settings.json')
  @BOT_SETTINGS_HASH = JSON.parse(file_contents)

  file_contents = File.read('./server_settings.json')
  @ALL_SERVER_SETTINGS_HASH = JSON.parse(file_contents)

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
def add_role_to_user event_obj, single_permission_role_hash
  Debug.trace if @DEBUG
  returnval = true

  user_hash = get_user_from_event event_obj
  server_hash = get_server_from_event event_obj

  event_obj.server.member(user_hash[:id]).add_role(single_permission_role_hash[:obj])
  @BOT_OBJ.send_message(server_hash[:role_spam_channel_id],
    'Added the ' + single_permission_role_hash[:name] + ' role to you, ' + user_hash[:mention])

  return returnval
end



# Remove a role from a user.
# @param [EventObject]
# @param [PermissionRoleHash]
# @return [true]
def remove_role_from_user event_obj, single_permission_role_hash
  Debug.trace if @DEBUG
  returnval = true

  user_hash = get_user_from_event event_obj
  server_hash = get_server_from_event event_obj

  event_obj.server.member(user_hash[:id]).remove_role(single_permission_role_hash[:obj])
  @BOT_OBJ.send_message(server_hash[:role_spam_channel_id],
    'Removed the ' + single_permission_role_hash[:name] + ' role from you, ' + user_hash[:mention])

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
            remove_role_from_user event_obj, server_roles_hash[role_name]
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



# Print outs a message when a new user joins the server.
# @param [EventObject]
# @return [true]
def member_join event_obj
  Debug.trace if @DEBUG

  user_hash = get_user_from_event event_obj
  server_hash = get_server_from_event event_obj

  @BOT_OBJ.send_message(server_hash[:default_channel_id],
    'Hei ' + user_hash[:mention] + ' og velkommen til **' + server_hash[:servername] + '**!' +"\n"+
    'Feel free to assign yourself an applicable role by typing `!beginner`, `!intermediate`, or `!native`.' +"\n"+
    'We hope you enjoy your stay.' +"\n"+
    '*(Id: ' + user_hash[:id] + ')*')

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
    user_hash[:mention] + ' forlot nettopp serveren. Adjø og ha det bra, **' + user_hash[:nick] + '**!' +"\n"+
    '*(Id: ' + user_hash[:id] + ')*')

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
    'Source code for the bot can (soon) be found at:' +"\n"+
    '  https://github.com/Brukarnamn/Bifrost' +"\n"+
    @BOT_COMMANDS_LIST+
    'In loving memory of **Askeladden** (2016-2017). Hvil i fred. :sob:'

  return true
end  



# Check what the user typed as a simple one-word command and do appropriately.
# @param [EventObject]
# @return [true]
def handle_simple_messages event_obj
  Debug.trace if @DEBUG

  command_hash = get_message_from_event event_obj
  user_hash = get_user_from_event event_obj
  #channel_hash = get_channel_from_event event_obj

  text_command = command_hash[:text]
  case text_command
  when 'PING'
    event_obj.respond 'Pong ' + user_hash[:mention] + '! *(Id = ' + user_hash[:id] + ')*'
  when 'HELP'
    show_help_text event_obj
  when 'BEGINNER', 'INTERMEDIATE',
    'NATIVE', 'NORSK',
    'SVENSK', 'DANSK', 'DANSKER'
    change_role_permission_on_user event_obj, @USER_ROLE_COMMANDS[text_command], true
  when 'ADVANCED'
    event_obj.respond 'Dette nivået må du spørre en moderator om, ' + user_hash[:mention]
  when 'NSFW', 'COMP'
    #change_simple_permission_on_user event_obj, @USER_ROLE_COMMANDS[text_command]
    change_role_permission_on_user event_obj, @USER_ROLE_COMMANDS[text_command]
  when 'CHANNELINFO'
    output_server_and_channel_info event_obj
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

  bot_command_regexp_roles = (@BOT_INVOKE_CHARACTER+'[a-zA-Z]+').freeze
  @BOT_OBJ.message(exact_text: %r{^#{bot_command_regexp_roles}$}) do |event_obj|
    handle_simple_messages event_obj
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



