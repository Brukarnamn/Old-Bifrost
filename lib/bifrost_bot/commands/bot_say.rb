# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the reload of the server configuration files.
    # Discordrb::Commands::CommandEvent
    module BotImpersonate
      extend Discordrb::Commands::CommandContainer

      command(:int209410769664380689_impersonate_bot_say, BOT_CONFIG.bot_command_default_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'command_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:normal_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert BOT_IMPERSONATE response here.'
        #event_obj.respond 'r Insert BOT_IMPERSONATE response here.'

        # If the channel is set to nil it should only work as a private message,
        # otherwise it should only work in the specified channel.
        Debug.pp [helper_obj.is_private_message, helper_obj.channel_id, BOT_CONFIG.bot_impersonator_in_channel] if BOT_CONFIG.debug_spammy

        if helper_obj.is_private_message
          return nil if !BOT_CONFIG.bot_impersonator_in_channel.nil?
        else
          return nil if BOT_CONFIG.bot_impersonator_in_channel.nil?
          return nil if BOT_CONFIG.bot_impersonator_in_channel != helper_obj.channel_id
        end

        if !helper_obj.user_is_bot_impersonator?
          #response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
          #response_str = helper_obj.substitute_event_vars response_str

          #event_obj.respond response_str
          return nil
        end

        response_array = []

        command_args = helper_obj.command_args_str.split(' ', 2)
        channel_str = command_args[0]
        message_str = command_args[1]
        Debug.pp [channel_str, message_str] if BOT_CONFIG.debug_spammy

        response_array.push '!**write** <channel_id> <message_string>' if message_str.nil_or_empty?

        if !channel_str.nil_or_empty?
          #target_channel = BOT_OBJ.parse_mention(helper_obj.command_args_str)
          #channel_id = target_channel.id

          # 123456789012345678
          # <#123456789012345678>
          # <#!123456789012345678>
          target_channel = channel_str.match(/^<?#?!?(?<id>[0-9]+)>?$/)

          if target_channel
            channel_id = target_channel[:id]
          else
            response_array.push '<channel_id> needs to be a number or <#channel_id>-tag. For example 12345 or <\#12345> or #12345.'
          end
        end

        if !response_array.empty?
          event_obj.respond response_array.join("\n")
          return nil
        end

        begin
          BOT_OBJ.send_message(channel_id, message_str)
        rescue Discordrb::Errors::NoPermission => err
          Debug.error 'MISSING BOT PERMISSIONS: ' + err.message
          message_str = 'Bot impersonation: ' + err.message
          event_obj.respond message_str
        rescue RestClient::NotFound => err
          Debug.error 'CHANNEL NOT FOUND: ' + err.message
          message_str = 'Channel not found.'
          event_obj.respond message_str
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #module BotImpersonate
  end
  #module Commands
end
#module BifrostBot
