# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a user is unbanned from a server.
    #
    # user_unban(attributes = {}) {|event| ... } ⇒ UserUnbanEventHandler
    #
    module UserUnbanEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/UserUnbanEvent
      user_unban do |event_obj|
        #puts Debug.msg('----------UserUnbanEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        # Nah, don't need to store this.
        #helper_obj.write_user_event_to_db(BOT_CONFIG.db_message_unbanned)

        server_id = helper_obj.server_id
        target_id = helper_obj.user_id

        BOT_CACHE.remove_user_ban(server_id, target_id)

        #     :audit_id => 876543210987654321,
        #  :action_type => 23,
        #    :server_id => 123456789012345678,
        #   :channel_id => nil,
        #   :message_id => nil,
        # :repeat_count => nil,
        #      :changes => nil,
        #       :reason => nil,
        #  :target_type => "user",
        #    :target_id => 123456789012345678,
        #      :user_id => 876543210987654321,
        #   :created_at => "2018-10-15 10:08:21 UTC",
        #    :edited_at => "2018-10-15 10:08:22 UTC"
        #
        audit_data_hash = helper_obj.fetch_unban_audit_log_info(target_id)
        #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(audit_data_hash, 0, false)

        next if audit_data_hash.nil?

        # Find out who removed the ban.
        moduser_obj = BOT_CACHE.get_server_user(server_id, audit_data_hash[:user_id])
        #moduser_short_str = moduser_obj.distinct.to_s
        moduser_short_str = +'**' << moduser_obj.username.to_s << '**#' << moduser_obj.discriminator.to_s

        #config_str = +'**UNBANNED**: User ' << helper_obj.user_id.to_s << ' → ' << helper_obj.user_distinct <<
        #             (helper_obj.user_nick.empty? ? '' : +' → ' << helper_obj.user_nick)
        config_str = BOT_CONFIG.bot_event_responses[:user_unban]
        config_str = helper_obj.substitute_event_vars(config_str, moduser_short_str)

        BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, config_str)
        BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #UserUnbanEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  Attributes inherited from UserBanEvent
    #server, #user

  Attributes inherited from Event
    #bot
=end
=begin
  2017-11-21 16:12:32.547 websocket        ← {"t"=>"GUILD_BAN_REMOVE", "s"=>11, "op"=>0, "d"=>{
  "user"=>{
    "username"=>"Testbot",
    "id"=>"123456789012345678",
    "discriminator"=>"6556",
    "avatar"=>nil},
  "guild_id"=>"123456789012345678"}}

  #<Discordrb::Events::UserUnbanEvent
=end
