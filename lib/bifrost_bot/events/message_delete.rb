# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a message is deleted in a channel.
    #
    # message_delete(attributes = {}) {|event| ... } ⇒ MessageDeleteEventHandler
    #
    module MessageDeleteEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/MessageDeleteEvent
      message_delete do |event_obj|
        #puts Debug.msg('----------MessageDeleteEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        deleted_rows_arrayhash = helper_obj.delete_message_from_db

        # Skip everything else if it is a private message to the bot.
        # Could technically still show the message without showing user and channel ... But, no.  Uninteresting and spammy.
        #
        #return if is_private_message  # Exception: #<LocalJumpError: unexpected return>
        #break if is_private_message   # Exception: #<LocalJumpError: break from proc-closure>
        if helper_obj.is_private_message
          puts Debug.msg(+'PRIVATE message-id: ' << helper_obj.message_id.to_s << ' was deleted. ' \
                         ' Channel-id-name: ' << helper_obj.channel_id.to_s << ' = ' << helper_obj.channel_name.to_s << '')
          next
        end

        #is_private_message = false
        is_bot_message      = false
        is_user_own_message = false
        is_user_banned      = false

        datetime = '?'
        server_id  = helper_obj.server_id
        channel_id = helper_obj.channel_id
        message_id = helper_obj.message_id
        target_user_id = nil
        files = nil

        i = 1
        embed_data_hash = {
          fields: []
        }

        # Is the database guaranteed to return the rows in the same way as they were added?
        # Need to search the documentation. But seems to be for the sporadic use here...
        #
        # sql = 'SELECT "rowid", "server_id", "channel_id", "user_id", "is_private_msg", "message", "files", "created_at", "edited_at" '
        #
        deleted_rows_arrayhash.each do |data_row|
          #{
          #  rowid:          1234,
          #  message_id:     987654321098765432,
          #  channel_id:     123456789012345678,
          #  user_id:        123456789012345678,
          #  is_private_msg: false,
          #  message:        'testest setest',
          #  files:          '',
          #  created_at:     '2018-10-11 19:30:37.477',
          #  edited_at:      nil
          #}
          #Debug.pp data_row if BOT_CONFIG.debug_spammy

          if i <= 1
            datetime = data_row[:created_at].to_s
            #server_id = data_row[:server_id]
            #channel_id = data_row[:channel_id]
            target_user_id = data_row[:user_id]
            files = data_row[:files]

            target_user_obj = BOT_CACHE.get_server_user(server_id, target_user_id)

            #is_private_message  = true if data_row[:is_private_msg] || server_id.nil? || !server_id.positive?
            #is_bot_message      = target_user_id == BOT_CONFIG.client_id
            is_bot_message      = target_user_obj.bot_account
            is_user_own_message = (target_user_id == helper_obj.user_id)
            is_user_banned      = helper_obj.user_banned?(target_user_id)
          end

          # Don't create a discord embed if it is never going to be shown.
          # So stop the loop.
          #return if it was made by the bot itself. # Exception: #<LocalJumpError: unexpected return>
          #return if it was made by the user that deleted it.
          #return if the user is banned - show the deleted messages in the ban event. # Exception: #<LocalJumpError: unexpected return>
          break if is_bot_message
          break if is_user_own_message || is_user_banned

          # The max length of a value string inside an embed field is 1024 characters.
          # Allow for possibly 7 characters of [. . .]
          message ||= data_row[:message] || ''
          message = message.truncate_words(1017)
          is_edited = !data_row[:edited_at].nil_or_empty?
          is_edited_utc = is_edited ? data_row[:edited_at].to_s : ''

          field = {
            name:  +'━━━ ' <<
                   i.to_s << ' (' << (is_edited ? (+'edit ' << is_edited_utc) : 'original message') <<
                   ') ━━━ ',
            value: (message.empty? ? '.' : message) # To prevent Discord's automatic join messages (which are server made) to cause bugs.
          }
          embed_data_hash[:fields].push(field)

          i += 1
        end
        #loop deleted_rows_arrayhash

        # Fetch the last audit log entries.
        audit_data_hash = helper_obj.fetch_msg_delete_audit_log_info(channel_id, message_id)
        #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(audit_data_hash, 0, false)

        # Skip the rest if it was the bot itself that made the message.
        #return # Exception: #<LocalJumpError: unexpected return>
        if is_bot_message
          puts Debug.msg(+'BOT message-id: ' << message_id.to_s << ' was deleted. User-id: ' << target_user_id.to_s << '')
          next
        end

        # If the audit log doesn't show any entries where the user matches for the last entries, then assume the user deleted their own message.
        if !audit_data_hash.nil? && audit_data_hash.key?(message_id)
          deleted_audit_data_hash = audit_data_hash[message_id]

          deleted_by_id = deleted_audit_data_hash[:user_id]
          deleted_by_user_obj = BOT_CACHE.get_server_user(server_id, deleted_by_id)

          #deleted_by_distinct = deleted_by_user_obj.distinct
          deleted_by_distinct = +'**' << deleted_by_user_obj.username.to_s << '**#' << deleted_by_user_obj.discriminator.to_s
        else
          is_user_own_message = true

          #deleted_by_id = target_user_id
          deleted_by_distinct = is_user_banned ? '**<ban delete>**' : '**<self>**'
        end

        # If it is banned messages deletion, then ignore them to avoid too much spam.
        # Instead they will be shown through the ban-event if wanted.
        #return # Exception: #<LocalJumpError: unexpected return>
        if is_user_own_message && is_user_banned
          puts Debug.msg(+'OWN USER message-id: ' << message_id.to_s << ' was deleted. User-id: ' << target_user_id.to_s << ' (ban ignored)')
          next
        end

        missing_data = false
        if server_id.nil? || channel_id.nil? || target_user_id.nil?
          missing_data = true

          target_user_id    = '?'
          user_str          = '?'
          user_short_str    = '**?**'
          channel_str       = '?'
          channel_short_str = '?'
        else
          target_user_obj   = BOT_CACHE.get_server_user(server_id, target_user_id)
          channel_obj = BOT_OBJ.channel(channel_id, server_id)

          target_user_id    = target_user_id.to_s
          user_str          = (+'' << target_user_obj.mention << ' (' << target_user_obj.distinct << ' = ' << target_user_obj.id.to_s << ')')
          #user_short_str   = user_obj.distinct.to_s
          user_short_str    = (+'**' << target_user_obj.username << '**#' << target_user_obj.discriminator.to_s)
          channel_str       = (+'' << channel_obj.mention << ' (' << channel_obj.id.to_s << ')')
          channel_short_str = channel_obj.mention.to_s
        end

        delete_short_str = BOT_CONFIG.bot_event_responses[:message_delete]
        delete_short_str = helper_obj.substitute_event_vars(delete_short_str, channel_short_str, target_user_id, user_short_str, deleted_by_distinct.to_s)

        # Ignore the contents if it was the user itself that deleted the message.
        # But show a message that something was deleted.
        if is_user_own_message && !is_user_banned
          puts Debug.msg(+'OWN USER message-id: ' << message_id.to_s << ' was deleted. User-id: ' << target_user_id.to_s << '')

          # Show a message in the mod log that the user deleted their own message.
          BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, delete_short_str)

        # Internal error. This should have been caught earlier.
        elsif is_user_own_message && is_user_banned
          puts Debug.error(+'BANNED & OWN USER message-id: ' << message_id.to_s << ' was deleted. User-id: ' << target_user_id.to_s << '')

        # Otherwise show a message.
        # Someone (hopefully a moderator) deleted a message created by someone else. So show what was deleted.
        else
          puts Debug.msg(+'User MESSAGE-id: ' << message_id.to_s << ' was deleted. User-id: ' << target_user_id.to_s << '')

          if !files.nil? && !files.empty?
            field = { name:  'Attachments:',
                      value: files }
            embed_data_hash[:fields].unshift(field)
          end

          #embed_data_hash[:content] = +'User-id: ' << target_user_id.to_s << ''
          #embed_data_hash[:title] = +'Message ' << message_id.to_s << ' was DELETED by ' << deleted_by_distinct.to_s << ''
          embed_data_hash[:title] = +'Message was DELETED by ' << deleted_by_distinct.to_s << ''
          embed_data_hash[:description] = [+'**In channel**: ' << channel_str,
                                           +'**Written by**: ' << user_str,
                                           +'**First written**: ' << datetime]
          embed_data_hash[:description].push("Unfortunately I can't remember the contents.") if missing_data

          helper_obj.channel_respond_with_embed(BOT_CONFIG.audit_spam_mod_channel_id, embed_data_hash)
          #BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id,
          #                     ['Noen slettet meldingen... :thinking:',
          #                      +'Channel: ' << channel_str,
          #                      +'User: ' << user_str].join("\n") << "\n" <<
          #                     response_str.join("\n"))

          BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, delete_short_str)
        end
        #if

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #MessageDeleteEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  Attributes inherited from MessageIDEvent
    #id

  Attributes included from Respondable
    #channel

  Attributes inherited from Event
    #bot

  Method Summary
  ==============

  Methods included from Respondable
    #<<, #drain, #drain_into, #send_embed, #send_message, #send_temporary_message
=end
=begin
  2017-11-21 15:44:05.021 websocket        ← {"t"=>"MESSAGE_DELETE", "s"=>10, "op"=>0, "d"=>{
    "id"=>"987654321098765432",
    "channel_id"=>"123456789012345678"}}

  2017-11-21 16:11:27.430 websocket        ← {"t"=>"MESSAGE_DELETE_BULK", "s"=>9, "op"=>0, "d"=>{"ids"=>["382522334080139265", "382544221594451989", "382547735783538688"], "channel_id"=>"123456789012345678"}}
  2017-11-21 16:11:27.432 websocket        ← {"t"=>"MESSAGE_DELETE_BULK", "s"=>10, "op"=>0, "d"=>{"ids"=>["382524785168744449", "382525834541662209", "382540276184645632"], "channel_id"=>"123456789012345678"}}

  #<Discordrb::Events::MessageDeleteEvent:0x000000000427f868
=end
