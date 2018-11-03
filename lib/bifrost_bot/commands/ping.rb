# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the ping command.
    # Discordrb::Commands::CommandEvent
    module Ping
      extend Discordrb::Commands::CommandContainer

      command(:int999168740761015147_ping, BOT_CONFIG.bot_command_test_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'ping_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:test_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert PING response here.'
        #event_obj.respond 'r Insert PING response here.'

        # This will not be accurate if the computer's clock is out of sync
        # with the Discord server's clock.
        # "#{((Time.now - event.timestamp) * 1000).to_i}ms."

        reply_str = +'Pong ' << helper_obj.user_mention << '! (Id = ' << helper_obj.user_id.to_s << ')'

        if helper_obj.is_private_message
          event_obj.respond reply_str
        else
          event_obj.channel.send_temporary_message(reply_str, 60)
          #BOT_OBJ.send_message(BOT_CONFIG.audit_summary_spam_channel_id, reply_str)
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      # For commands that gets a normal event object sent the << method works.
      # Why doesn't it work for the commands that get sent a manually made event object... hmm...
      #command(:bleh, BOT_CONFIG.bot_command_test_attributes) do |event_obj|
      #  event_obj << 'Insert BLEH response here.'
      #end

    end
    #module Ping
  end
  #module Commands
end
#module BifrostBot
