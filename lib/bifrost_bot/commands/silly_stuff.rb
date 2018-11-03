# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the commands for the silly and custom responses.
    # Discordrb::Commands::CommandEvent
    module SillyStuff
      extend Discordrb::Commands::CommandContainer

      command(:int957803030189468496_silly_custom_responses, BOT_CONFIG.bot_command_default_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'silly_stuff_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:test_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert SILLYSTUFF response here.'
        #event_obj.respond 'r Insert SILLYSTUFF response here.'

        if helper_obj.command == 'SILLYSTUFF' && helper_obj.uc_command_args_str.empty?
          command_usage_str = BOT_CONFIG.bot_event_responses[:command_usage]
          command_usage_str = helper_obj.substitute_event_vars(command_usage_str, '!sillystuff', '!sillystuff tilt')

          #command_list = BOT_CONFIG.silly_commands_hash.keys.map { |cmd| "**#{cmd}**" }
          command_list = BOT_CONFIG.silly_commands_hash.keys

          response_str = +'' << command_usage_str << "\n" << command_list.join('  ') << ''

          #event_obj.respond(response_str)
          event_obj.channel.send_temporary_message(response_str, 60)

          return nil
        end

        #Debug.pp BOT_CONFIG.role_commands_hash if BOT_CONFIG.debug_spammy
        #Debug.pp BOT_CONFIG.silly_commands_hash if BOT_CONFIG.debug_spammy
        #Debug.pp BOT_CONFIG.silly_regexp_commands_hash if BOT_CONFIG.debug_spammy

        # Check if the user invoked it with
        #   !sillystuff tilt
        # or simply
        #   !tilt
        #
        command = if helper_obj.command == 'SILLYSTUFF'
                    helper_obj.uc_command_args[0]
                  else
                    helper_obj.command
                  end
        #

        # Just return if this key does not exist.
        # For example if the user wrote
        #   !sillystuff I_WANT_SOMETHING_TOO
        return nil if !BOT_CONFIG.silly_commands_hash.key?(command)

        command_reply = BOT_CONFIG.silly_commands_hash[command][:text]
        time_duration = BOT_CONFIG.silly_commands_hash[command][:time]

        # If it is a private message, then show it permanently.
        # And also if the time is negative.
        if helper_obj.is_private_message || time_duration.negative?
          event_obj.respond command_reply
        else
          event_obj.send_temporary_message(command_reply, time_duration)
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #module SillyStuff
  end
  #module Commands
end
#module BifrostBot
