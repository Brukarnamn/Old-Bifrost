# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a member update happens.
    #
    # member_update(attributes = {}) {|event| ... } ⇒ ServerMemberUpdateEventHandler
    #
    module ServerMemberUpdateEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/ServerMemberUpdateEvent
      member_update do |event_obj|
        #puts Debug.msg('----------ServerMemberUpdateEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        # Fetch the old user object in the cache.
        # Create a new one with a mix of the new data and some of the old data.
        user_id = helper_obj.user_id
        old_user_obj = BOT_CACHE.users[user_id]
        new_user_obj = helper_obj.create_user_helper_obj

        # The event object returns a member-object, so everything should be the same in the old and the new object.
        # Unless changes happened.
        # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Member

        #Debug.pp old_user_obj
        #Debug.pp new_user_obj

        # Then update the user object in the cache.
        BOT_CACHE.update_users_cache_with_user new_user_obj

        #Debug.divider
        #Debug.pp old_user_obj
        #Debug.pp new_user_obj

        # Can now compare and see what changed between the old and the new user information.
        # "id": 123456789012345678,
        # "username": "Testbot",
        # "discriminator": "2413",
        # "distinct": "Testbot#2413",
        # "mention": "<@123456789012345678>",
        # "avatar_id": "123456789abcdef123456789abcdef12",
        # "avatar_url": "https://cdn.discordapp.com/avatars/123456789012345678/123456789abcdef123456789abcdef12.webp",
        # "game": "",
        # "bot_account": false,
        # "nick": "urgh",
        # "roles": {
        #   361455803594571778: "TE",
        #   497818068001751051: "KAFFE"
        # },
        # "joined_at": "2018-10-04 23:41:20 +0000"
        change_type = nil
        moduser_short_str = nil

        # Show the user's nickname if it is not empty.
        if new_user_obj.nick.nil_or_empty?
          addon_str = ''
        else
          addon_str = BOT_CONFIG.bot_event_responses[:user_has_nick]
          addon_str = helper_obj.substitute_event_vars(addon_str)
        end

        # The ServerMemberUpdateEvent is not triggered when changing
        # - username -> PresenceEvent
        # - avatar   -> PresenceEvent
        # - game     -> ??  # Would be VERY spammy anyway.

        # If the server configuration allows users to change the nick,
        # then the user's server nickname changed.
        if old_user_obj.nick != new_user_obj.nick
          change_type = BOT_CONFIG.db_message_user_nick

          # Store the change type since it is nick change.
          helper_obj.write_user_event_to_db(change_type)

          # Even if the nick is now empty, show (in some way) that it was
          # changed to an empty nick.
          if new_user_obj.nick.nil_or_empty?
            addon_str = BOT_CONFIG.bot_event_responses[:user_has_nick]
            addon_str = helper_obj.substitute_event_vars(addon_str)
          end

          #     :audit_id => 500120473875513344,
          #  :action_type => 24,
          #    :server_id => 123456789012345678,
          #   :channel_id => nil,
          #   :message_id => nil,
          # :repeat_count => nil,
          #      :changes => "NICK|→new nick←|",
          #       :reason => nil,
          #  :target_type => "user",
          #    :target_id => 123456789012345678,
          #      :user_id => 876543210987654321,
          #   :created_at => "2018-10-15 10:08:21 UTC",
          #    :edited_at => "2018-10-15 10:08:22 UTC"
          #
          audit_data_hash = helper_obj.fetch_nick_change_audit_log_info(user_id, new_user_obj.nick)
          #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(audit_data_hash, 0, false)

          # Check if it was the user themselves that changed the nickname, or someone else did it.
          if user_id != audit_data_hash[:user_id]
            moduser_obj = BOT_CACHE.get_server_user(helper_obj.server_id, audit_data_hash[:user_id])
            #moduser_short_str = moduser_obj.distinct.to_s
            moduser_distinct = +'**' << moduser_obj.username.to_s << '**#' << moduser_obj.discriminator.to_s

            moduser_short_str = BOT_CONFIG.bot_event_responses[:user_modchanged]
            moduser_short_str = helper_obj.substitute_event_vars(moduser_short_str, moduser_distinct)
          end
        end

        # The user had a role added or removed.
        # Convert the hash structures to strings and compare.
        if old_user_obj.roles.to_s != new_user_obj.roles.to_s
          # Modify the string with type of changes accordingly.
          if change_type.nil?
            change_type = BOT_CONFIG.db_message_user_roles
          else
            change_type += '+' + BOT_CONFIG.db_message_user_roles
          end
        end

        #next if change_type.nil?
        if !change_type.nil?
          # Store the change type. Moved to the if-nick-change. Don't need to store role changes.
          #helper_obj.write_user_event_to_db(change_type)

          #config_str = +'User **' << change_type << '** changed: User ' << helper_obj.user_id.to_s <<
          #             ' → ' << helper_obj.user_distinct <<
          #             (helper_obj.user_nick.empty? ? '' : +' → ' << helper_obj.user_nick)

          if helper_obj.url_username?
            config_str = BOT_CONFIG.bot_event_responses[:member_update_mod]
            config_str = helper_obj.substitute_event_vars(config_str, change_type, addon_str + moduser_short_str.to_s)

            config_str = BOT_CONFIG.moderator_ping + "\n" + config_str
            #BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)
          else
            config_str = BOT_CONFIG.bot_event_responses[:member_update]
            config_str = helper_obj.substitute_event_vars(config_str, change_type, addon_str + moduser_short_str.to_s)

            #BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, config_str)
          end
          BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #ServerMemberUpdateEvent
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
  {"id": 123456789012345678,
  "username": "Testbot",
  "discriminator": "6556",
  "distinct": "Testbot#6556",
  "mention": "<@123456789012345678>",
  "avatar_id": "123456789abcdef123456789abcdef12",
  "avatar_url": "https://cdn.discordapp.com/avatars/123456789012345678/123456789abcdef123456789abcdef12.webp",
  "game": "",
  "nick": "æøåøæ",
  "role_ids": [  ],
  "role_names": [  ],
  "joined_at": "2017-11-27 13:07:53 +0000"}

  2017-11-21 17:01:55.078 websocket        ← {"t"=>"PRESENCE_UPDATE", "s"=>3, "op"=>0, "d"=>{ ... }

  2017-11-21 16:17:54.788 websocket        ← {"t"=>"GUILD_MEMBER_UPDATE", "s"=>16, "op"=>0, "d"=>{
    "user"=>{
      "username"=>"Testbot",
      "id"=>"123456789012345678",
      "discriminator"=>"6556",
      "avatar"=>nil},
    "roles"=>[
      "361262849353318411"],
    "nick"=>nil,
    "guild_id"=>"123456789012345678"}}
  2017-11-21 16:17:56.789 websocket        ← {"t"=>"GUILD_MEMBER_UPDATE", "s"=>17, "op"=>0, "d"=>{"user"=>{"username"=>"Testbot", "id"=>"123456789012345678", "discriminator"=>"6556", "avatar"=>nil}, "roles"=>["361262753895415808", "361262849353318411"], "nick"=>nil, "guild_id"=>"123456789012345678"}}

  #<Discordrb::Events::ServerMemberUpdateEvent
=end
