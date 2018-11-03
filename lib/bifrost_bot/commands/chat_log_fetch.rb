# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Responds with response time.
    # Discordrb::Commands::CommandEvent
    module FetchChatLog
      extend Discordrb::Commands::CommandContainer

      command(:int843698523271581386_fetch_all_server_messages, BOT_CONFIG.bot_command_complex_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'fetch_chat_log_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:complex_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert FETCH ALL response here.'
        #event_obj.respond 'r Insert FETCH ALL response here.'

        # This method shouldn't really be called at if it was a private message,
        # but just in case there was a brainfart somewhere.
        return nil if helper_obj.is_private_message

        if !BOT_CONFIG.check_system_code(helper_obj.command_args_str)
          #response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
          #response_str = helper_obj.substitute_event_vars response_str

          #event_obj.respond response_str
          return nil
        end

        response_str = 'OK. This will take a ***VERY*** long time to do...'
        BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, response_str)

        number_of_messages_str = helper_obj.fetch_all_server_messages(true)

        BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, number_of_messages_str)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      command(:int420823229203000431_fetch_new_messages, BOT_CONFIG.bot_command_complex_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'fetch_chat_log_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:complex_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert FETCH response here.'
        #event_obj.respond 'r Insert FETCH response here.'

        # This method shouldn't really be called at if it was a private message,
        # but just in case there was a brainfart somewhere.
        return nil if helper_obj.is_private_message

        if !BOT_CONFIG.check_system_code(helper_obj.command_args_str)
          #response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
          #response_str = helper_obj.substitute_event_vars response_str

          #event_obj.respond response_str
          return nil
        end

        response_str = 'OK. This will take a ***VERY*** long time to do...'
        BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, response_str)

        number_of_messages_str = helper_obj.fetch_all_server_messages(false)

        BOT_OBJ.send_message(BOT_CONFIG.audit_spam_mod_channel_id, number_of_messages_str)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #module FetchChatLog
  end
  #module Commands
end
#module BifrostBot
