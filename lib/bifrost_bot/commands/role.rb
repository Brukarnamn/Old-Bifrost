# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the various role commands remove/add from a user.
    # Discordrb::Commands::CommandEvent
    module Role
      extend Discordrb::Commands::CommandContainer

      command(:int879173974137803085_role, BOT_CONFIG.bot_command_default_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'role_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:normal_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert ROLE response here.'
        #event_obj.respond 'r Insert ROLE response here.'

        # This method shouldn't really be called at if it was a private message,
        # but just in case there was a brainfart somewhere.
        return nil if helper_obj.is_private_message

        if helper_obj.command == 'ROLE' && helper_obj.uc_command_args_str.empty?
          command_usage_str = BOT_CONFIG.bot_event_responses[:command_usage]
          command_usage_str = helper_obj.substitute_event_vars(command_usage_str, '!role', '!role popcorn')

          #command_list = BOT_CONFIG.role_commands_hash.keys.map { |cmd| "**#{cmd}**" }
          command_list = BOT_CONFIG.role_commands_hash.keys

          response_str = +'' << command_usage_str << "\n" << command_list.join('  ') << ''

          #event_obj.respond(response_str)
          event_obj.channel.send_temporary_message(response_str, 60)

          return nil
        end

        #Debug.pp BOT_CONFIG.role_commands_hash if BOT_CONFIG.debug_spammy
        #Debug.pp BOT_CONFIG.silly_commands_hash if BOT_CONFIG.debug_spammy
        #Debug.pp BOT_CONFIG.silly_regexp_commands_hash if BOT_CONFIG.debug_spammy

        # Check if the user invoked it with
        #   !role popcorn
        # or simply
        #   !popcorn
        #
        command = if helper_obj.command == 'ROLE'
                    helper_obj.uc_command_args[0]
                  else
                    helper_obj.command
                  end
        #

        # Just return if this key does not exist.
        # For example if the user wrote
        #   !role I_WANT_TO_GET_THE_OWNER_ROLE
        if !BOT_CONFIG.role_commands_hash.key?(command)
          response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
          response_str = helper_obj.substitute_event_vars response_str

          event_obj.respond response_str

          return nil
        end

        mapped_role_name = BOT_CONFIG.role_commands_hash[command]

        #event_obj.respond(+'' << command << ' → ' << mapped_role_name << '') if BOT_CONFIG.debug_spammy
        puts(+'' << command << ' → ' << mapped_role_name << '') if BOT_CONFIG.debug_spammy

        changes_to_do = helper_obj.change_server_role_on_user(mapped_role_name)

        puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(changes_to_do, 0, false) if BOT_CONFIG.debug_spammy
        #{
        #  :add_roles => [ 497561484935823390 ],
        #  :remove_roles => [
        #    497561539218505728,
        #    361455813014847488,
        #    361455803594571778
        #  ],
        #  :messages => [
        #    "WARNING: The server has several roles with the name **BOKMÅL**. This needs to be fixed, @&361262780537503755.
        #497561484935823390 → BOKMÅL
        #503134409801728002 → BOKMÅL",
        #    "ERROR: Can't find the role **TESTSETSETSE** which is defined in the configuration file. This needs to be fixed, @&361262780537503755."
        #  ]
        #}
        additional_message_str = changes_to_do[:messages].join "\n"
        add_messages = []
        remove_messages = []

        changes_to_do[:add_roles].each do |add_role_id|
          # Skip if the user already has the role.
          next if helper_obj.user_roles.key?(add_role_id)

          response_str = add_role_to_user(event_obj, helper_obj.user_id, add_role_id)
          puts 'ADD for ' + helper_obj.user_id.to_s + ': ' + add_role_id.to_s + ' → ' + response_str

          add_role_name = BOT_CACHE.role_ids[add_role_id].name
          add_messages.push helper_obj.substitute_event_vars(response_str, add_role_name)
        end

        changes_to_do[:remove_roles].each do |remove_role_id|
          # Skip if the user does not already have the role.
          next if !helper_obj.user_roles.key?(remove_role_id)

          response_str = remove_role_to_user(event_obj, helper_obj.user_id, remove_role_id)
          puts 'REMOVE for ' + helper_obj.user_id.to_s + ': ' + remove_role_id.to_s + ' → ' + response_str

          remove_role_name = BOT_CACHE.role_ids[remove_role_id].name
          remove_messages.push helper_obj.substitute_event_vars(response_str, remove_role_name)
        end

        # If a role added, show it.
        # But also send a temp message about any roles that were deleted.
        if !add_messages.empty?
          add_message_str = +'' << [additional_message_str, add_messages].flatten.join("\n") << ''
          remove_message_str = remove_messages.join("\n")

          #event_obj.respond(add_message_str)
          #event_obj.channel.send_temporary_message(remove_message_str, 60) if !remove_messages.empty?

          BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, add_message_str)
          BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, remove_message_str) if !remove_messages.empty?
        elsif !remove_messages.empty?
          remove_message_str = +'' << [additional_message_str, remove_messages].flatten.join("\n") << ''

          #event_obj.respond(remove_message_str)
          BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, remove_message_str)
        else
          Debug.internal('BRAINFART!? CMD: ' + command + ' → ' + mapped_role_name)
          Debug.pp changes_to_do
          Debug.pp [additional_message_str, add_messages, remove_messages]

          response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
          response_str = helper_obj.substitute_event_vars(response_str)

          additional_message_str = [additional_message_str, 'Configuration error? ' + command + ' → ' + mapped_role_name + "\n" + response_str].join("\n")

          event_obj.respond(+'' << additional_message_str)
          BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, additional_message_str)
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      def self.add_role_to_user(event_obj, user_id, add_role_id)
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        add_role_name = BOT_CACHE.role_ids[add_role_id].uc_name

        # If the bot lacks permissions to change the role.
        # For example missing the actual permission to change member roles,
        # or if it tries to change a role which is placed on a higher level
        # than the bot's own role.
        begin
          event_obj.server.member(user_id).add_role(add_role_id)

          response_str_hash = BOT_CONFIG.bot_event_responses[:role_added]
          response_str = if response_str_hash.key?(add_role_name)
                           response_str_hash[add_role_name]
                         else
                           response_str_hash[:generic]
                         end
          #
        rescue Discordrb::Errors::NoPermission => err
          Debug.error 'MISSING BOT PERMISSIONS: ' + err.message
          response_str = 'Configuration error? ← ' + add_role_name + "\n" + err.message
        end

        #return response_str
        response_str
      end
      #add_role_to_user



      def self.remove_role_to_user(event_obj, user_id, remove_role_id)
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        remove_role_name = BOT_CACHE.role_ids[remove_role_id].uc_name

        # If the bot lacks permissions to change the role.
        # For example missing the actual permission to change member roles,
        # or if it tries to change a role which is placed on a higher level
        # than the bot's own role.
        begin
          event_obj.server.member(user_id).remove_role(remove_role_id)

          response_str_hash = BOT_CONFIG.bot_event_responses[:role_removed]
          response_str = if response_str_hash.key?(remove_role_name)
                           response_str_hash[remove_role_name]
                         else
                           response_str_hash[:generic]
                         end
          #
        rescue Discordrb::Errors::NoPermission => err
          Debug.error 'MISSING BOT PERMISSIONS: ' + err.message
          response_str = 'Configuration error? ← ' + remove_role_name + "\n" + err.message
        end

        #return response_str
        response_str
      end
      #remove_role_to_user

    end
    #module Role
  end
  #module Commands
end
#module BifrostBot
