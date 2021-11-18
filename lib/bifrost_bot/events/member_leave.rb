# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a member leaves a server.
    #
    # member_leave(attributes = {}) {|event| ... } ⇒ ServerMemberDeleteEventHandler
    #
    module ServerMemberDeleteEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/ServerMemberDeleteEvent
      member_leave do |event_obj|
        #puts Debug.msg('----------ServerMemberDeleteEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        # Store that the user has joined in the database.
        helper_obj.update_user_left
        helper_obj.write_user_event_to_db(BOT_CONFIG.db_message_leave)

        server_id = helper_obj.server_id
        target_id = helper_obj.user_id

        # Fetch all the previous usernames and nicknames stored in the database for this user.
        user_nicknames_hash = BOT_CACHE.get_user_nicknames(server_id, target_id)
        user_nicknames_array = []
        user_nicknames_hash[:nicknames].each { |nickname| user_nicknames_array.push('**' + nickname + '**') }
        user_nicknames_str = user_nicknames_array.join ', '

        # \nAndre tidligere navn: ##LOCAL_EVENT_STRING##
        if user_nicknames_str.length.positive?
          previous_nicks_str = BOT_CONFIG.bot_event_responses[:user_nicks_loc]
          previous_nicks_str = helper_obj.substitute_event_vars(previous_nicks_str, user_nicknames_str)
        else
          previous_nicks_str = ''
        end

        #config_str = +'**' << helper_obj.username << '** ' << (helper_obj.user_nick.empty? ? '' : +'(a.k.a. ' << helper_obj.user_nick << ') ') <<
        #             'forlot nettopp serveren. ' \
        #             'Adjø og ha det bra, **' << helper_obj.username << '** !' << "\n" \
        #             '(Id: *' << helper_obj.user_id.to_s << '*)'
        if helper_obj.url_username?
          config_str = BOT_CONFIG.bot_event_responses[:member_leave_mod]
          config_str = helper_obj.substitute_event_vars(config_str)

          BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)
        else
          config_str = BOT_CONFIG.bot_event_responses[:member_leave]
          config_str = helper_obj.substitute_event_vars(config_str, previous_nicks_str)

          BOT_OBJ.send_message(BOT_CONFIG.default_channel_id, config_str)
        end

        # If the user got banned an UserBanEvent got triggered.
        # But there is no event for Kick.
        # So check the audit log to see if the user left on their own,
        # or the user got kicked.

        #     :audit_id => 500120473875513344,
        #  :action_type => 20,
        #    :server_id => 123456789012345678,
        #   :channel_id => nil,
        #   :message_id => nil,
        # :repeat_count => nil,
        #      :changes => nil,
        #       :reason => "Tralalalalaatestsetsetset",
        #  :target_type => "user",
        #    :target_id => 123456789012345678,
        #      :user_id => 876543210987654321,
        #   :created_at => "2018-10-15 10:08:21 UTC",
        #    :edited_at => "2018-10-15 10:08:22 UTC"
        #
        audit_data_hash = helper_obj.fetch_kick_audit_log_info(target_id)
        #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(audit_data_hash, 0, false)

        #return if is_private_message # Exception: #<LocalJumpError: unexpected return>
        #break if is_private_message  # Exception: #<LocalJumpError: break from proc-closure>
        next if audit_data_hash.nil? || !audit_data_hash.length.positive?

        moduser_obj = BOT_CACHE.get_server_user(server_id, audit_data_hash[:user_id])
        #moduser_short_str = moduser_obj.distinct.to_s
        moduser_short_str = +'**' << moduser_obj.username.to_s << '**#' << moduser_obj.discriminator.to_s
        kick_reason = audit_data_hash[:reason] || '...'

        #config_str = +'**KICKED**: User ' << helper_obj.user_id.to_s << ' → ' << helper_obj.user_distinct <<
        #             (helper_obj.user_nick.empty? ? '' : +' → ' << helper_obj.user_nick)
        config_str = BOT_CONFIG.bot_event_responses[:user_kick]
        config_str = helper_obj.substitute_event_vars(config_str, moduser_short_str, kick_reason)

        #if helper_obj.url_username?
        #  config_str = BOT_CONFIG.moderator_ping + "\n" + config_str
        #  BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)
        #else
        #  BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, config_str)
        #end
        BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, config_str)
        BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #ServerMemberDeleteEvent
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


  Instance Method Summary
  =======================

  #init_user(data, bot) ⇒ Object
    Overide init_user to account for the deleted user on the server.

  Methods inherited from ServerMemberEvent
    #initialize
=end
=begin
  2017-11-21 16:11:27.409 websocket        ← {"t"=>"GUILD_BAN_ADD", "s"=>6, "op"=>0, "d"=>{"user"=>{"username"=>"Testbot", "id"=>"123456789012345678", "discriminator"=>"6556", "avatar"=>nil}, "guild_id"=>"123456789012345678"}}
  2017-11-21 16:11:27.412 websocket        ← {"t"=>"GUILD_MEMBER_REMOVE", "s"=>7, "op"=>0, "d"=>{
    "user"=>{
      "username"=>"Testbot",
      "id"=>"123456789012345678",
      "discriminator"=>"6556",
      "avatar"=>nil},
    "guild_id"=>"123456789012345678"}}
  2017-11-21 16:11:27.415 websocket        ← {"t"=>"PRESENCE_UPDATE", "s"=>8, "op"=>0, "d"=>{"user"=>{"id"=>"123456789012345678"}, "status"=>"offline", "roles"=>[], "guild_id"=>"123456789012345678", "game"=>nil}}
  2017-11-21 16:11:27.430 websocket        ← {"t"=>"MESSAGE_DELETE_BULK", "s"=>9, "op"=>0, "d"=>{"ids"=>["382522334080139265", "382544221594451989", "382547735783538688"], "channel_id"=>"348172071412563971"}}
  2017-11-21 16:11:27.432 websocket        ← {"t"=>"MESSAGE_DELETE_BULK", "s"=>10, "op"=>0, "d"=>{"ids"=>["382524785168744449", "382525834541662209", "382540276184645632", "382542701197000704"], "channel_id"=>"363718468421419008"}}

  #<Discordrb::Events::ServerMemberDeleteEvent
=end
