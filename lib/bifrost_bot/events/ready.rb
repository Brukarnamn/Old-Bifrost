# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when the READY packet is received, i.e. servers and channels have finished initialization.
    # It's the recommended way to do things when the bot has finished starting up.
    #
    # ready(attributes = {}) {|event| ... } ⇒ ReadyEventHandler
    #
    module ReadyEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/ReadyEvent
      ready do #|event_obj|
        #puts Debug.msg('----------ReadyEvent----------')
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        BOT_OBJ.game = BOT_CONFIG.bot_is_playing_game

        servers_hash = BOT_OBJ.servers
        if !servers_hash.key?(BOT_CONFIG.bot_runs_on_server_id)
          Debug.error(+'The bot does not run on the expected server-id: ' << BOT_CONFIG.bot_runs_on_server_id.to_s << ' (from config file).')
          puts(+'Did you mean? ' << servers_hash.keys.join(' | '))
          exit
        end

        channels_array = BOT_OBJ.server(BOT_CONFIG.bot_runs_on_server_id).channels
        channel_ids_array = []
        channels_array.each { |channel_obj| channel_ids_array.push channel_obj.id }

        exit_error = false
        config_channels = [
          { id: BOT_CONFIG.info_channel_id,              config_option: 'info_channel_id' },
          { id: BOT_CONFIG.default_channel_id,           config_option: 'default_channel_id' },
          { id: BOT_CONFIG.role_spam_channel_id,         config_option: 'role_spam_channel_id' },
          { id: BOT_CONFIG.generic_spam_channel_id,      config_option: 'generic_spam_channel_id' },
          { id: BOT_CONFIG.audit_spam_mod_channel_id,    config_option: 'audit_spam_mod_channel_id' },
          { id: BOT_CONFIG.audit_spam_public_channel_id, config_option: 'audit_spam_public_channel_id' },
          { id: BOT_CONFIG.exercises_channel_id,         config_option: 'exercises_channel_id' }
        ]

        config_channels.each do |config_hash|
          if !channel_ids_array.include?(config_hash[:id])
            exit_error = true
            Debug.error(+'This server does not have a channel with id: ' << config_hash[:id].to_s << ' ← `' << config_hash[:config_option] << '` (from config file).')
          end
        end
        exit if exit_error

        BOT_CACHE.initialize_roles_and_users_and_channels

        if BOT_CONFIG.debug_spammy
          Debug.divider "#{__FILE__}, #{__LINE__}"
          Debug.pp BOT_CACHE.role_ids
          #Debug.pp BOT_CACHE.role_names

          #Debug.divider "#{__FILE__}, #{__LINE__}"
          #Debug.pp BOT_CACHE.users

          Debug.divider "#{__FILE__}, #{__LINE__}"
          Debug.pp BOT_CACHE.users_joined
          Debug.pp BOT_CACHE.users_left

          Debug.divider "#{__FILE__}, #{__LINE__}"
        end

        # Setting it again since we probably changed it a little bit in the initialize method.
        BOT_OBJ.game = BOT_CONFIG.bot_is_playing_game

        server_id = BOT_CONFIG.bot_runs_on_server_id
        channel_id = BOT_CONFIG.default_channel_id
        #channel_obj = BOT_OBJ.channel(channel_id, server_id)
        _channel_obj = BOT_OBJ.channel(channel_id, server_id)

        #config_str = +'Oops! I think I fell asleep for a little bit! ' \
        #             'I wonder what I missed... :thinking:')
        config_str = BOT_CONFIG.bot_event_responses[:ready]
        #config_str = helper_obj.substitute_event_vars config_str  # helper_obj not defined (yet)

        Debug.warn 'DISABLED SLEEP MESSAGE if the send_message is commented out! ' + config_str
        #channel_obj.send_message(config_str)

        BOT_CACHE.show_users_that_joined_and_left

        admin_system_code = BOT_CONFIG.bot_system_code
        LOGGER.info 'Bot is finally ready. Starting system code: ' + Debug.msg(admin_system_code)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #ReadyEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  Attributes inherited from Event
    #bot
