# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# MIT License
#
# Copyright (c) 2018
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Bifrost / Askeladden v2
module BifrostBot
  # Helper class to get stuff from an event object with less digging and variation.
  # Because laziness.
  class DiscordEventHelper
    require 'debug'
    require 'time'



    private

    # If you add something here, the same value might be needed in
    # the initialize method, and the to_s method.
    valid_read_write_methods = %w[
      user_roles
      user_nick
    ]
    valid_read_only_methods = %w[
      bot_runs_on_server_id
      bot_invoke_character
      is_private_message

      has_server_obj
      server_id
      server_name

      has_channel_obj
      channel_id
      channel_name
      channel_type

      has_user_obj
      user_id
      user_name
      user_discriminator
      user_distinct
      user_mention
      user_joined_at
      user_is_bot
      user_avatar_id
      user_avatar_url
      user_game

      message_id
      message
      msg_files
      msg_embeds
      msg_timestamp
      msg_is_edited
      edited_timestamp
      is_bot_command
      command
      command_args
      uc_command_args
      command_args_str
      uc_command_args_str

      audit_action_types
    ]

    #class << self
    public

    valid_read_only_methods.each { |key_method| attr_reader key_method.to_sym }
    valid_read_write_methods.each { |key_method| attr_accessor key_method.to_sym }

    def username
      Debug.warn('USE user_name')
      @user_name
    end

    protected

    #valid_read_write_methods.each { |key_method| attr_writer key_method.to_sym }

    private

    attr_accessor :db_obj
    #end



    public

    def to_s
      protected_write_values = %w[
        bot_runs_on_server_id
        bot_invoke_character
        is_private_message

        has_server_obj
        server_id
        server_name

        has_channel_obj
        channel_id
        channel_name
        channel_type

        has_user_obj
        user_id
        user_name
        user_discriminator
        user_distinct
        user_mention
        user_nick
        user_roles
        user_joined_at
        user_is_bot
        user_avatar_id
        user_avatar_url
        user_game

        message_id
        message
        msg_files
        msg_embeds
        msg_timestamp
        msg_is_edited
        edited_timestamp
        is_bot_command
        command
        command_args
        uc_command_args
        command_args_str
        uc_command_args_str
      ]
      protected_write_values_hash = {}

      protected_write_values.each do |method|
        value = instance_variable_get('@' + method.to_s)
        protected_write_values_hash[method] = value
      end

      #{ protected_write: protected_write_values_hash }
      +'#<BifrostBot::DiscordEventHelper: ' << Debug.pp(protected_write_values_hash, 2, false)
    end



    public

    def initialize(event_obj)
      #ap event_obj

      @db_obj = nil

      @bot_runs_on_server_id  = BOT_CONFIG.bot_runs_on_server_id
      @bot_invoke_character   = BOT_CONFIG.bot_invoke_character

      from_event_obj = nil
      server_obj = if event_obj.respond_to?('server') && !event_obj.server.nil?
                     from_event_obj = 'event_obj.server'
                     event_obj.server
                   else
                     DiscordEventServerHelper.new({})
                   end
      @has_server_obj = from_event_obj
      @server_id      = server_obj.id
      @server_name    = server_obj.name

      # If the event_obj has a channel-object, then that can be used to determine
      # if it is a private message by checking Discord's internal channel-types.
      #@is_private_message = false
      #@is_private_message = (@server_id.nil? || @server_id.zero? || @server_id != @bot_runs_on_server_id)

      #@server_info_channel_id              = BOT_CONFIG.info_channel_id
      #@server_default_channel_id           = BOT_CONFIG.default_channel_id
      #@server_role_spam_channel_id         = BOT_CONFIG.role_spam_channel_id
      #@server_generic_spam_channel_id      = BOT_CONFIG.generic_spam_channel_id
      #@server_audit_spam_mod_channel_id    = BOT_CONFIG.audit_spam_mod_channel_id
      #@server_audit_spam_public_channel_id = BOT_CONFIG.audit_spam_public_channel_id
      #@server_exercises_channel_id         = BOT_CONFIG.exercises_channel_id

      from_event_obj = nil
      channel_obj = if event_obj.respond_to?('channel') && !event_obj.channel.nil?
                      from_event_obj = 'event_obj.channel'
                      event_obj.channel
                    else
                      DiscordEventChannelHelper.new({})
                    end
      #
      @has_channel_obj = from_event_obj
      @channel_id   = channel_obj.id
      @channel_name = channel_obj.name
      @channel_type = channel_obj.type

      @is_private_message = if channel_obj.respond_to?('pm?')
                              channel_obj.pm?
                            else
                              false
                            end
      #

      from_event_obj = nil
      user_obj = if event_obj.respond_to?('user') && !event_obj.user.nil?
                   from_event_obj = 'event_obj.user'
                   event_obj.user
                 else
                   DiscordEventUserHelper.new({})
                 end
      #

      @has_user_obj       = from_event_obj
      @user_id            = user_obj.id             # Unique id for each user.
      @user_name          = user_obj.username       # <Someone>
      @user_discriminator = user_obj.discriminator  # -1
      @user_distinct      = user_obj.distinct       # <Someone>#-1
      @user_mention       = user_obj.mention        # <@id>
      @user_is_bot        = user_obj.bot_account?
      @user_avatar_id     = user_obj.avatar_id
      @user_avatar_url    = user_obj.avatar_url
      @user_game          = user_obj.game

      @user_nick          = (user_obj.respond_to?('nick')      && !user_obj.nick.nil?      ? user_obj.nick      : '') # <I'm someone else>
      @user_joined_at     = (user_obj.respond_to?('joined_at') && !user_obj.joined_at.nil? ? user_obj.joined_at : '')

      user_roles = {}
      if user_obj.respond_to?('roles') && !user_obj.roles.nil_or_empty?
        user_obj.roles.each do |role_obj|
          #user_roles[role_obj.name.upcase] = role_obj.id
          user_roles[role_obj.id] = role_obj.name.upcase
        end
      end
      @user_roles = user_roles

      @message_id       = 0
      @message          = ''
      @msg_files        = []
      @msg_embeds       = []
      @msg_timestamp    = ''
      @msg_is_edited    = false
      @edited_timestamp = ''
      @is_bot_command   = false
      @command          = ''
      @command_args     = []
      @uc_command_args  = []
      @command_args_str = ''
      @uc_command_args_str = ''

      case event_obj
      when Discordrb::Events::MessageEvent,
           Discordrb::Events::MessageEditEvent,
           Discordrb::Events::PrivateMessageEvent,
           Discordrb::Events::MentionEvent
        #puts Debug.msg('message')
        initialize_message_event event_obj

      when Discordrb::Events::MessageDeleteEvent
        #puts Debug.msg('msg delete')
        initialize_delete_event event_obj
        @is_private_message = (@server_id.nil? || @server_id.zero? || @server_id != @bot_runs_on_server_id)

      # Some of these events shouldn't really create a new helper object, but in any case.
      when Discordrb::Events::ReadyEvent, # rubocop:disable Lint/EmptyWhen
           Discordrb::Events::HeartbeatEvent,
           Discordrb::Events::DisconnectEvent,
           Discordrb::Events::VoiceStateUpdateEvent,
           Discordrb::Events::ServerMemberAddEvent,
           Discordrb::Events::ServerMemberDeleteEvent,
           Discordrb::Events::UserBanEvent,
           Discordrb::Events::UserUnbanEvent,
           Discordrb::Events::RawEvent,
           Discordrb::Events::UnknownEvent
        #puts Debug.msg('server')
        # Do not try to fetch any extra information for these events.

      when Discordrb::Events::ServerMemberUpdateEvent,
           Discordrb::Events::PresenceEvent
        #puts Debug.msg('extra_user')
        initialize_extra_user_info event_obj

      else
        #raise(Debug.internal_msg('Unhandled event_obj type: ') + Debug.msg(event_obj.class.to_s, 'cyan'))
        puts Debug.msg('-----UNHANDLED IN HELPER_OBJ INIT----->', 'red') + Debug.msg(event_obj.class.to_s, 'cyan') + Debug.msg('<----------', 'red')
        Debug.pp self.to_s # rubocop:disable Style/RedundantSelf
      end

      # Set this at the top instead. The initialize_methods that might set @server_id redo this check.
      #@is_private_message = (@server_id.nil? || @server_id.zero? || @server_id != @bot_runs_on_server_id)

      if BOT_CONFIG.debug_spammy && false # rubocop:disable Lint/LiteralAsCondition
        obj_summary_hash = {
          has_server_obj:     @has_server_obj,
          server_id:          @server_id,
          server_name:        @server_name,
          is_private_message: @is_private_message,
          has_channel_obj:    @has_channel_obj,
          channel_id:         @channel_id,
          channel_name:       @channel_name,
          has_user_obj:       @has_user_obj,
          user_id:            @user_id,
          user_name:          @user_name,
          user_discriminator: @user_discriminator,
          user_nick:          @user_nick,
          user_is_bot:        @user_is_bot
        }
        puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(obj_summary_hash, 0, false)
      end

      # https://discordapp.com/developers/docs/resources/audit-log
      @audit_action_types = {
        server_update:            1,
        channel_create:           10,
        channel_update:           11,
        channel_delete:           12,
        channel_overwrite_create: 13,
        channel_overwrite_update: 14,
        channel_overwrite_delete: 15,
        member_kick:              20,
        member_prune:             21,
        member_ban_add:           22,
        member_ban_remove:        23,
        member_update:            24,
        member_role_update:       25,
        role_create:              30,
        role_update:              31,
        role_delete:              32,
        invite_create:            40,
        invite_update:            41,
        invite_delete:            42,
        webhook_create:           50,
        webhook_update:           51,
        webhook_delete:           52,
        emoji_create:             60,
        emoji_update:             61,
        emoji_delete:             62,
        # 70
        # 71
        message_delete:           72
      }.freeze

      #return nil
      #nil
    end



    # This is not a magic Ruby method, but has to be called manually.
    def finalize; end



    protected

    def initialize_message_event(event_obj)
      @message_id       = event_obj.message.id
      @message          = event_obj.message.content
      @msg_timestamp    = event_obj.message.timestamp
      @msg_is_edited    = event_obj.message.edited
      @edited_timestamp = event_obj.message.edited_timestamp

      files_array = []
      event_obj.message.attachments.each do |file|
        files_array.push file.url
      end
      @msg_files = files_array

      # Ignoring the embeds for now.
      # Too many fields to bother with, and only bots(?) that create them?
      # Make a summary of them instead.
      embeds_array = []
      event_obj.message.embeds.each do |embed|
        if !embed.title.nil_or_empty?
          embeds_array.push embed.title
          break
        end

        if !embed.description.nil_or_empty?
          embeds_array.push embed.description
          break
        end

        if !embed.fields.nil_or_empty?
          embed.fields.each { |embed_field| embeds_array.push embed_field.name }
          break
        end

        embeds_array.push 'Embed with fields currently ignored by the bot.'
      end
      @msg_embeds = embeds_array

      # If the message is empty, add the fields titles to the message.
      # Otherwise ignore the embed completely.
      @message = (@message.nil_or_empty? ? @msg_embeds.join("\n") : @message)
      @msg_embeds = []

      @is_bot_command = false
      text_string = ''

      # Don't bother trying to parse the stuff it is a bot that sends it.
      return if @user_is_bot

      # If it is a private message, then make it a bot command in itself.
      if @is_private_message
        # If the first character actually is the bot command/invoke character
        # then remove it, to make it easier for the user.
        text_string = if @message[0] == @bot_invoke_character
                        @message[1..-1] || ''
                      else
                        @message || ''
                      end
        #
        @is_bot_command = true if !text_string.empty?

      # If it is a public message (not private), then it needs to start with
      # the bot command/invoke character.
      elsif !@is_private_message && @message[0] == @bot_invoke_character
        # Remove the bot command/invoke character.
        text_string = @message[1..-1] || ''

        @is_bot_command = true if !text_string.empty?
      end

      # Don't bother to split up the line if it is not potentially a bot command.
      return if !@is_bot_command

      text_array = text_string.split(/\s+/)

      #if !@is_private_message && @message[0] == @bot_invoke_character
      #  text_string = @message[1..-1] || ''
      #  @is_bot_command = true if !text_string.empty?
      #else
      #  text_string = @message || ''
      #end
      #text_array = text_string.split(/\s+/)
      #
      #return if !@is_bot_command && !@is_private_message

      @command             = (text_array[0] || '').upcase
      @command_args        = text_array[1..-1] || []
      @uc_command_args     = @command_args.map(&:upcase) # { |arg| arg.upcase }
      @command_args_str    = @command_args.join ' '
      @uc_command_args_str = @command_args_str.upcase

      # Re-check the first "word" in the text array, and compare it with the valid
      # characters from the configuration file to decide if it still should be
      # considered a valid bot command.
      #@is_bot_command = %r{^#{BOT_CONFIG.bot_valid_command_characters}$}.match?(@command)
      @is_bot_command = /^#{BOT_CONFIG.bot_valid_command_characters}$/.match?(@command)

      #return nil
      nil
    end



    # No longer used. Can be deleted.
    def initialize_command_event(_event_obj)
      #return nil
      nil
    end



    def initialize_delete_event(event_obj)
      @message_id = event_obj.id

      # Private messages don't have a server-id.
      @server_id   = event_obj.channel.server.id   if !event_obj.channel.server.nil?
      @server_name = event_obj.channel.server.name if !event_obj.channel.server.nil?

      nil
    end



    def initialize_extra_user_info(_event_obj)
      nil
    end



    public

    def create_user_helper_obj
      single_user_data_hash = {
        id:            @user_id,
        username:      @user_name,
        discriminator: @user_discriminator,
        distinct:      @user_distinct,
        mention:       @user_mention,
        avatar_id:     @user_avatar_id,
        avatar_url:    @user_avatar_url,
        game:          @user_game,
        bot_account:   @user_is_bot,

        nick:          @user_nick,
        roles:         @user_roles,
        joined_at:     @user_joined_at
      }

      # Make a new helper user object with the hash data, then return it.
      DiscordEventUserHelper.new single_user_data_hash
    end



    def url_username?
      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(BOT_CONFIG.illegal_usernames, 0, false) if BOT_CONFIG.debug_spammy
      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp("User: #{@user_name}, Nick: #{@user_nick}", 0, false) if BOT_CONFIG.debug_spammy

      has_url_username = false

      if !BOT_CONFIG.illegal_usernames.nil_or_empty?
        BOT_CONFIG.illegal_usernames.each do |regexp|
          next if regexp.empty?
          next if !(@user_name.match?(/#{regexp}/) || @user_nick.match?(/#{regexp}/))

          puts '-----' + Debug.msg("User: #{@user_name}, Nick: #{@user_nick} → " + 'User/nick match on: /' + regexp + '/', 'red') + '-----' if BOT_CONFIG.debug_spammy

          has_url_username = true
          break
        end
      end

      #return has_url_username
      has_url_username
    end



    def user_is_bot_owner?
      return_value = false
      return false if @user_id.nil? || !@user_id.positive?

      #Debug.pp(user: @user_id, devs: BOT_CONFIG.developer_user_ids) if BOT_CONFIG.debug_spammy

      if BOT_CONFIG.developer_user_ids.is_a?(Array)
        BOT_CONFIG.developer_user_ids.each do |single_owner_user_id|
          next if single_owner_user_id.nil? || !single_owner_user_id.is_a?(Integer)
          next if single_owner_user_id != @user_id

          return_value = true
          break
        end

      elsif BOT_CONFIG.developer_user_ids.is_a?(Integer) # nil = NilClass
        return_value = (BOT_CONFIG.developer_user_ids == @user_id)
      end

      #return return_value
      return_value
    end



    def user_is_roleless?
      #Debug.pp(user: @user_id, user_roles: @user_roles) if BOT_CONFIG.debug_spammy
      return true if @user_roles.empty?

      false
    end



    def user_is_bot_impersonator?
      return_value = false
      return false if @user_id.nil? || !@user_id.positive?

      Debug.pp(user: @user_id, imps: BOT_CONFIG.bot_impersonator_user_ids) if BOT_CONFIG.debug_spammy

      if BOT_CONFIG.bot_impersonator_user_ids.is_a?(Array)
        BOT_CONFIG.bot_impersonator_user_ids.each do |single_owner_user_id|
          next if single_owner_user_id.nil? || !single_owner_user_id.is_a?(Integer)
          next if single_owner_user_id != @user_id

          return_value = true
          break
        end

      elsif BOT_CONFIG.bot_impersonator_user_ids.is_a?(Integer) # nil = NilClass
        return_value = (BOT_CONFIG.bot_impersonator_user_ids == @user_id)
      end

      #return return_value
      return_value
    end



    def user_is_server_moderator?
      #Debug.pp(user: @user_id, user_roles: @user_roles, admin_roles: BOT_CONFIG.moderator_role_ids) if BOT_CONFIG.debug_spammy
      return_value = user_has_one_of_these_roles?(BOT_CONFIG.moderator_role_ids)

      #return return_value
      return_value
    end



    def user_is_server_contributor?
      #Debug.pp(user: @user_id, user_roles: @user_roles, admin_roles: BOT_CONFIG.contributor_role_ids) if BOT_CONFIG.debug_spammy
      return_value = user_has_one_of_these_roles?(BOT_CONFIG.contributor_role_ids)

      #return return_value
      return_value
    end



    def user_has_one_of_these_roles?(array_of_role_ids)
      return_value = false
      return false if @user_id.nil? || !@user_id.positive?
      return false if @user_roles.nil? || @user_roles.empty?

      #Debug.pp(user: @user_id, user_roles: @user_roles, check_against: array_of_role_ids) if BOT_CONFIG.debug_spammy

      # nil → NilClass
      if array_of_role_ids.is_a?(Array)
        array_of_role_ids.each do |single_role_id|
          next if single_role_id.nil? || !single_role_id.is_a?(Integer)
          next if !@user_roles.key?(single_role_id)

          return_value = true
          break
        end

      elsif array_of_role_ids.is_a?(Integer) # nil = NilClass
        return_value = @user_roles.key?(array_of_role_ids)
      end

      #return return_value
      return_value
    end



    # @returns [nil] if no match were found.
    # @returns [Array<Integer>] if one or more matches were found.
    def server_role_name_to_role_ids(server_role_name)
      Debug.pp BOT_CACHE.role_ids
      Debug.pp BOT_CACHE.role_names
      server_role_ids = []

      # Loop over all the server roles in the Cache.
      # The role_ids are the only one to contain all entries since the
      # id is unique. The role_names might not be.
      BOT_CACHE.role_ids.each_key do |single_server_role_id|
        server_role_ids.push(single_server_role_id) if server_role_name == BOT_CACHE.role_ids[single_server_role_id].uc_name
      end

      Debug.pp server_role_ids
      server_role_ids = nil if server_role_ids.empty?

      #return server_role_ids
      server_role_ids
    end



    # @returns [nil, false] The role doesn't exist.
    # @returns [Array] String Array with what changes were done.
    def change_server_role_on_user(server_role_name)
      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(BOT_CACHE.role_ids, 0, false) if BOT_CONFIG.debug_spammy
      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(BOT_CACHE.role_names, 0, false) if BOT_CONFIG.debug_spammy
      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(@user_roles, 0, false) if BOT_CONFIG.debug_spammy
      return_value = {
        add_roles:    [],
        remove_roles: [],
        messages:     []
      }
      local_messages = []

      # Make sure the cached list of server roles are up-to-date.
      #BOT_CACHE.update_roles_cache
      ap BOT_CACHE

      # Check if the permission role exist on the server.
      # A bug somewhere? Spelling error in the configuration file?
      # Did the roles get changed without the configuration file getting updated?
      #
      # WARNING / BUG
      # If two roles have the exact same incasitive spelling then it is
      # "random" if you get the wanted role or not.
      #
      # Will have to change the configuration file to use unique role-id,
      # or both, if this should be handled/fixed.
      #
      several_server_role_ids = server_role_name_to_role_ids(server_role_name)

      return return_value if several_server_role_ids.nil?

      # Since this server role name could possibly be matching several
      # role-ids, just use the first found, but also make a warning about
      # it.
      if several_server_role_ids.length > 1
        duplicates = several_server_role_ids.map { |role_id| +'' << role_id.to_s << ' → ' << BOT_CACHE.role_ids[role_id].uc_name }
        message_str = BOT_CONFIG.bot_event_responses[:roles_not_unique]
        local_messages.push substitute_event_vars(message_str, server_role_name, "\n" + duplicates.join("\n"))
      end

      #Debug.pp local_messages

      # Pick only the first that got matched.
      server_role_id = several_server_role_ids.shift

      # The role exists on the server. Or at least it did when the bot was
      # started.
      # Need to handle the
      #   ServerRoleCreateEvent, ServerRoleDeleteEvent and ServerRoleUpdateEvent
      # to be 100 % sure.
      #
      # Figure out if it should be added or removed from the user.
      return_value = if add_role_to_user?(server_role_id)
                       add_role_to_user(server_role_id)
                     else
                       remove_role_from_user(server_role_id)
                     end
      #
      #Debug.pp return_value

      return_value[:remove_roles] = return_value[:remove_roles].uniq
      return_value[:messages] = return_value[:messages].unshift(local_messages).flatten

      #return return_value
      return_value
    end



    # @returns [true] if the user does not have the permission role.
    # @returns [false] if the user has the permission role.
    def add_role_to_user?(server_role_id)
      #Debug.pp BOT_CACHE.role_ids
      #Debug.pp BOT_CACHE.role_names
      #Debug.pp @user_roles

      user_has_role = @user_roles.key?(server_role_id)

      #return !user_has_role
      !user_has_role
    end



    def add_role_to_user(server_role_id)
      #Debug.pp BOT_CACHE.role_ids
      #Debug.pp BOT_CACHE.role_names
      #Debug.pp @user_roles
      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(BOT_CONFIG.uc_user_exclusive_roles, 0, false) if BOT_CONFIG.debug_spammy

      return_value = {
        add_roles:    [],
        remove_roles: [],
        messages:     []
      }
      server_role_name = BOT_CACHE.role_ids[server_role_id].uc_name

      return_value[:add_roles].push server_role_id

      BOT_CONFIG.uc_user_exclusive_roles.each do |unique_role_names_hash|
        next if !unique_role_names_hash.key?(server_role_name)

        puts('Remove duplicates: ' + unique_role_names_hash.keys.to_s) if BOT_CONFIG.debug_spammy

        unique_role_names_hash.each_key do |single_role_name_to_remove|
          # Don't remove the role we already want to add.
          next if server_role_name == single_role_name_to_remove

          if BOT_CACHE.role_names.key?(single_role_name_to_remove)
            return_value[:remove_roles].push BOT_CACHE.role_names[single_role_name_to_remove].id
          else
            message_str = BOT_CONFIG.bot_event_responses[:role_not_found]
            return_value[:messages].push substitute_event_vars(message_str, single_role_name_to_remove.to_s)
          end
        end
        #loop single-unique-array
      end
      #loop all-unique-arrays

      #return return_value
      return_value
    end



    def remove_role_from_user(server_role_id)
      #Debug.pp BOT_CACHE.role_ids if BOT_CONFIG.debug_spammy
      #Debug.pp BOT_CACHE.role_names if BOT_CONFIG.debug_spammy
      #Debug.pp @user_roles if BOT_CONFIG.debug_spammy
      return_value = {
        add_roles:    [],
        remove_roles: [],
        messages:     []
      }

      return_value[:remove_roles].push server_role_id

      #return return_value
      return_value
    end



    def substitute_event_vars(text_str = '', local_event_str = nil, local_event_str_2 = nil, local_event_str_3 = nil, local_event_str_4 = nil)
      user_has_url_username = url_username?

      new_text = text_str.gsub(/##([0-9A-Z_]+)##/m) do |event_variable|
        case event_variable.tr! '#', ''
        when 'USER_ID'
          @user_id.to_s
        when 'USER_NAME', 'USERNAME'
          @user_name.to_s
        when 'USER_DISCRIMINATOR'
          @user_discriminator.to_s
        when 'USER_DISTINCT'
          user_has_url_username ? (+'Redacted_Username#' << @user_discriminator.to_s) : @user_distinct.to_s
        when 'USER_DISTINCT_BOLD'
          user_has_url_username ? (+'Redacted_Username#' << @user_discriminator.to_s) : (+'**' << @user_name.to_s << '**#' << @user_discriminator.to_s)
        when 'USER_MENTION'
          @user_mention.to_s
        when 'USER_NICK'
          @user_nick.nil_or_empty? ? '' : @user_nick.to_s
        when 'USER_NICK_BOLD'
          @user_nick.nil_or_empty? ? '' : (+'**' << @user_nick.to_s << '**')

        when 'MESSAGE_ID'
          @message_id.to_s

        when 'LOCAL_EVENT_STRING'
          if !local_event_str.nil?
            local_event_str.to_s
          else
            '***ERR:Missing_1***'
          end

        when 'LOCAL_EVENT_STRING_2'
          if !local_event_str.nil?
            local_event_str_2.to_s
          else
            '***ERR:Missing_2***'
          end

        when 'LOCAL_EVENT_STRING_3'
          if !local_event_str.nil?
            local_event_str_3.to_s
          else
            '***ERR:Missing_3***'
          end

        when 'LOCAL_EVENT_STRING_4'
          if !local_event_str.nil?
            local_event_str_4.to_s
          else
            '***ERR:Missing_4***'
          end

        when 'MODERATOR_PING'
          +'' << BOT_CONFIG.moderator_ping.to_s << ''

        when 'CHANNEL_NAME'
          @channel_name.to_s
        when 'CHANNEL_MENTION'
          +'<#' << @channel_id.to_s << '>'
        when 'CHANNEL_ID'
          @channel_id.to_s
        when 'INFO_CHANNEL_MENTION'
          +'<#' << BOT_CONFIG.info_channel_id.to_s << '>'

        when 'SERVER_NAME'
          @server_name.to_s
        when 'SERVER_ID'
          @server_id.to_s

        else
          +'***Unknown variable: ' << event_variable << '***'
        end

        # Return value is the string from the case structure.
      end

      #return new_text
      new_text
    end



    public

    # https://leovoel.github.io/embed-visualizer/
    def create_discord_embed(embed_data_hash)
      # rubocop:disable Layout/AlignHash
      defaults = {
        # Normal text at the start before the actual embed.
        # Supports the following subset of markdown.
        #   bold            **
        #   italic          *
        #   underline       __
        #   strikethrough   ~~
        #   blocktext       `
        #   codeblock       ```ruby
        # Max length 2000 characters.
        content: '',
        # The colour of the bar to the left side, in decimal form.
        colour: BOT_CONFIG.bot_text_embed_color,
        # Author of the embed. Will show up in white text on the top.
        # No markdown supported.
        # Max length 256 characters.
        author: {
        #  icon_url: '',
        #  name: '',
        #  url: ''
        },
        # The title of the embed. Will show up in blue text if a url is
        # applied. White text otherwise. Supports the subset of markdown.
        # Max length 256 characters.
        title: '',
        # The url to go to if you click on the title text.
        title_url: '',
        # Icon to show in front of the title.
        thumbnail: {
        #  url: ''
        },
        # Main description text to show in the embed. Light grey text.
        # Supports the subset of markdown. And additionally.
        #   url             [link text on screen](https://www.google.com/)
        # Max length 2048 characters.
        description: [],
        # Image to show at the bottom of the embed, before the footer.
        image: {
        #  url: ''
        },
        # Footer text at the bottom of the embed. Shows up in smaller light
        # grey text. No markdown supported.
        # Optional icon on the start.
        # Max 256 characters.
        footer: {
        #  icon_url: '',
        #  text: ''
        },
        # Timestamp to show in the footer text.
        timestamp: '',
        # Up to 25 fields to show after the description, and before the image.
        fields: [
        #  {
        #    # Header of the field. Supports limited subsection of markdown.
        #    # Max length 256 characters.
        #    name: '',
        #    # Main text of the field. Supports markdown in addition to url.
        #    # Max length 1024 characters.
        #    value: '',
        #    # Should it fill an entire row in the embed (inline = false),
        #    # or try to stack them sideways (inline = true).
        #    inline: false
        #  }
        ]
        # rubocop:enable Layout/AlignHash
      }
      embed_data_hash = defaults.merge(embed_data_hash)
      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(embed_data_hash, 0, false) if BOT_CONFIG.debug_spammy

      # Shortcuts to the contents of the embed_info_hash. Lazy.
      embed_content_str       = embed_data_hash[:content]
      embed_colour_str        = embed_data_hash[:colour]
      embed_author_hash       = embed_data_hash[:author]
      embed_title_str         = embed_data_hash[:title]
      embed_title_url_str     = embed_data_hash[:title_url]
      embed_thumbnail_hash    = embed_data_hash[:thumbnail]
      embed_description_array = embed_data_hash[:description]
      embed_image_hash        = embed_data_hash[:image]
      embed_footer_hash       = embed_data_hash[:footer]
      embed_timestamp_str     = embed_data_hash[:timestamp]
      embed_fields_arrayhash  = embed_data_hash[:fields]

      # Max lengths set by Discord.
      max_length_embed_content      = 2_000
      max_length_embed_author_name  = 256
      max_length_embed_title        = 256
      max_length_embed_description  = 2_048
      max_length_embed_footer_text  = 256
      max_length_embed_fields_count = 25
      max_length_embed_field_name   = 256
      max_length_embed_field_value  = 1_024

      # New embed object. Return value.
      embed_obj = Discordrb::Webhooks::Embed.new
      embed_obj.colour = embed_colour_str if !embed_colour_str.nil_or_empty?

      if !embed_content_str.nil_or_empty?
        embed_content_str = embed_content_str.join "\n" if embed_content_str.is_a?(Array)

        if embed_content_str.length > max_length_embed_content # rubocop:disable Style/IfUnlessModifier
          Debug.warn(+'embed_data_hash[:content] is too long. ' << embed_content_str.length.to_s << ' > max_length (' << max_length_embed_content.to_s << ')')
        end
      end

      if embed_author_hash.nil_or_empty?
        # Do nothing.
      elsif !embed_author_hash.is_a?(Hash)
        Debug.warn 'embed_data_hash[:author] is not a Hash.'
      elsif embed_author_hash[:name].nil_or_empty?
        Debug.warn 'embed_data_hash[:author] is set and missing a required :name'
      elsif embed_author_hash[:name].length > max_length_embed_author_name
        Debug.warn(+'embed_data_hash[:author][:name] is too long. ' << embed_author_hash[:name].length.to_s << ' > max_length (' << max_length_embed_author_name.to_s << ')')
      else
        embed_obj.author = Discordrb::Webhooks::EmbedAuthor.new(
          name:     embed_author_hash[:name],
          url:      embed_author_hash[:url],
          icon_url: embed_author_hash[:icon_url]
        )
      end

      if !embed_title_str.nil_or_empty?
        if embed_title_str.length > max_length_embed_title
          Debug.warn(+'embed_data_hash[:title] is too long. ' << embed_title_str.length.to_s << ' > max_length (' << max_length_embed_title.to_s << ')')
        else
          embed_obj.title = embed_title_str
        end
      end

      if !embed_title_url_str.nil_or_empty?
        if embed_title_str.nil_or_empty?
          Debug.warn 'Ignored embed_data_hash[:title_url] because embed_data_hash[:title] is not set.'
        else
          embed_obj.url = embed_title_url_str
        end
      end

      if embed_thumbnail_hash.nil_or_empty?
        # Do nothing.
      elsif !embed_thumbnail_hash.is_a?(Hash)
        Debug.warn 'embed_data_hash[:thumbnail] is not a Hash.'
      elsif !embed_thumbnail_hash[:url].nil_or_empty?
        embed_obj.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
          url: embed_thumbnail_hash[:url]
        )
      end

      if !embed_description_array.nil_or_empty?
        embed_description_array = embed_description_array.join "\n" if embed_description_array.is_a?(Array)

        if embed_description_array.length > max_length_embed_description
          Debug.warn(+'embed_data_hash[:description] is too long. ' << embed_description_array.length.to_s << ' > max_length (' << max_length_embed_description.to_s << ')')
        else
          embed_obj.description = embed_description_array
        end
      end

      if embed_image_hash.nil_or_empty?
        # Do nothing.
      elsif !embed_image_hash.is_a?(Hash)
        Debug.warn 'embed_data_hash[:image] is not a Hash.'
      elsif !embed_image_hash[:url].nil_or_empty?
        embed_obj.image = Discordrb::Webhooks::EmbedImage.new(
          url: embed_image_hash[:url]
        )
      end

      if embed_footer_hash.nil_or_empty?
        # Do nothing.
      elsif !embed_footer_hash.is_a?(Hash)
        Debug.warn 'embed_data_hash[:footer] is not a Hash.'
      elsif embed_footer_hash[:text].nil_or_empty?
        Debug.warn 'embed_data_hash[:footer] is set and missing a :text'
      elsif embed_footer_hash[:text].length > max_length_embed_footer_text
        Debug.warn(+'embed_data_hash[:footer][:text] is too long. ' << embed_footer_hash[:text].length.to_s << ' > max_length (' << max_length_embed_footer_text.to_s << ')')
      else
        embed_obj.footer = Discordrb::Webhooks::EmbedFooter.new(
          text:     embed_footer_hash[:text],
          icon_url: embed_footer_hash[:icon_url]
        )
      end

      if embed_timestamp_str.nil_or_empty?
        # Do nothing.
      else
        if embed_timestamp_str.is_a?(String)
          embed_timestamp_str = Time.parse(embed_timestamp_str) #.strftime(BOT_CONFIG.timestamp_format)
        end
        embed_obj.timestamp = embed_timestamp_str
      end

      if embed_fields_arrayhash.nil_or_empty?
        # Do nothing.
      elsif !embed_fields_arrayhash.is_a?(Array)
        Debug.warn 'embed_data_hash[:fields] is not an Array.'
      else
        i = 1
        embed_fields_arrayhash.each do |single_field|
          if i > max_length_embed_fields_count
            Debug.warn(+'Too many embed_data_hash[:fields]. Maximum allowed is ' << max_length_embed_fields_count.to_s << '.')
          elsif single_field[:name].nil_or_empty?
            Debug.warn 'embed_data_hash[:fields] is set and missing a required :name'
          elsif single_field[:value].nil_or_empty?
            Debug.warn 'embed_data_hash[:fields] is set and missing a required :value'
          else
            single_field[:name] = single_field[:name].join "\n" if single_field[:name].is_a?(Array)
            single_field[:value] = single_field[:value].join "\n" if single_field[:value].is_a?(Array)

            if single_field[:name].to_s.length > max_length_embed_field_name # rubocop:disable Style/IfUnlessModifier
              Debug.warn(+'embed_data_hash[:fields][:name] is too long. ' << single_field[:name].length.to_s << ' > max_length (' << max_length_embed_field_name.to_s << ')')
            end
            if single_field[:value].to_s.length > max_length_embed_field_value # rubocop:disable Style/IfUnlessModifier
              Debug.warn(+'embed_data_hash[:fields][:value] is too long. ' << single_field[:value].length.to_s << ' > max_length (' << max_length_embed_field_value.to_s << ')')
            end

            embed_obj.add_field(
              name:   single_field[:name],
              value:  single_field[:value],
              inline: single_field[:inline]
            )
          end
          i += 1
        end
        # each-loop
      end

      # Return value.
      { content: embed_content_str, embed: embed_obj }
    end



    def event_respond_with_pm_embed(event_obj, embed_data_hash)
      return_hash = create_discord_embed(embed_data_hash)
      content = return_hash[:content]
      embed_obj = return_hash[:embed]

      event_obj.author.send_embed(content, embed_obj)

      nil
    end



    def event_respond_with_embed(event_obj, embed_data_hash)
      return_hash = create_discord_embed(embed_data_hash)
      content = return_hash[:content]
      embed_obj = return_hash[:embed]

      event_obj.channel.send_embed(content, embed_obj)

      nil
    end



    def channel_respond_with_embed(channel_id, embed_data_hash)
      return_hash = create_discord_embed(embed_data_hash)
      content = return_hash[:content]
      embed_obj = return_hash[:embed]

      channel_obj = BOT_OBJ.channel(channel_id, @bot_runs_on_server_id)
      channel_obj.send_embed(content, embed_obj)

      nil
    end



    public

    def fetch_all_server_messages(fetch_them_all = false)
      return_str = ''

      channels_array = BOT_OBJ.server(@server_id).text_channels
      channels_array.each do |single_channel_obj|
        mobj_channel_id = single_channel_obj.id
        mobj_channel_name = single_channel_obj.name

        number_of_messages_fetched = fetch_all_channel_messages(mobj_channel_id, fetch_them_all)

        summary_str = +'**' << mobj_channel_name << '** (id: ' << mobj_channel_id.to_s << '): Fetched ' << number_of_messages_fetched.to_s << ''
        return_str = +return_str << summary_str << "\n"

        puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(summary_str, 0, false) if BOT_CONFIG.debug_spammy
      end

      #return return_str
      return_str
    end



    def fetch_all_channel_messages(mobj_channel_id, fetch_them_all = false)
      max_number_of_messages_to_fetch = 100
      number_of_messages_fetched = 0
      nothing_stored_counter = 0
      last_message_id = nil
      current_message_id = nil

      puts '-----' + Debug.msg('channel_id: ', 'black') + '----->> ' + Debug.msg(mobj_channel_id) + ' <<----------' if BOT_CONFIG.debug

      loop do
        messages_array = BOT_OBJ.channel(mobj_channel_id).history(max_number_of_messages_to_fetch, last_message_id)
        stored_messages = 0

        #ap messages_array
        #puts 'Got ' + Debug.msg(messages_array.length.to_s) + ' messages.' if BOT_CONFIG.debug_spammy

        messages_array.each do |single_message_obj|
          current_message_id = single_message_obj.id
          message_stored_successfully = create_new_message_from_message_obj(single_message_obj, @server_id, mobj_channel_id)

          number_of_messages_fetched += 1 if message_stored_successfully
          stored_messages += 1 if message_stored_successfully
        end

        last_message_id = current_message_id

        break if messages_array.length < max_number_of_messages_to_fetch

        puts '---------->> ' + Debug.msg("stored: #{stored_messages}, 0-count: #{nothing_stored_counter}") + ' <<----------' if BOT_CONFIG.debug_spammy

        if !fetch_them_all && stored_messages <= 0
          nothing_stored_counter += 1
          break if nothing_stored_counter > 2
        end

        puts 'Got ' + Debug.msg(messages_array.length.to_s) + ' messages. Do another loop...' if BOT_CONFIG.debug_spammy
        sleep 4.2
      end

      #return number_of_messages_fetched
      number_of_messages_fetched
    end



    def create_string_from_discord_message(msg_content, msg_files_array = nil, msg_embeds_array = nil)
      return_message_str = msg_content || ''

      files_array = []
      files_str = nil # rubocop:disable Lint/UselessAssignment

      if !msg_files_array.nil? && msg_files_array.is_a?(Array) && msg_files_array.respond_to?('url')
        msg_files_array.each { |file| files_array.push file.url }
      else
        files_array.push msg_files_array.to_s
      end
      files_str = files_array.join "\n"

      # Ignoring the complete embeds for now.
      # Too many fields to bother with, and only bots(?) that create them?
      # Make a summary of them instead.
      embeds_array = []
      embeds_str = nil # rubocop:disable Lint/UselessAssignment

      if !msg_embeds_array.nil? && msg_embeds_array.is_a?(Array)
        msg_embeds_array.each do |embed|
          if embed.respond_to?('title') && !embed.title.nil_or_empty?
            embeds_array.push embed.title
            break
          end

          if embed.respond_to?('description') && !embed.description.nil_or_empty?
            embeds_array.push embed.description
            break
          end

          if embed.respond_to?('fields') && !embed.fields.nil_or_empty?
            embed.fields.each { |embed_field| embeds_array.push embed_field.name }
            break
          end

          embeds_array.push 'Embed with fields currently ignored by the bot.'
        end
      else
        embeds_array.push msg_embeds_array.to_s
      end
      embeds_str = embeds_array.join "\n"

      # If the message is empty, add the fields titles to the message.
      # Otherwise ignore the embed completely.
      return_message_str += "\n" + files_str if !files_str.nil_or_empty?
      return_message_str = embeds_str if return_message_str.nil_or_empty?

      #return return_message_str
      return_message_str
    end



    def create_new_message_from_message_obj(message_obj, mobj_server_id, mobj_channel_id)
      mobj_user_id          = message_obj.author.id
      mobj_message_id       = message_obj.id
      mobj_message          = message_obj.content
      mobj_msg_timestamp    = message_obj.timestamp
      #mobj_msg_is_edited   = message_obj.edited
      mobj_edited_timestamp = message_obj.edited_timestamp

      files_array = []
      message_obj.attachments.each do |file|
        files_array.push file.url
      end
      mobj_msg_files = files_array

      mobj_message = create_string_from_discord_message(mobj_message, nil, message_obj.embeds)

      message_data_hash = {
        message_id:     mobj_message_id,
        server_id:      mobj_server_id,
        channel_id:     mobj_channel_id,
        user_id:        mobj_user_id,
        is_private_msg: false,
        message:        mobj_message,
        files:          mobj_msg_files.join("\n"),
        created_at:     mobj_msg_timestamp,
        edited_at:      mobj_edited_timestamp
      }
      db_store_success = write_old_message_to_db(message_data_hash)

      #return mobj_message_id
      db_store_success
    end



    public

    def fetch_msg_delete_audit_log_info(channel_id, message_id)
      audit_hash = {}
      utc_time_stamp = Time.now.utc

      # Fetch the most recent audit entries for deleted messages.
      audit_entries_array = fetch_audit_log_entries(:message_delete, 2)
      #Debug.pp audit_entries_array

      # Loop over the audit entries for deleted messages.
      #
      # For each audit log entry check if this audit entry exists in the
      # local database already.
      #
      # If it exists, then it should be possible to retrieve the message-id
      # that triggered the audit.
      # If it doesn't exist then (in theory) it was the current message-id
      # that triggered it. (Except it doesn't work properly until at least
      # a few audit entries exists.)
      #
      audit_entries_array.each do |audit_entry|
        #              :id => 500120473875513344,
        #          :action => "message_delete",
        #         :changes => nil,
        #           :count => 2,
        #            :days => nil,
        # :members_removed => nil,
        #          :reason => nil,
        #     :target_type => "message",
        #      :channel_id => nil,
        #       :target_id => 123456789012345678,
        # :target_distinct => "Test#1234",
        #         :user_id => 876543210987654321,
        #   :user_distinct => "Noko#1234",
        #   :creation_time => "2018-10-12 01:40:12 UTC"
        #
        #Debug.pp audit_entry

        audit_log_data_hash = {
          audit_id:     audit_entry[:id],
          action_type:  audit_entry[:action],
          server_id:    @server_id,
          channel_id:   channel_id, # This will be wrong until the database is properly updated.  Or until Discord provides it in a proper way.
          message_id:   message_id, # This will be wrong until the database is properly updated.  Or until Discord provides it in a proper way.
          repeat_count: audit_entry[:count],
          changes:      nil,
          reason:       audit_entry[:reason],
          target_type:  audit_entry[:target_type].to_s,
          target_id:    audit_entry[:target_id],
          user_id:      audit_entry[:user_id],
          created_at:   audit_entry[:creation_time],
          edited_at:    utc_time_stamp
        }

        # If the log entry doesn't exist, then it is created with the given data.
        # Othwerwise it returns nil
        audit_log_cache = write_or_fetch_log_entry_to_db(audit_log_data_hash)

        next if audit_log_cache.nil?

        # Should skip if it is the wrong user, but we don't know yet who
        # the message that was deleted belonged to since the audit log
        # entry might not be the same as the one that was deleted.
        #
        # <Insert if-test here>

        audit_hash[audit_log_cache[:message_id]] = audit_log_cache
      end

      #return audit_hash
      audit_hash
    end



    def fetch_ban_audit_log_info(target_user_id)
      audit_hash = {}
      utc_time_stamp = Time.now.utc

      audit_entries_array = fetch_audit_log_entries(:member_ban_add, 2)
      #Debug.pp audit_entries_array

      audit_entries_array.each do |audit_entry|
        #              :id => 500120473875513344,
        #          :action => "member_ban_add",
        #         :changes => {},
        #           :count => nil,
        #            :days => nil,
        # :members_removed => nil,
        #          :reason => "Tralalalalaatestsetsetset",
        #     :target_type => "user",
        #      :channel_id => nil,
        #       :target_id => 123456789012345678,
        # :target_distinct => "Test#1234",
        #         :user_id => 876543210987654321,
        #   :user_distinct => "Noko#1234",
        #   :creation_time => "2018-10-12 01:40:12 UTC"
        #
        #Debug.pp audit_entry

        audit_log_data_hash = {
          audit_id:     audit_entry[:id],
          action_type:  audit_entry[:action],
          server_id:    @server_id,
          channel_id:   nil,
          message_id:   nil,
          repeat_count: audit_entry[:count],
          changes:      nil,
          reason:       audit_entry[:reason],
          target_type:  audit_entry[:target_type].to_s,
          target_id:    audit_entry[:target_id],
          user_id:      audit_entry[:user_id],
          created_at:   audit_entry[:creation_time],
          edited_at:    utc_time_stamp
        }

        # If the log entry doesn't exist, then it is created with the given data.
        # Othwerwise it returns nil
        audit_log_cache = write_or_fetch_log_entry_to_db(audit_log_data_hash)

        next if audit_log_cache.nil?

        # Skip if the banned user isn't same as the one in the audit log entry.
        next if audit_log_cache[:target_id] != target_user_id

        audit_hash[audit_entry[:id]] = audit_log_cache
      end

      #return audit_hash
      audit_hash[audit_hash.keys.max]
    end



    def fetch_unban_audit_log_info(target_user_id)
      audit_hash = {}
      utc_time_stamp = Time.now.utc

      audit_entries_array = fetch_audit_log_entries(:member_ban_remove, 2)
      #Debug.pp audit_entries_array

      audit_entries_array.each do |audit_entry|
        #              :id => 500120473875513344,
        #          :action => "member_ban_remove",
        #         :changes => {},
        #           :count => nil,
        #            :days => nil,
        # :members_removed => nil,
        #          :reason => nil,
        #     :target_type => "user",
        #      :channel_id => nil,
        #       :target_id => 123456789012345678,
        # :target_distinct => "Test#1234",
        #         :user_id => 876543210987654321,
        #   :user_distinct => "Noko#1234",
        #   :creation_time => "2018-10-12 01:40:12 UTC"
        #
        #Debug.pp audit_entry

        audit_log_data_hash = {
          audit_id:     audit_entry[:id],
          action_type:  audit_entry[:action],
          server_id:    @server_id,
          channel_id:   nil,
          message_id:   nil,
          repeat_count: audit_entry[:count],
          changes:      nil,
          reason:       audit_entry[:reason],
          target_type:  audit_entry[:target_type].to_s,
          target_id:    audit_entry[:target_id],
          user_id:      audit_entry[:user_id],
          created_at:   audit_entry[:creation_time],
          edited_at:    utc_time_stamp
        }

        # If the log entry doesn't exist, then it is created with the given data.
        # Othwerwise it returns nil
        audit_log_cache = write_or_fetch_log_entry_to_db(audit_log_data_hash)

        next if audit_log_cache.nil?

        # Skip if the unbanned user isn't same as the one in the audit log entry.
        next if audit_log_cache[:target_id] != target_user_id

        audit_hash[audit_entry[:id]] = audit_log_cache
      end

      #return audit_hash
      audit_hash[audit_hash.keys.max]
    end



    def fetch_kick_audit_log_info(target_user_id)
      audit_hash = {}
      utc_time_stamp = Time.now.utc

      audit_entries_array = fetch_audit_log_entries(:member_kick, 2)
      #Debug.pp audit_entries_array

      audit_entries_array.each do |audit_entry|
        #              :id => 500120473875513344,
        #          :action => "member_kick",
        #         :changes => {},
        #           :count => nil,
        #            :days => nil,
        # :members_removed => nil,
        #          :reason => "Tralalalalaatestsetsetset",
        #     :target_type => "user",
        #      :channel_id => nil,
        #       :target_id => 123456789012345678,
        # :target_distinct => "Test#1234",
        #         :user_id => 876543210987654321,
        #   :user_distinct => "Noko#1234",
        #   :creation_time => "2018-10-12 01:40:12 UTC"
        #
        #Debug.pp audit_entry

        audit_log_data_hash = {
          audit_id:     audit_entry[:id],
          action_type:  audit_entry[:action],
          server_id:    @server_id,
          channel_id:   nil,
          message_id:   nil,
          repeat_count: audit_entry[:count],
          changes:      nil,
          reason:       audit_entry[:reason],
          target_type:  audit_entry[:target_type].to_s,
          target_id:    audit_entry[:target_id],
          user_id:      audit_entry[:user_id],
          created_at:   audit_entry[:creation_time],
          edited_at:    utc_time_stamp
        }

        # If the log entry doesn't exist, then it is created with the given data.
        # Othwerwise it returns nil
        audit_log_cache = write_or_fetch_log_entry_to_db(audit_log_data_hash)

        next if audit_log_cache.nil?

        # Skip if the kicked user isn't same as the one in the audit log entry.
        next if audit_log_cache[:target_id] != target_user_id

        audit_hash[audit_entry[:id]] = audit_log_cache
      end

      #return audit_hash
      audit_hash[audit_hash.keys.max]
    end



    def fetch_nick_change_audit_log_info(target_user_id, new_nick)
      audit_hash = {}
      utc_time_stamp = Time.now.utc

      audit_entries_array = fetch_audit_log_entries(:member_update, 2)
      #Debug.pp audit_entries_array

      audit_entries_array.each do |audit_entry|
        #              :id => 500120473875513344,
        #          :action => "member_update",
        #         :changes => { "nick": "#<Discordrb::AuditLogs::Change:0x0000000004768ca8>" },
        #           :count => nil,
        #            :days => nil,
        # :members_removed => nil,
        #          :reason => nil,
        #     :target_type => "user",
        #      :channel_id => nil,
        #       :target_id => 123456789012345678,
        # :target_distinct => "Test#1234",
        #         :user_id => 876543210987654321,
        #   :user_distinct => "Noko#1234",
        #   :creation_time => "2018-10-12 01:40:12 UTC"
        #
        #Debug.pp audit_entry
        #ap audit_entry[:changes]['nick']
        #change_str = 'NICK|→' + audit_entry[:changes]['nick'].old + '←|→' + audit_entry[:changes]['nick'].new
        audit_entry_nick = audit_entry[:changes]['nick'].new.to_s
        change_str = 'NICK|→' + audit_entry_nick + '←|'

        audit_log_data_hash = {
          audit_id:     audit_entry[:id],
          action_type:  audit_entry[:action],
          server_id:    @server_id,
          channel_id:   nil,
          message_id:   nil,
          repeat_count: audit_entry[:count],
          changes:      change_str,
          reason:       audit_entry[:reason],
          target_type:  audit_entry[:target_type].to_s,
          target_id:    audit_entry[:target_id],
          user_id:      audit_entry[:user_id],
          created_at:   audit_entry[:creation_time],
          edited_at:    utc_time_stamp
        }

        # If the log entry doesn't exist, then it is created with the given data.
        # Othwerwise it returns nil
        audit_log_cache = write_or_fetch_log_entry_to_db(audit_log_data_hash)

        next if audit_log_cache.nil?

        # Skip if the user who got usernamed changed isn't same as the one in the audit log entry.
        next if audit_log_cache[:target_id] != target_user_id

        # Skip if the new nick name doesn't match what was expected.
        next if new_nick != audit_entry_nick

        audit_hash[audit_entry[:id]] = audit_log_cache
      end

      #return audit_hash
      audit_hash[audit_hash.keys.max]
    end



    def fetch_audit_log_entries(action_type, limit = 2)
      return_audit_logs_entries = []
      return return_audit_logs_entries if @server_id.nil? || !@server_id.positive?

      server_obj = BOT_OBJ.server(@server_id)
      audit_log_obj = server_obj.audit_logs(action: action_type, limit: limit)
      audit_log_entries = audit_log_obj.entries

      current_time_utc = Time.now.utc

      # audit_log_entries
      #              :id => 497803268420796436, # Discord's audit log id
      #          :action => :message_delete,
      #         :changes => nil,
      #           :count => 1,
      #            :days => nil,
      # :members_removed => nil,
      #          :reason => nil,
      #     :target_type => :message,
      #         :channel => nil,
      #         :inspect => "<AuditLogs::Entry id=497803268420796436 action=message_delete reason= action_type=delete target_type=message count=1 days= members_removed=>"
      #          :target => <Member user=<User username=Test id=123456789012345678 discriminator=1234> ... >,
      #            :user => <Member user=<User username=Noko id=876543210987654321 discriminator=1234> ...>
      #   :creation_time => '2018-10-12 20:55:31 UTC'
      #
      audit_log_entries.each do |audit_entry|
        # Skip this entry if it was made so long ago that Discord should have made seperate audit log entries.
        #   2018-10-12 20:55:31 UTC +  3 * 60 < 2018-10-12 21:00:01 UTC → true  (current time is outside of the 3 min range; it has been more than 3 min)
        #   2018-10-12 20:55:31 UTC + 10 * 60 < 2018-10-12 21:00:01 UTC → false (current time is inside the 10 min range; it has not been more than 10 min)
        next if audit_entry.creation_time.utc + BOT_CONFIG.discord_audit_log_max_time < current_time_utc

        audit_hash = {
          id:              audit_entry.id,
          action:          audit_entry.action,
          changes:         audit_entry.changes,
          count:           audit_entry.count,
          days:            audit_entry.days,
          members_removed: audit_entry.members_removed,
          reason:          audit_entry.reason,
          target_type:     audit_entry.target_type,
          channel_id:      audit_entry.channel,
          #inspect:        audit_entry.inspect,
          target_id:       audit_entry.target.id,
          target_distinct: +'' << audit_entry.target.username.to_s << '#' << audit_entry.target.discriminator.to_s << '',
          user_id:         audit_entry.user.id,
          user_distinct:   +'' << audit_entry.user.username.to_s << '#' << audit_entry.user.discriminator.to_s << '',
          creation_time:   audit_entry.creation_time.utc #Time.parse(audit_entry.creation_time.to_s).utc
        }

        return_audit_logs_entries.push audit_hash
      end

      #return return_audit_logs_entries
      return_audit_logs_entries
    end



    def user_banned?(user_id)
      BOT_CACHE.user_banned?(@server_id, user_id)
    end



    public

    def fetch_user_messages(number_of_messages: BOT_CONFIG.user_ban_show_messages_count, time: Time.now.utc - 2)
      #CREATE TABLE "messages" (
      #  "message_id"        integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "is_private_msg"    boolean     DEFAULT 0,
      #  "message"           text,
      #  "files"             text,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer,
      #  "deleted_at"        integer
      #)
      message_ids_array = DataStorage.get_user_message_ids(@server_id, @user_id, number_of_messages, time)
      #Debug.pp message_ids_array

      messages_hash = DataStorage.get_messages(message_ids_array.sort)
      #Debug.pp messages_hash

      channels_hash = {}
      messages_hash.each do |key, value|
        channel_id = value[:channel_id]

        channels_hash[channel_id] = {} if !channels_hash.key?(channel_id)
        channels_hash[channel_id][key] = value
      end

      #return channels_hash
      channels_hash
    end



    def write_message_to_db
      #CREATE TABLE "messages" (
      #  "message_id"        integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "is_private_msg"    boolean     DEFAULT 0,
      #  "message"           text,
      #  "files"             text,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer,
      #  "deleted_at"        integer
      #)
      message_data_hash = {
        message_id:     @message_id,           # 0
        server_id:      @server_id,            # 0
        channel_id:     @channel_id,           # 0
        user_id:        @user_id,              # 0
        is_private_msg: @is_private_message,   # false
        message:        @message,              # ''
        files:          @msg_files.join("\n"), # ''
        created_at:     @msg_timestamp,        # Time
        edited_at:      @edited_timestamp,     # Time
        deleted_at:     nil                    # Time
      }

      # Can not be NULL
      #   message_id, server_id, channel_id, user_id, created_at
      # Can be true/false
      #   is_private_msg
      %i[message files edited_at deleted_at].each do |key|
        message_data_hash[key] = nil if message_data_hash[key].nil_or_empty?
      end

      #db_results = []
      #return db_results if @message.nil?

      db_message_id = DataStorage.find_user_message(message_data_hash[:message_id], message_data_hash[:edited_at])
      db_success    = DataStorage.save_user_message(message_data_hash) if db_message_id.nil?

      #return db_success
      db_success
    end



    def write_old_message_to_db(message_data_hash)
      #CREATE TABLE "messages" (
      #  "message_id"        integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "is_private_msg"    boolean     DEFAULT 0,
      #  "message"           text,
      #  "files"             text,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer,
      #  "deleted_at"        integer
      #)

      # Can not be NULL
      #   message_id, server_id, channel_id, user_id, created_at
      # Can be true/false
      #   is_private_msg
      %i[message files edited_at deleted_at].each do |key|
        message_data_hash[key] = nil if message_data_hash[key].nil_or_empty?
      end

      #db_results = []
      #return db_results if @message.nil?

      db_message_id = DataStorage.find_user_message(message_data_hash[:message_id], message_data_hash[:edited_at])
      db_success    = DataStorage.save_user_message(message_data_hash) if db_message_id.nil?

      # If nil nothing was stored.
      # If 0 nothing was stored.
      # If >0 it was stored.
      db_success = (!db_success.nil? && db_success)

      #return db_success
      db_success
    end



    def delete_message_from_db
      found_messages = DataStorage.mark_user_messages_as_deleted(@message_id)
      messages_array = DataStorage.get_deleted_messages(@message_id) if found_messages

      # Return value.
      messages_array || []
    end



    def update_user_joined
      user_exists_already = DataStorage.server_user_exists(@server_id, @user_id)

      success = if user_exists_already
                  DataStorage.update_server_user_joined(@server_id, @user_id)
                else
                  DataStorage.save_server_user_joined(@server_id, @user_id)
                end
      #

      Debug.internal('Could not store into the database.') if !success

      #return user_exists_already
      user_exists_already
    end



    def update_user_left
      success = DataStorage.update_server_user_left(@server_id, @user_id)

      Debug.internal('Could not store into the database.') if !success

      #return success
      success
    end



    def write_user_event_to_db(event_note)
      #CREATE TABLE "user_changes" (
      #  "server_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "username"          varchar(64),
      #  "nickname"          varchar(64),
      #  "avatar_id"         varchar(35),
      #  "avatar_url"        varchar(256),
      #  "note"              text,
      #  "created_at"        integer     NOT NULL
      #)
      event_data_hash = {
        server_id:  @server_id,       # 0
        user_id:    @user_id,         # 0
        username:   @user_distinct,   # ''
        nickname:   @user_nick,       # ''
        avatar_id:  @user_avatar_id,  # ''
        avatar_url: @user_avatar_url, # ''
        note:       event_note,       # ''
        created_at: Time.now.utc      # Time
      }

      # Can not be NULL
      #   server_id, user_id, created_at
      #
      %i[username nickname avatar_id avatar_url note].each do |key|
        event_data_hash[key] = nil if event_data_hash[key].nil_or_empty?
      end

      #db_results = []
      #return db_results if username.nil?

      db_results = DataStorage.save_user_event(event_data_hash)

      #return db_results
      db_results
    end



    # @returns [Hash, nil]
    def write_or_fetch_log_entry_to_db(audit_log_data_hash)
      #CREATE TABLE "audits" (
      #  "audit_id"          integer     NOT NULL,
      #  "action_type"       integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer,
      #  "message_id"        integer,
      #  "repeat_count"      integer,
      #  "changes"           varchar(64),
      #  "reason"            text,
      #  "target_type"       varchar(64),
      #  "target_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer
      #)
      action_type = audit_log_data_hash[:action_type]
      audit_log_data_hash[:action_type] = @audit_action_types[action_type]

      audit_log_data_hash[:created_at] = audit_log_data_hash[:created_at].utc
      audit_log_data_hash[:edited_at] = Time.now.utc

      # Can not be NULL
      #   audit_id, action_type, server_id, target_id, user_id, created_at
      #
      %i[channel_id message_id repeat_count changes reason target_type].each do |key|
        audit_log_data_hash[key] = nil if audit_log_data_hash[key].nil_or_empty?
      end

      db_row_exists = DataStorage.find_audit_log_entry(audit_log_data_hash[:audit_id],
                                                       repeat_count: audit_log_data_hash[:repeat_count],
                                                       changes:      audit_log_data_hash[:changes],
                                                       reason:       audit_log_data_hash[:reason])
      #
      return nil if db_row_exists

      # If the audit-id with the same information does not exist then create it.
      # And return the contents.
      db_results = DataStorage.save_audit_log_entry(audit_log_data_hash)

      #return db_results
      db_results
    end

  end
  #class DiscordEventHelper
end
#module BifrostBot



=begin
# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.
puts "LOADED: #{__FILE__}" if Rails.configuration.app_debug_loading_files
  require 'appglobals'

  public
  protected
  private

    Debug.divider "#{__FILE__},#{__LINE__}"
    Debug.divider "#{__FILE__},#{__LINE__}" if AppGlobals.debug

    Debug.trace if AppGlobals.debug
    #raise NotImplementedError, "#{__FILE__},#{__LINE__},#{__method__}(...): Not completed yet!"
    #raise ArgumentError, "#{__FILE__},#{__LINE__},#{__method__}(...): Missing argument ``"

=end


