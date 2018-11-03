# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the reload of the server configuration files.
    # Discordrb::Commands::CommandEvent
    module ServerInformation
      extend Discordrb::Commands::CommandContainer

      command(:int321025852557280648_show_server_information, BOT_CONFIG.bot_command_default_attributes) do |event_obj|
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

        #event_obj << '<< Insert SERVERINFO response here.'
        #event_obj.respond 'r Insert SERVERINFO response here.'

        # This method shouldn't really be called at if it was a private message,
        # but just in case there was a brainfart somewhere.
        return nil if helper_obj.is_private_message

        if !(helper_obj.user_is_server_moderator? || helper_obj.user_is_bot_owner?) # !BOT_CONFIG.check_system_code(helper_obj.command_args_str)
          #response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
          #response_str = helper_obj.substitute_event_vars response_str

          #event_obj.respond response_str
          return nil
        end

        server_obj = event_obj.server

        response_array = []
        response_str = +'**Owner**: ' << server_obj.owner.distinct.to_s << "\n" \
                        '**Voice region**: ' << server_obj.region_id << "\n" \
                        '**Features**:' << server_obj.features.join(', ').to_s << "\n" \
                        '**Verification level**: ' << server_obj.verification_level.to_s << "\n" \
                        '**Creation time**: ' << server_obj.creation_time.to_s << "\n"
        #

        # Loop over all the channels and write the channel id and some other information.
        response_str += +"\n" << '__**Channels**__:' << "\n"
        channels_hash = fetch_all_channels_sorted(server_obj)
        #Debug.pp channels_hash

        channels_hash.each do |_position, single_channel_obj|
          #Debug.pp [_position, single_channel_obj.name]
          #next if single_channel_obj.type == 4

          response_str += +'' << single_channel_obj.id.to_s << ' *('
          response_str += case single_channel_obj.type
                          when 0
                            'text'
                          when 1
                            'dm'
                          when 2
                            'voice'
                          when 3
                            'group'
                          when 4
                            'category'
                          else
                            +'**INTERNAL ERROR: ' << single_channel_obj.type.to_s << '**'
                          end
          #
          response_str += +')* → **' << single_channel_obj.name.to_s << '**'
          #
          response_str += +' → user_limit: ' << single_channel_obj.user_limit.to_s if single_channel_obj.type == 2
          response_str += "\n"

          # A channel name can be at most 100 characters. The rest of the text could take up to 50 characters.
          # Discord's max length message is 2_048
          if response_str.length > 2_048 - 150
            response_array.push response_str
            response_str = ''
          end
        end
        #loop channels

        # Loop over all the roles and list role id and some other information.
        response_str += +"\n" << '__**Roles**__:' << "\n"
        roles_hash = fetch_all_roles_sorted(server_obj)
        #Debug.pp roles_hash

        roles_hash.each do |_position, single_role_obj|
          #Debug.pp [_position, single_role_obj.name]

          colour_obj = single_role_obj.colour
          dec_colour = +'' << colour_obj.red.to_s << ',' << colour_obj.green.to_s << ',' << colour_obj.blue.to_s << ''
          hex_colour = format('%02x%02x%02x', colour_obj.red, colour_obj.green, colour_obj.blue)

          response_str += +'' << single_role_obj.id.to_s << ' (#' << hex_colour << ' = ' << dec_colour << ') →' \
                          ' **' << single_role_obj.name << '**'
          #
          if single_role_obj.hoist || single_role_obj.mentionable
            response_str += +' → ' <<
                            (single_role_obj.hoist ? 'hoisted' : '') <<
                            (single_role_obj.hoist && single_role_obj.mentionable ? ', ' : '') <<
                            (single_role_obj.mentionable ? 'mentionable' : '') << ''
            #
          end
          response_str += "\n"

          # A role name can be at most 100 characters. The rest of the text could take up to 70 characters.
          # Discord's max length message is 2_048
          if response_str.length > 2_048 - 170
            response_array.push response_str
            response_str = ''
          end
        end
        #loop roles

        response_array.push response_str
        response_array.each { |response| event_obj.respond response if !response.empty? }

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      def self.fetch_all_channels_sorted(discord_server_obj)
        # [ #<Discordrb::Channel:0x00000000051c46e8>, ... ]
        #channels_array = server_obj.text_channels
        #channels_array = server_obj.voice_channels
        channels_array = discord_server_obj.channels
        channels_hash = {}

        # Sort the categories before the channels inside it.
        # Put voice channels at the end.
        # Put channels outside a category at the top.
        channels_array.each do |single_channel_obj|
          # Sort categories before the channels.
          # Put voice channels at the end.
          category_parent_obj = single_channel_obj.category
          category_parent_key = category_parent_obj.nil? ? '______' : +'c' << category_parent_obj.position.to_s.rjust(5, '_')
          # Since categories do not have a parent:
          category_parent_key = +'c' << single_channel_obj.position.to_s.rjust(5, '_') if single_channel_obj.type == 4

          channel_key = +'' << (single_channel_obj.type == 2 ? 'v' : ' ') <<
                        single_channel_obj.position.to_s.rjust(5, '0') <<
                        (single_channel_obj.type == 4 ? ' ' : '_') << single_channel_obj.type.to_s
          #
          channels_hash["#{category_parent_key},#{channel_key}"] = single_channel_obj
        end
        #Debug.pp channels_hash

        #return channels_hash
        channels_hash.sort.to_h
      end



      def self.fetch_all_roles_sorted(discord_server_obj)
        # [ #<Discordrb::Role:0x0000000005220b00>, ... ]
        roles_array = discord_server_obj.roles
        roles_hash = {}

        # Sort them by their
        roles_array.each do |single_role_obj|
          role_key = +'' << single_role_obj.position.to_s.rjust(5, '0')
          #puts role_key
          roles_hash[role_key] = single_role_obj
        end
        #Debug.pp roles_hash

        # Since the order is from lowest role to highest role, we want to reverse it.
        #return roles_hash
        roles_hash.sort.reverse.to_h
      end

    end
    #module ServerInformation
  end
  #module Commands
end
#module BifrostBot
