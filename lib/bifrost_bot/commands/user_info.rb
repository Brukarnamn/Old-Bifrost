# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the reload of the server configuration files.
    # Discordrb::Commands::CommandEvent
    module UserInfo
      extend Discordrb::Commands::CommandContainer

      command(:int707750744596935852_show_user_info, BOT_CONFIG.bot_command_default_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'user_info_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:complex_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert USER INFO response here.'
        #event_obj.respond 'r Insert USER INFO response here.'

        # This method shouldn't really be called at if it was a private message,
        # but just in case there was a brainfart somewhere.
        return nil if helper_obj.is_private_message

        #if !helper_obj.user_is_server_moderator?
        #  #response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
        #  #response_str = helper_obj.substitute_event_vars response_str
        #
        #  #event_obj.respond response_str
        #  return nil
        #end

        show_user_id = helper_obj.user_id

        if !helper_obj.command_args_str.empty? && helper_obj.user_is_server_moderator?
          #tagged_user = BOT_OBJ.parse_mention(helper_obj.command_args_str)
          # <User username=Bifrost-dev id=361603350975741952 discriminator=0209>
          #ap tagged_user

          # 123456789012345678
          # <@123456789012345678>
          # <@!123456789012345678>
          user_tagged = helper_obj.command_args_str.match(/^<?@?!?(?<id>[0-9]+)>?$/)
          show_user_id = user_tagged[:id] if user_tagged
        end

        #show_user_id = if tagged_user.nil? || tagged_user.class != Discordrb::User
        #                 helper_obj.user_id
        #               else
        #                 tagged_user.id
        #               end
        #

        server_id = BOT_CONFIG.bot_runs_on_server_id
        show_user_obj = BOT_CACHE.get_server_user(server_id, show_user_id)
        #Debug.pp show_user_obj

        # Fetch all the previous usernames and nicknames stored in the database for this user.
        user_nicknames_hash = BOT_CACHE.get_user_nicknames(server_id, show_user_id)
        user_nicknames_array = []
        user_nicknames_hash[:nicknames].each { |nickname| user_nicknames_array.push(+'' << nickname << '') }
        user_nicknames_str = user_nicknames_array.join ', '

        user_info_embed_hash = {
          # rubocop:disable Layout/AlignHash
          author: {
            icon_url: show_user_obj.avatar_url,
            name:     +'' << show_user_obj.username << (show_user_obj.nick.nil_or_empty? ? '' : +' → ' << show_user_obj.nick)
          },
          thumbnail: {
            url: show_user_obj.avatar_url # Only shows on phones. / Chrome web-client.
          },
          #image: {
          #  url: show_user_obj.avatar_url # Only shows on Chrome web-client.
          #},
          #description: [
          #  (+'**User joined at**: ' << show_user_obj.joined_at.to_s),
          #  '**Recorded usernames/nicknames**:',
          #  user_nicknames_str
          #],
          fields: [{
            name:  'User joined at:',
            value: show_user_obj.joined_at.to_s,
            inline: false
          }, {
            name:  'Recorded usernames/nicknames:',
            value: user_nicknames_str,
            inline: false
          }]
          # rubocop:enable Layout/AlignHash
        }

        embed_return_hash = helper_obj.create_discord_embed(user_info_embed_hash)
        content = embed_return_hash[:content]
        embed_obj = embed_return_hash[:embed]

        event_obj.send_embed(content, embed_obj)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #module UserInfo
  end
  #module Commands
end
#module BifrostBot
