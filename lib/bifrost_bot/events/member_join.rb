# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a new user joins a server.
    #
    # member_join(attributes = {}) {|event| ... } ⇒ ServerMemberAddEventHandler
    #
    module ServerMemberAddEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/ServerMemberAddEvent
      member_join do |event_obj|
        #puts Debug.msg('----------ServerMemberAddEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        user_nicknames_hash = BOT_CACHE.get_user_nicknames(helper_obj.server_id, helper_obj.user_id)
        #Debug.pp user_nicknames_hash
        #{
        #  :user_id => 1234567890123456789,
        #  :username => nil,
        #  :nicknames => [  ]
        #}
        new_user = user_nicknames_hash[:username].nil_or_empty?

        # Store that the user has joined in the database.
        user_exists_already = helper_obj.update_user_joined
        helper_obj.write_user_event_to_db(BOT_CONFIG.db_message_join)

        Debug.internal('BRAINFART! User bot does not and does exist at the same time.') if new_user == user_exists_already

        # Update the user object in the cache.
        BOT_CACHE.update_users_cache_with_user helper_obj.create_user_helper_obj

        # Hi @user (id: 1234567890123456789) and welcome to this server for **Norwegian language learning** and practice!
        # To show others your Norwegian proficiency level you can assign a role by typing !beginner, !intermediate, or !native.
        # Please see the #welcome channel for some basic information. We hope you enjoy your stay.
        #
        #config_str = +'Hei, ' << helper_obj.user_mention << ' (id: *' << helper_obj.user_id.to_s << '*) ' \
        #             'og velkommen til **' << helper_obj.server_name << '** !' << "\n" \
        #             'We hope you enjoy your stay – Vi håper du vil trives her.'
        if helper_obj.url_username?
          config_str = BOT_CONFIG.bot_event_responses[:member_join_mod]
          config_str = helper_obj.substitute_event_vars config_str

          config_str = BOT_CONFIG.moderator_ping + "\n" + config_str
          BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)
        else
          config_str = if new_user
                         BOT_CONFIG.bot_event_responses[:member_join]
                       else
                         BOT_CONFIG.bot_event_responses[:member_rejoin]
                       end
          #
          config_str = helper_obj.substitute_event_vars config_str
          BOT_OBJ.send_message(BOT_CONFIG.default_channel_id, config_str)
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #ServerMemberAddEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  Attributes inherited from ServerMemberEvent
    #roles, #server, #user

  Attributes inherited from Event
    #bot


  Method Summary
  ==============

  Methods inherited from ServerMemberEvent
    #initialize
=end
=begin
  2017-11-21 16:08:08.295 websocket        ← {"t"=>"GUILD_MEMBER_ADD", "s"=>3, "op"=>0, "d"=>{
    "user"=>{
      "username"=>"Testbot",
      "id"=>"123456789012345678",
      "discriminator"=>"6556",
      "avatar"=>nil},
    "roles"=>[],
    "mute"=>false,
    "joined_at"=>"2017-11-21T15:08:07.592974+00:00",
    "guild_id"=>"123456789012345678",
    "deaf"=>false}}
  2017-11-21 16:08:08.301 websocket        ← {"t"=>"MESSAGE_CREATE", "s"=>4, "op"=>0, "d"=>{ ... }
  2017-11-21 16:08:09.801 websocket        ← {"t"=>"PRESENCE_UPDATE", "s"=>5, "op"=>0, "d"=>{"user"=>{"username"=>"Testbot", "id"=>"123456789012345678", "discriminator"=>"6556", "avatar"=>nil}, "status"=>"online", "roles"=>[], "nick"=>nil, "guild_id"=>"123456789012345678", "game"=>nil}}

  #<Discordrb::Events::ServerMemberAddEvent
=end