=end
=begin
  # username: 'Testbot',
  # id: 123456789012345678,
  # discriminator: '1234',
  # avatar: '123456789abcdef123456789abcdef12'}

  helper_obj => {
    "bot_runs_on_server_id": 123456789012345678,
    "bot_invoke_character":  "!",
    "is_private_message":    true,
    "has_server_obj":        nil,
    "server_id":             0,
    "server_name":           "",
    "has_channel_obj":       nil,
    "channel_id":            0,
    "channel_name":          "",
    "channel_type":          0,
    "has_user_obj":          nil,
    "user_id":               0,
    "user_name":             "",
    "user_discriminator":    0,
    "user_distinct":         "",
    "user_mention":          "",
    "user_nick":             "",
    "user_roles":            {},
    "user_joined_at":        "",
    "user_is_bot":           false,
    "user_avatar_id":        "",
    "user_avatar_url":       "",
    "user_game":             "",
    "message_id":            0,
    "message":               "",
    "msg_files":             [],
    "msg_embeds":            [],
    "msg_timestamp":         "",
    "msg_is_edited":         false,
    "edited_timestamp":      "",
    "is_bot_command":        false,
    "command":               "",
    "command_args":          [],
    "uc_command_args":       [],
    "command_args_str":      "",
    "uc_command_args_str":   ""
  }

  2018-10-16 17:09:59.881 main             D WS thread created! Now waiting for confirmation that everything worked
  2018-10-16 17:09:59.882 websocket        D Connecting
  2018-10-16 17:09:59.962 websocket        D Gateway URL: wss://gateway.discord.gg/?encoding=json&v=6
  2018-10-16 17:09:59.990 websocket        D Obtained socket
  2018-10-16 17:10:00.307 websocket        ← {"t"=>nil, "s"=>nil, "op"=>10, "d"=>{"heartbeat_interval"=>41250, "_trace"=>["gateway-prd-main-rp1n"]}}
  2018-10-16 17:10:00.308 websocket        D Hello!
  2018-10-16 17:10:00.309 websocket        D Trace: ["gateway-prd-main-rp1n"]
  2018-10-16 17:10:00.310 websocket        D Session: nil
  2018-10-16 17:10:00.311 websocket        → {"op":2,"d":{"token":"Bot REDACTED_TOKEN","properties":{"$os":"x64-mingw32","$browser":"discordrb","$device":"discordrb","$referrer":"","$referring_domain":""},"compress":false,"large_threshold":100}}
  2018-10-16 17:10:00.533 websocket        ← {"t"=>"READY", "s"=>1, "op"=>0, "d"=>{
    "v"=>6,
    "user_settings"=>{},
    "user"=>{
      "verified"=>true,
      "username"=>"Testbot",
      "mfa_enabled"=>true,
      "id"=>"123456789012345678",
      "email"=>nil,
      "discriminator"=>"1234",
      "bot"=>true,
      "avatar"=>"123456789abcdef123456789abcdef12"},
    "session_id"=>"123456789abcdef123456789abcdef12",
    "relationships"=>[],
    "private_channels"=>[],
    "presences"=>[],
    "guilds"=>[{
      "unavailable"=>true,
      "id"=>"123456789012345678"}],
    "_trace"=>[
      "gateway-prd-main-rp1n",
      "discord-sessions-prd-1-16"]
    }}
  2018-10-16 17:10:00.534 websocket        i Discord using gateway protocol version: 6, requested: 6
  2018-10-16 17:10:00.656 websocket        ← {"t"=>"GUILD_CREATE", "s"=>2, "op"=>0, "d"=>{ ... }}
  2018-10-16 17:10:00.661 websocket        D Raised a Discordrb::Events::ReadyEvent
  2018-10-16 17:10:00.661 websocket        ✓ Ready
  2018-10-16 17:10:00.662 et-1             → {"op":3,"d":{"status":"online","since":0,"game":{"name":"Something something...","url":null,"type":0},"afk":false}}
  2018-10-16 17:10:01.057 main             D Confirmation received! Exiting run.
  2018-10-16 17:10:01.240 main             D Oh wait! Not exiting yet as run was run synchronously.
=end

