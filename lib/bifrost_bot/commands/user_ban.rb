# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the ping command.
    # Discordrb::Commands::CommandEvent
    module UserBan
      extend Discordrb::Commands::CommandContainer

      command(:int255038720237542980_ban_user_id, BOT_CONFIG.bot_command_test_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'user_ban_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:normal_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert BAN USER ID response here.'
        #event_obj.respond 'r Insert BAN USER ID response here.'

        # This method shouldn't really be called at if it was a private message,
        # but just in case there was a brainfart somewhere.
        return nil if helper_obj.is_private_message

        Debug.pp(user_roles: helper_obj.user_roles, mod_roles: BOT_CONFIG.moderator_role_ids) if BOT_CONFIG.debug

        if !helper_obj.user_is_server_moderator?
          #response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
          #response_str = helper_obj.substitute_event_vars response_str

          #event_obj.respond response_str
          return nil
        end

        response_array = []

        command_args = helper_obj.command_args_str.split(' ', 2)
        target_user_id = command_args[0]
        ban_reason = command_args[1]
        Debug.pp [target_user_id, ban_reason] if BOT_CONFIG.debug_spammy

        response_array.push '!**banuser** <user_id> <ban_reason>' if ban_reason.nil_or_empty?

        if !target_user_id.nil_or_empty?
          # 123456789012345678
          # <@123456789012345678>
          # <@!123456789012345678>
          user_tagged = target_user_id.match(/^<?@?!?(?<id>[0-9]+)>?$/)
          if user_tagged
            target_user_id = user_tagged[:id]
          else
            response_array.push '<user_id> needs to be a number or <@user_id>-tag. For example 12345 or <\@12345> or @12345.'
          end
        end

        if !response_array.empty?
          event_obj.respond response_array.join("\n")
          return nil
        end

        server_id = helper_obj.server_id
        server_obj = BOT_OBJ.server(server_id)
        response_str = 'Internal error.'

        # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Server#ban-instance_method
        # ban(user, message_days = 0, reason: nil)
        begin
          server_obj.ban(target_user_id, reason: ban_reason)
          response_str = 'Done.'
        rescue Discordrb::Errors::NoPermission => err
          Debug.error 'MISSING BOT PERMISSIONS: ' + err.message
          response_str = err.message
        rescue RestClient::NotFound => err
          Debug.error 'USER NOT FOUND: ' + err.message
          response_str = 'User not found.'

        # This will always be done.
        ensure
          event_obj.respond response_str
        end

        #return nil
        nil
      end

    end
    #module UserBan
  end
  #module Commands
end
#module BifrostBot
