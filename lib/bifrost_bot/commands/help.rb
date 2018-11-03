# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle display of the HELP texts.
    # Discordrb::Commands::CommandEvent
    module Help
      extend Discordrb::Commands::CommandContainer

      command(:int690284170289163650_help, BOT_CONFIG.bot_command_info_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'help_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:info_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert HELP response here.'
        #event_obj.respond 'r Insert HELP response here.'

        # helper_obj.message.upcase would also contain the starting bot invoke character.
        command_string = (+'' << helper_obj.command << (helper_obj.uc_command_args_str.empty? ? '' : +' ' << helper_obj.uc_command_args_str) << '').upcase
        bot_text_entry = BOT_CONFIG.find_bot_help_entry(command_string)

        bot_texts_hash = BOT_CONFIG.bot_texts
        #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(bot_texts_hash, 0, false) if BOT_CONFIG.debug_spammy

        helper_obj.event_respond_with_embed(event_obj, bot_texts_hash[bot_text_entry]) if bot_text_entry

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #module Help
  end
  #module Commands
end
#module BifrostBot
