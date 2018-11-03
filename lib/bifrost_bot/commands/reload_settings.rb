# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the reload of the server configuration files.
    # Discordrb::Commands::CommandEvent
    module ReloadSettings
      extend Discordrb::Commands::CommandContainer

      command(:int422660145997257723_reload_server_configuration_files, BOT_CONFIG.bot_command_default_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'reload_settings_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:normal_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert RELOADSETTINGS response here.'
        #event_obj.respond 'r Insert RELOADSETTINGS response here.'

        # This method shouldn't really be called at if it was a private message,
        # but just in case there was a brainfart somewhere.
        return nil if helper_obj.is_private_message

        if !(helper_obj.user_is_bot_owner? || BOT_CONFIG.check_system_code(helper_obj.command_args_str))
          #response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
          #response_str = helper_obj.substitute_event_vars response_str

          #event_obj.respond response_str
          return nil
        end

        begin
          Debug.clear_messages
          BOT_CONFIG.load_and_reload_configuration
        rescue ConfigurationError => err
          Debug.add_message(err.message)
        end

        Debug.add_message('Done.')

        result_array = Debug.fetch_messages_as_array(2_047, true)
        result_array.each { |single_str| event_obj.respond single_str }

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #module ReloadSettings
  end
  #module Commands
end
#module BifrostBot
