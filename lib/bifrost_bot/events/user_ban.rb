# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a user is banned from a server.
    #
    # user_ban(attributes = {}) {|event| ... } ⇒ UserBanEventHandler
    #
    module UserBanEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/UserBanEvent
      user_ban do |event_obj|
        #puts Debug.msg('----------UserBanEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        # Nah, don't need to store this.
        #helper_obj.write_user_event_to_db(BOT_CONFIG.db_message_banned)

        server_id = helper_obj.server_id
        target_id = helper_obj.user_id

        BOT_CACHE.add_user_ban(server_id, target_id)

        #     :audit_id => 500120473875513344,
        #  :action_type => 22,
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
        audit_data_hash = helper_obj.fetch_ban_audit_log_info(target_id)
        #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(audit_data_hash, 0, false)

        next if audit_data_hash.nil?

        # Find out who banned and why.
        moduser_obj = BOT_CACHE.get_server_user(server_id, audit_data_hash[:user_id])
        #moduser_short_str = moduser_obj.distinct.to_s
        moduser_short_str = +'**' << moduser_obj.username.to_s << '**#' << moduser_obj.discriminator.to_s
        ban_reason = audit_data_hash[:reason] || '...'

        moduser_short_str = +'**' << BOT_CONFIG.bot_identity << '**' if moduser_obj.id == BOT_CONFIG.client_id

        #config_str = +'**BANNED**: User ' << helper_obj.user_id.to_s << ' → ' << helper_obj.user_distinct <<
        #             (helper_obj.user_nick.empty? ? '' : +' → ' << helper_obj.user_nick)
        config_str = BOT_CONFIG.bot_event_responses[:user_ban]
        config_str = helper_obj.substitute_event_vars(config_str, moduser_short_str, ban_reason)

        #if helper_obj.url_username?
        #  config_str = BOT_CONFIG.moderator_ping + "\n" + config_str
        #  BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)
        #else
        #  BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, config_str)
        #end
        BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, config_str)
        BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, config_str)

        # Fetch the last N messages that were not deleted less than 2 seconds ago.
        last_user_messages_hash = helper_obj.fetch_user_messages
        #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(last_user_messages_hash, 0, false) if BOT_CONFIG.debug_spammy

        # Create a discord embed of the deleted messages.
        delete_header_str = BOT_CONFIG.bot_event_responses[:user_messages]
        delete_header_str = helper_obj.substitute_event_vars(delete_header_str, BOT_CONFIG.user_ban_show_messages_count)

        embed_data_hash = {
          title:  delete_header_str,
          fields: []
        }

        last_user_messages_hash.each_key do |channel_id|
          last_user_messages_hash[channel_id].each do |_message_id, message_value|
            mobj_message = helper_obj.create_string_from_discord_message(message_value[:message], message_value[:files], nil)
            next if mobj_message.nil_or_empty?

            mobj_message.truncate_words(1017) if mobj_message.length > 1017
            mobj_message = +'__**In ** <#' << channel_id.to_s << '>' << "__:\n" << mobj_message

            is_edited = !message_value[:edited_at].nil_or_empty?
            is_edited_utc = is_edited ? message_value[:edited_at] : ''

            field = {
              name:  +'━━━ ' << message_value[:created_at].to_s << '' <<
                     (is_edited ? (+' (Edited: ' << is_edited_utc.to_s << ')') : '') <<
                     ' ━━━ ',
              value: (mobj_message.empty? ? '.' : mobj_message) # To prevent Discord's automatic join messages (which are server made) to cause bugs.
            }
            embed_data_hash[:fields].push(field)
          end
        end

        helper_obj.channel_respond_with_embed(BOT_CONFIG.audit_spam_mod_channel_id, embed_data_hash)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #UserBanEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  #server ⇒ Server readonly
    The server from which the user was banned.

  #user ⇒ User readonly
    The user that was banned.

  Attributes inherited from Event
    #bot
=end
=begin
  2017-11-21 16:11:27.409 websocket        ← {"t"=>"GUILD_BAN_ADD", "s"=>6, "op"=>0, "d"=>{
    "user"=>{
      "username"=>"TestBot",
      "id"=>"123456789012345678",
      "discriminator"=>"6556",
      "avatar"=>nil},
    "guild_id"=>"123456789012345678"}}
  2017-11-21 16:11:27.412 websocket        ← {"t"=>"GUILD_MEMBER_REMOVE", "s"=>7, "op"=>0, "d"=>{"user"=>{"username"=>"TestBot", "id"=>"123456789012345678", "discriminator"=>"6556", "avatar"=>nil}, "guild_id"=>"123456789012345678"}}
  2017-11-21 16:11:27.415 websocket        ← {"t"=>"PRESENCE_UPDATE", "s"=>8, "op"=>0, "d"=>{"user"=>{"id"=>"123456789012345678"}, "status"=>"offline", "roles"=>[], "guild_id"=>"123456789012345678", "game"=>nil}}
  2017-11-21 16:11:27.430 websocket        ← {"t"=>"MESSAGE_DELETE_BULK", "s"=>9, "op"=>0, "d"=>{"ids"=>["382522334080139265", "382544221594451989", "382547735783538688"], "channel_id"=>"348172071412563971"}}
  2017-11-21 16:11:27.432 websocket        ← {"t"=>"MESSAGE_DELETE_BULK", "s"=>10, "op"=>0, "d"=>{"ids"=>["382524785168744449", "382525834541662209", "382540276184645632", "382542701197000704"], "channel_id"=>"363718468421419008"}}

  #<Discordrb::Events::UserBanEvent:0x00000000036d8708
=end
