# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a user's status (online/offline/idle) changes.
    #
    # presence(attributes = {}) {|event| ... } ⇒ PresenceEventHandler
    #
    module PresenceUpdateEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/PresenceEvent
      presence do |event_obj|
        #puts Debug.msg('----------PresenceUpdateEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        # Fetch the old user object in the cache.
        # and create a new one.
        user_id = helper_obj.user_id
        old_user_obj = BOT_CACHE.users[user_id]
        new_user_obj = helper_obj.create_user_helper_obj

        #return nil # Exception: #<LocalJumpError: unexpected return>
        next if old_user_obj.nil?

        # This event object returns a user-object, not a member-object, so has less information.
        # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/User
        # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Member
        #Debug.pp old_user_obj
        #Debug.pp new_user_obj

        # Because of this...
        # ... copy over some of the old data into the new one object.
        helper_obj.user_roles = new_user_obj.roles = old_user_obj.roles
        helper_obj.user_nick = new_user_obj.nick = old_user_obj.nick
        new_user_obj.joined_at = old_user_obj.joined_at

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
        # "nick": "nøff",
        # "roles": {
        #   361455803594571778: "TE",
        #   497818068001751051: "KAFFE"
        # },
        # "joined_at": "2018-10-04 23:41:20 +0000"
        change_type = nil

        # Show the user's nickname if it is not empty.
        if new_user_obj.nick.nil_or_empty?
          addon_str = ''
        else
          addon_str = BOT_CONFIG.bot_event_responses[:user_has_nick]
          addon_str = helper_obj.substitute_event_vars(addon_str)
        end

        # The PresenceEvent is not triggered when changing
        # - nick  -> MemberUpdateEvent
        # - roles -> MemberUpdateEvent

        # The username/discriminator changed.
        if old_user_obj.distinct != new_user_obj.distinct
          change_type = BOT_CONFIG.db_message_user_name

          # Store the change type if it was the username that got changed.
          helper_obj.write_user_event_to_db(change_type)
        end

        # The avatar id changed, which means the avatar picture got changed.
        if old_user_obj.avatar_id != new_user_obj.avatar_id
          # Modify the string with type of changes accordingly.
          if change_type.nil?
            change_type = BOT_CONFIG.db_message_user_avatar
          else
            change_type += '+' + BOT_CONFIG.db_message_user_avatar
          end
        end

        # The user's *Is playing game...* changed.
        # This can get VERY spammy.
        if old_user_obj.game != new_user_obj.game
          puts Debug.msg(BOT_CONFIG.db_message_user_game, 'cyan') if BOT_CONFIG.debug_spammy

          #change_type = BOT_CONFIG.db_message_user_game
        end

        #next if change_type.nil?
        if !change_type.nil?
          # Store the change type. Moved to the if-username-change. Don't need to store avatar or game changes.
          #helper_obj.write_user_event_to_db(change_type)

          #config_str = +'User **' << change_type << '** changed: User ' << helper_obj.user_id.to_s <<
          #             ' → ' << helper_obj.user_distinct <<
          #             (helper_obj.user_nick.empty? ? '' : +' → ' << helper_obj.user_nick)
          if helper_obj.url_username?
            config_str = BOT_CONFIG.bot_event_responses[:presence_update_mod]
            config_str = helper_obj.substitute_event_vars(config_str, change_type.to_s, addon_str)

            config_str = BOT_CONFIG.moderator_ping + "\n" + config_str
            #BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)
          else
            config_str = BOT_CONFIG.bot_event_responses[:presence_update]
            config_str = helper_obj.substitute_event_vars(config_str, change_type.to_s, addon_str)

            #BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, config_str)
          end
          BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #PresenceUpdateEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  #server ⇒ Server readonly
    The server on which the presence update happened.

  #status ⇒ Symbol readonly
    The new status.

  #user ⇒ User readonly
    The user whose status got updated.

  Attributes inherited from Event
    #bot


  Instance Method Summary
  =======================

  #initialize(data, bot) ⇒ PresenceEvent constructor
    A new instance of PresenceEvent.
=end
=begin
  "PRESENCE_UPDATE"
  2017-11-21 17:45:27.455 websocket        ← {"t"=>"PRESENCE_UPDATE", "s"=>3, "op"=>0, "d"=>{"user"=>{"id"=>"123456789012345678"}, "status"=>"idle", "roles"=>["348172825884098561", "361262664510603266", "361262753895415808"], "nick"=>nil, "guild_id"=>"123456789012345678", "game"=>{"type"=>0, "timestamps"=>{"start"=>1511034492689}, "name"=>"Game of Life Editor"}}}
  2017-11-21 17:45:38.206 websocket        ← {"t"=>"PRESENCE_UPDATE", "s"=>4, "op"=>0, "d"=>{"user"=>{"id"=>"123456789012345678"}, "status"=>"online", "roles"=>["348172825884098561", "361262664510603266", "361262753895415808"], "nick"=>nil, "guild_id"=>"123456789012345678", "game"=>{"type"=>0, "timestamps"=>{"start"=>1511034492689}, "name"=>"Game of Life Editor"}}}
  2017-11-21 17:15:45.995 websocket        ← {"t"=>"PRESENCE_UPDATE", "s"=>3, "op"=>0, "d"=>{"user"=>{"id"=>"123456789012345678"}, "status"=>"idle", "roles"=>["348172825884098561", "361262664510603266", "361262753895415808"], "nick"=>nil, "guild_id"=>"123456789012345678", "game"=>{"type"=>0, "timestamps"=>{"start"=>1511034492689}, "name"=>"Game of Life Editor"}}}
  2017-11-22 18:45:08.605 websocket        ← {"t"=>"PRESENCE_UPDATE", "s"=>39, "op"=>0, "d"=>{"user"=>{"id"=>"123456789012345678"}, "status"=>"online", "roles"=>["361262849353318411"], "nick"=>nil, "guild_id"=>"123456789012345678", "game"=>nil}}
  2017-11-21 17:45:27.455 websocket        ← {"t"=>"PRESENCE_UPDATE", "s"=>3, "op"=>0, "d"=>{"user"=>{"id"=>"123456789012345678"}, "status"=>"idle", "role
  2017-11-21 17:45:38.206 websocket        ← {"t"=>"PRESENCE_UPDATE", "s"=>4, "op"=>0, "d"=>{"user"=>{"id"=>"123456789012345678"}, "status"=>"online", "role

  #<Discordrb::Events::PresenceEvent
=end
