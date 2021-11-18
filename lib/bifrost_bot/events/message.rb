# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a message is sent to a text channel the bot is currently in.
    #
    # message(attributes = {}) {|event| ... } ⇒ MessageEventHandler
    #
    module MessageEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/MessageEvent
      message do |event_obj|
        #puts Debug.msg('----------MessageEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        helper_obj.write_message_to_db

        # Ignore the bot's own messages and any other bots to avoid endless loops.
        #return if is_a_bot_generated_message  # Exception: #<LocalJumpError: unexpected return>
        #break if is_a_bot_generated_message   # Exception: #<LocalJumpError: break from proc-closure>
        next if helper_obj.user_is_bot

        #config_str = 'Kommando: **' + helper_obj.command + '**, tillegg: ' + helper_obj.uc_command_args_str
        #
        #if BOT_CONFIG.debug_spammy && !helper_obj.command.nil_or_empty?
        #  config_str = BOT_CONFIG.bot_event_responses[:message]
        #  config_str = helper_obj.substitute_event_vars(config_str, helper_obj.command, helper_obj.uc_command_args_str)
        #
        #  event_obj.respond config_str
        #end

        is_private_message = helper_obj.is_private_message

        # Update that the server was active.
        if update_user_activity?(helper_obj)
          # If the channel value is nil, it is added just to check and update the activity.
          # Update the activity time, but pretend it was the same user as last time.
          if !BOT_CONFIG.server_activity_channels[helper_obj.channel_id].nil?
            #puts Debug.msg('BLIP! user', 'green')
            BOT_CACHE.update_last_activity(helper_obj.server_id, helper_obj.user_id)
          else
            last_server_activity = BOT_CACHE.last_activity(helper_obj.server_id)
            last_server_activity_user_id = last_server_activity[:user_id]

            #puts Debug.msg('BLIP! pretend it was last user', 'red')
            BOT_CACHE.update_last_activity(helper_obj.server_id, last_server_activity_user_id)
          end
        end

        # Check of the text matches any of the regexpes for illegal/unwanted texts patterns.
        # Do this before the command check to avoid people trying to pass it as a bot command.
        untwanted_text = message_contains_untwanted_text?(helper_obj)
        untwanted_text_from_roleless = message_contains_untwanted_text_from_roleless?(helper_obj)

        if (untwanted_text || untwanted_text_from_roleless) && !helper_obj.user_is_server_moderator?
          begin
            event_obj.channel.delete_message(helper_obj.message_id)

            config_str = BOT_CONFIG.bot_event_responses[:message_delete_mod]
            config_str = helper_obj.substitute_event_vars(config_str)
            #message_str = BOT_CONFIG.moderator_ping + ': ' + config_str + " ```\n" + helper_obj.message + "\n```"

            message_str = ''
            message_str = +'' << BOT_CONFIG.moderator_ping << ': ' if untwanted_text

            message_str += config_str << ' ```' << helper_obj.message << '```'
          rescue Discordrb::Errors::NoPermission => err
            Debug.error 'MISSING BOT PERMISSIONS: ' + err.message
            message_str = 'Delete message: ' + err.message

          # This will always be done.
          ensure
            BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, message_str)
          end
        end

        # Check if the text starts with the bot command/invoke character.
        # All these commands could have been triggered naturally with normal
        # function names, but would like better control and case insensive
        # checks.
        if helper_obj.is_bot_command
          #command_hash = {
          #  command:             helper_obj.command,
          #  command_args:        helper_obj.command_args,
          #  uc_command_args:     helper_obj.uc_command_args, }
          #  command_args_str:    helper_obj.command_args_str,
          #  uc_command_args_str: helper_obj.uc_command_args_str
          #}
          #success = Commands.custom_command_parser(event_obj, is_private_message, command_hash)
          begin
            success = Commands.custom_command_parser(event_obj, is_private_message, helper_obj.command)
          rescue Discordrb::Errors::NoPermission => err
            Debug.error 'MISSING BOT PERMISSIONS: ' + err.message
            message_str = +'**' << helper_obj.command << '**: ' << err.message
            BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, message_str)
          end

          # Respond with an emoji if the command got successfully triggered, and if there happens to be an emoji to respond with.
          # But only if it was not a private message.
          if success && !is_private_message && !BOT_CONFIG.bot_valid_command_emoji.nil_or_empty?
            begin
              event_obj.message.create_reaction BOT_CONFIG.bot_valid_command_emoji
            rescue Discordrb::Errors::NoPermission => err
              Debug.error 'MISSING BOT PERMISSIONS: ' + err.message
              #message_str = 'Command emoji-react: ' + err.message
              #BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, message_str)
            end
          end

          #return # Exception: #<LocalJumpError: unexpected return>
          # Skip doing anything else since it was an attempted command.
          next
        end

        #Debug.pp BOT_CONFIG.role_commands_hash if BOT_CONFIG.debug_spammy
        #Debug.pp BOT_CONFIG.silly_commands_hash if BOT_CONFIG.debug_spammy
        #Debug.pp BOT_CONFIG.silly_regexp_commands_hash if BOT_CONFIG.debug_spammy

        BOT_CONFIG.silly_regexp_commands_hash.each_key do |single_regexp_trigger|
          next if !helper_obj.message.match?(/#{single_regexp_trigger}/i)

          command_hash  = BOT_CONFIG.silly_regexp_commands_hash[single_regexp_trigger]
          command_reply = command_hash[:text]
          time_duration = command_hash[:time]

          if is_private_message || time_duration.negative?
            event_obj << command_reply
          else
            event_obj.send_temporary_message(command_reply, time_duration)
          end

          break
        end

        # Skip doing anything else based on or because of the message
        # if it was sent as a private message.
        #return if is_private_message  # Exception: #<LocalJumpError: unexpected return>
        #break if is_private_message   # Exception: #<LocalJumpError: break from proc-closure>
        next if is_private_message

        if BOT_CONFIG.emoji_react_channels.key?(helper_obj.channel_id)
          reaction_emojis = BOT_CONFIG.emoji_react_channels[helper_obj.channel_id]

          # If a user has blocked the bot or in general anyone you can't react with emojis.
          # Or if the user or channel permission doesn't allow it an exception will be thrown.
          begin
            reaction_emojis.each do |emoji|
              event_obj.message.create_reaction emoji
              sleep 1.1 # discordrb will slow it down appropriately anyway.
            end
          rescue Discordrb::Errors::NoPermission => err
            Debug.error 'MISSING BOT PERMISSIONS: ' + err.message
            message_str = 'Emoji-react: ' + err.message
            BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, message_str)
          end
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      # Update that the server was active if it is one of the channels to check against.
      # - If it was not the bot itself that did the message
      # - If it is not a private message and
      #   if the channel id is in the list of channels to compare against
      # - But if the channel list is empty, consider that to mean all channels should be checked.
      def self.update_user_activity?(helper_obj)
        return false if helper_obj.user_is_bot
        return false if helper_obj.is_private_message
        return false if BOT_CONFIG.server_activity_channels.nil?

        return true if BOT_CONFIG.server_activity_channels.empty?
        return true if BOT_CONFIG.server_activity_channels.key?(helper_obj.channel_id)

        #return false
        false
      end



      def self.message_contains_untwanted_text?(helper_obj)
        return false if helper_obj.is_private_message

        BOT_CONFIG.illegal_messages.each do |single_regexp_trigger|
          return true if helper_obj.message.match?(/#{single_regexp_trigger}/i)
        end

        #return false
        false
      end



      def self.message_contains_untwanted_text_from_roleless?(helper_obj)
        return false if helper_obj.is_private_message
        return false if !helper_obj.user_is_roleless?

        BOT_CONFIG.illegal_messages_roleless.each do |single_regexp_trigger|
          return true if helper_obj.message.match?(/#{single_regexp_trigger}/i)
        end

        #return false
        false
      end

    end
    #MessageEvent
  end
  #module Events
end
#module BifrostBot



=begin
  # Instance Attribute Summary
  ============================

  #author ⇒ Member, User (also: #user) readonly
    Who sent this message.

  #channel ⇒ Channel readonly
    The channel in which this message was sent.

  #content ⇒ String (also: #text) readonly
    The message's content.

  #file ⇒ File readonly
    The file that have been saved by calls to #attach_file and will be sent to Discord upon completion.

  #message ⇒ Message readonly
    The message which triggered this event.

  #saved_message ⇒ String readonly
    The message that has been saved by calls to Respondable#<< and will be sent to Discord upon completion.

  #server ⇒ Server? readonly
    The server where this message was sent, or nil if it was sent in PM.

  #timestamp ⇒ Time readonly
    The time at which the message was sent.

  Attributes inherited from Event
    #bot


  Instance Method Summary
  =======================

  #attach_file(file) ⇒ Object
    Attaches a file to the message event and converts the message into a caption.

  #detach_file ⇒ Object
    Detaches a file from the message event.

  #from_bot? ⇒ true, false
    Whether or not this message was sent by the bot itself.

  #initialize(message, bot) ⇒ MessageEvent constructor
    A new instance of MessageEvent.

  #send_file(file, caption: nil) ⇒ Discordrb::Message
    Sends file with a caption to the channel this message was sent in, right now.

  #voice ⇒ VoiceBot?
    Utility method to get the voice bot for the current server.

  Methods included from Respondable
    #<<, #drain, #drain_into, #send_embed, #send_message, #send_temporary_message
=end
=begin
  2017-11-21 23:52:23.956 websocket        ← {"t"=>"TYPING_START", "s"=>34, "op"=>0, "d"=>{"user_id"=>"123456789012345678", "timestamp"=>1511277992, "channel_id"=>"123456789012345678"}}
  2017-11-21 23:52:24.994 websocket        ← {"t"=>"MESSAGE_CREATE", "s"=>4, "op"=>0, "d"=>{
    "type"=>0,
    "tts"=>false,
    "timestamp"=>"2017-11-21T22:52:24.129000+00:00",
    "pinned"=>false,
    "nonce"=>"987654321098765432",
    "mentions"=>[],
    "mention_roles"=>[],
    "mention_everyone"=>false,
    "id"=>"987654321098765432",
    "embeds"=>[],
    "edited_timestamp"=>nil,
    "content"=>"testtestset setest s et setset st s tes",
    "channel_id"=>"123456789012345678",
    "author"=>{
      "username"=>"Testbot",
      "id"=>"123456789012345678",
      "discriminator"=>"2413",
      "avatar"=>nil},
    "attachments"=>[]}}

  #<Discordrb::Events::MessageEvent:0x000000000480e248
=end
