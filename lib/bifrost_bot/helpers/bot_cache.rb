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
  # Helper class to keep track of all the roles and users on a Discord server.
  # Because laziness.
  class BotCache
    require 'debug'
    require 'time'



    public

    attr_reader :role_ids,
                :role_names,
                #:channels,
                :users,
                :users_joined,
                :users_left,
                :users_banned,
                #
                :server_last_activity_hash,
                :server_last_question,
                #
                :exercise_users
    #



    def initialize
      @role_ids = {}   # Used when a user adds/deletes a role.
      @role_names = {} # Used when a user adds/deletes a role.
      #@channels = {}
      @users = {}
      @users_joined = []
      @users_left = []
      @users_banned = {} # To keep track of the ban event.

      @server_last_activity_hash = {} # To keep track of the last user activity on a server.
      @server_last_question = {}      # To keep track of which channel the last activity message was sent to.

      @exercise_users = {} # To keep track of users that do exercises.
      #return nil
      #nil
    end



    def initialize_roles_and_users_and_channels
      # Does not seem to work unless you have a long enough wait.
      #BOT_OBJ.game = 'Creating rain ...'
      #sleep 5

      server_id = BOT_CONFIG.bot_runs_on_server_id
      server_obj = BOT_OBJ.server(server_id)
      roles_array = server_obj.roles
      ap server_obj
      # puts 'mmmmmm' if server_obj.respond_to?('members')
      puts 'ffffff' if !server_obj.respond_to?('members')
      # puts 'meep2'
      users_array = server_obj.members
      # puts 'meep3'
      channes_array = server_obj.channels
      # puts 'meep4'

      # Make sure these are reset.
      @role_ids = {}
      @role_names = {}
      #@channels = {}
      @users = {}
      @users_joined = []
      @users_left = []
      @users_banned = {}

      # Does not seem to work unless you have a long enough wait.
      #BOT_OBJ.game = 'Creating sunshine ...'
      #sleep 30

      # Loop over all the current roles on the server
      # and store the id and name.
      roles_array.each do |role_obj|
        role_id = role_obj.id
        role_name_upcased = role_obj.name.upcase

        single_role_data_hash = {
          id:      role_id,
          name:    role_obj.name,
          uc_name: role_name_upcased
        }
        @role_ids[role_id] = DiscordEventRoleHelper.new single_role_data_hash

        # This will contain errors if there are several roles that have
        # identical names after turned into upper case.
        if @role_names.key?(role_name_upcased)
          Debug.warn 'Multiple roles that turns into the exact same name: ' + role_name_upcased
          next
        end
        @role_names[role_name_upcased] = @role_ids[role_id]
      end

      ## Loop over all the current channels on the server
      ## and store the id and name.
      #channes_array.each do |channel_obj|
      #  single_channel_data_hash = {
      #    id:   channel_obj.id,
      #    name: channel_obj.name,
      #    type: channel_obj.type
      #  }
      #  @channels[channel_obj.id] = DiscordEventChannelHelper.new single_channel_data_hash
      #end

      # Set this now, so that it is similar for all the users
      # that gets created and updated.
      updated_at = Time.now.utc

      # Fetch all the users in the database that are marked as still present
      # on the server.
      # If/when the server gets too big, this needs to be changed to return data in chunks.
      all_users_present_in_users_table = DataStorage.get_all_server_user_present(server_id)
      #Debug.pp all_users_present_in_users_table

      # Then update the updated_at timestamp for all of these.
      success = DataStorage.mass_update_joined_server_user_updated_timestamp(server_id, updated_at)
      Debug.internal('Failed to update server_users table') if !success

      # Loop over Discord's list of all the current users on the server
      # and store some of their information.
      users_array.each do |user_obj|
        user_roles = {}

        # Do this now so it is more likely to detect it when a user changes a role.
        user_obj.roles.each do |user_role_obj|
          uc_name = @role_ids[user_role_obj.id].uc_name
          #user_roles[uc_name] = user_role_obj.id
          user_roles[user_role_obj.id] = uc_name
        end

        # Create a hash
        user_id = user_obj.id
        single_user_data_hash = {
          id:            user_id,
          username:      user_obj.username,
          discriminator: user_obj.discriminator,
          distinct:      user_obj.distinct,
          mention:       user_obj.mention,
          avatar_id:     user_obj.avatar_id,
          avatar_url:    user_obj.avatar_url,
          game:          user_obj.game,
          bot_account:   user_obj.bot_account?,

          nick:          user_obj.nick,
          roles:         user_roles,
          joined_at:     user_obj.joined_at
        }

        # And make a new helper user object with the hash data.
        # Then store a reference to the helper user object inside this object.
        @users[user_id] = DiscordEventUserHelper.new single_user_data_hash

        #
        #
        ## Check if the users already exists in the user table.
        ## Updates that is was checked if found.
        ##user_is_present_in_users_table = DataStorage.update_server_user_present(server_id, user_id, updated_at)
        #
        ## If the user was not found add it to the users table, so it now exists.
        ##DataStorage.save_server_user_joined(server_id, user_id, single_user_data_hash[:joined_at], updated_at) if !user_is_present_in_users_table
        #
        #

        # Check if the user already exists in the database table, and
        # remember that before deleting the hash key.
        user_is_present_in_users_table = all_users_present_in_users_table.key?(user_id)
        all_users_present_in_users_table.delete(user_id)

        # If the user was found before manually adding it into the user table, then the user is an old user.
        # So skip to next user.
        next if user_is_present_in_users_table

        # If the user does not exist in the database already, then the user
        # has joined at some point when the bot was dead.
        # Add them to the users table, so they now exists.
        #DataStorage.save_server_user_joined(server_id, user_id, single_user_data_hash[:joined_at], updated_at) if !user_is_present_in_users_table
        DataStorage.save_server_user_joined(server_id, user_id, single_user_data_hash[:joined_at]) if !user_is_present_in_users_table

        # And create a new user event line.
        event_data_hash = {
          server_id:  server_id,
          user_id:    user_id,
          username:   single_user_data_hash[:distinct],
          nickname:   single_user_data_hash[:nick],
          avatar_id:  single_user_data_hash[:avatar_id],
          avatar_url: single_user_data_hash[:avatar_url],
          note:       BOT_CONFIG.db_message_join,
          #created_at: Time.now.utc.strftime(@time_format_str)
        }
        DataStorage.save_user_event(event_data_hash)

        @users_joined.push user_id
        #@users_left.push user_id # ADDED HERE ONLY FOR TESTING
      end
      #user_loop

      # Any user that are still in the hash-list from the database table
      # of active users, are users that left while the bot was dead.
      #Debug.pp all_users_present_in_users_table

      # sql = 'SELECT "rowid", "user_id" '
      all_users_present_in_users_table.each_key do |user_id|
        # Mark them as left in the users table.
        DataStorage.update_server_user_left(server_id, user_id, updated_at)

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
        # And create a new user event line that updates them as left.
        event_data_hash = {
          server_id:  server_id,
          user_id:    user_id,
          username:   nil,
          nickname:   nil,
          avatar_id:  nil,
          avatar_url: nil,
          note:       BOT_CONFIG.db_message_leave,
          #created_at: Time.now.utc.strftime(@time_format_str)
        }
        DataStorage.save_user_event(event_data_hash)

        @users_left.push user_id
      end

      #return nil
      nil
    end



    def show_users_that_joined_and_left
      server_id = BOT_CONFIG.bot_runs_on_server_id

      joined_users_arraystr = []
      @users_joined.each do |user_id|
        joined_users_arraystr.push(+'\• ' << @users[user_id].mention << ' (id: ' << user_id.to_s << ')')
      end

      if !@users_joined.empty?
        joined_user_count = joined_users_arraystr.length

        # 'While I was sleeping the following users **JOINED**:'
        # 'Velkommen ' << (joined_user_count > 1 ? 'til dere alle sammen!' : 'skal du være!') << "\n" \
        # 'Please assign an applicable role to yourself. Type for example `!beginner`, `!intermediate`, or `!native`.' << "\n" \
        # 'We hope you enjoy your stay – Vi håper ' <<
        # (joined_user_count > 1 ? 'dere' : 'du') <<
        # 'vil trives her.'
        config_str = BOT_CONFIG.bot_event_responses[:mass_join_start]
        #config_and = BOT_CONFIG.bot_event_responses[:mass_and]

        message_str = +'' << config_str << "\n" <<
                      #(joined_user_count > 1 ? (joined_users_arraystr[0..-2].join(",\n") << ' ' << config_and << "\n") : '') <<
                      (joined_user_count > 1 ? (joined_users_arraystr[0..-2].join(",\n") << "\n") : '') <<
                      joined_users_arraystr[-1] << "\n\n"
        #
        config_str = BOT_CONFIG.bot_event_responses[:mass_join_msg]
        config_str = config_str.sub(/##INFO_CHANNEL_MENTION##/m, +'<#' << BOT_CONFIG.info_channel_id.to_s << '>')

        message_str = message_str << config_str

        channel_id = BOT_CONFIG.default_channel_id
        channel_obj = BOT_OBJ.channel(channel_id, server_id)
        channel_obj.send_message(message_str)
      end

      left_users_arraystr = []
      @users_left.each do |user_id|
        #{
        #  user_id:   1234567890,
        #  username:  'Tsetse#1234',
        #  nicknames: ['Test', 'test_nick', 'nick', 'nicktset']
        #}
        user_nicknames_hash = get_user_nicknames(server_id, user_id)
        user_username = user_nicknames_hash[:username].nil_or_empty? ? '?' : user_nicknames_hash[:username].to_s

        #left_users_arraystr.push(+'* **' << @users[user_id].distinct << '** (id: *' << user_id.to_s << '*)')
        left_users_arraystr.push(+'\• **' << user_username << '** (id: ' << user_id.to_s << ')')
      end

      return if @users_left.empty?

      left_user_count = left_users_arraystr.length

      # 'While I was sleeping the following users **LEFT**:'
      config_str = BOT_CONFIG.bot_event_responses[:mass_leave]
      #config_and = BOT_CONFIG.bot_event_responses[:mass_and]

      message_str = +'' << config_str << "\n" <<
                    #(left_user_count > 1 ? (left_users_arraystr[0..-2].join(",\n") << ' ' << config_and << "\n") : '') <<
                    (left_user_count > 1 ? (left_users_arraystr[0..-2].join(",\n") << "\n") : '') <<
                    left_users_arraystr[-1] << "\n\n"
      #

      channel_id = BOT_CONFIG.default_channel_id
      channel_obj = BOT_OBJ.channel(channel_id, server_id)
      channel_obj.send_message(message_str)

      #return nil
      nil
    end



    def update_users_cache_with_user(user_obj)
      if !user_obj.is_a?(BifrostBot::DiscordEventUserHelper)
        Debug.internal('Did not send a DiscordEventUserHelper object.')
        return
      end

      @users[user_obj.id] = user_obj

      #return nil
      nil
    end



    def get_server_user(server_id, user_id)
      # If we have it already, then just return it.
      return @users[user_id] if @users.key?(user_id)

      # Otherwise, attempt to look it up.
      # Hmm... if it fails to totally look up the user on this server it
      # returns nil.
      store_user_object = true

      user_obj = BOT_OBJ.member(server_id, user_id)
      user_obj = BOT_OBJ.user(user_id) if user_obj.nil?

      #puts user_obj.class
      #ap user_obj

      single_user_data_hash = {
        id:            user_id,
        username:      nil,
        discriminator: nil,
        distinct:      nil,
        mention:       nil,
        avatar_id:     nil,
        avatar_url:    nil,
        game:          nil,
        bot_account:   nil,

        nick:          nil,
        roles:         nil,
        joined_at:     nil
      }

      # Use safe navigation (`&.`) instead of checking if an object exists before calling the method.
      # foo&.bar
      # foo&.bar(param1, param2)
      # foo&.bar { |e| e.something }
      # foo&.bar(param) { |e| e.something }

      if user_obj.nil?
        Debug.error('Unable to lookup user-id: ' + user_id.to_s)
        store_user_object = false

        single_user_data_hash[:username] = '<Unknown>'

      elsif user_obj.respond_to?('id') && !user_obj.id.nil?
        Debug.error('Supplied user-id is different from returned user-id: ' + user_id.to_s + ' !=' + user_obj.id.to_s) if user_id != user_obj.id
        user_id = user_obj.id

        single_user_data_hash[:id]            = user_id
        single_user_data_hash[:username]      = user_obj.username      if user_obj.respond_to?('username')
        single_user_data_hash[:discriminator] = user_obj.discriminator if user_obj.respond_to?('discriminator')
        single_user_data_hash[:distinct]      = user_obj.distinct      if user_obj.respond_to?('distinct')
        single_user_data_hash[:mention]       = user_obj.mention       if user_obj.respond_to?('mention')
        single_user_data_hash[:avatar_id]     = user_obj.avatar_id     if user_obj.respond_to?('avatar_id')
        single_user_data_hash[:avatar_url]    = user_obj.avatar_url    if user_obj.respond_to?('avatar_url')
        single_user_data_hash[:game]          = user_obj.game          if user_obj.respond_to?('game')
        single_user_data_hash[:bot_account]   = user_obj.bot_account?  if user_obj.respond_to?('bot_account?')

        single_user_data_hash[:nick]          = user_obj.nick          if user_obj.respond_to?('nick')
        single_user_data_hash[:joined_at]     = user_obj.joined_at     if user_obj.respond_to?('joined_at')

        user_roles = {}
        if user_obj.respond_to?('roles')
          user_obj.roles.each do |user_role_obj|
            next if !@role_ids.key?(user_role_obj.id)

            uc_name = @role_ids[user_role_obj.id].uc_name
            #user_roles[uc_name] = user_role_obj.id
            user_roles[user_role_obj.id] = uc_name
          end
        end

        single_user_data_hash[:roles] = user_roles
      else
        Debug.internal('Unexpected values from user-lookup.')
        store_user_object = false

        single_user_data_hash[:username] = '<Error>'
      end

      # And make a new helper user object with the hash data.
      # Then store a reference to the helper user object inside this object.
      # But only if the data is worth storing... hmm...
      user_helper_obj = DiscordEventUserHelper.new single_user_data_hash

      @users[user_id] = user_helper_obj if store_user_object

      #return user_helper_obj
      user_helper_obj
    end



    def get_user_nicknames(server_id, user_id)
      return_data = {
        user_id:   user_id,
        username:  '',
        nicknames: []
      }
      last_username = nil
      usernames = {}
      nicknames = {}

      user_info_arrayhash = DataStorage.get_db_user_info(server_id, user_id)

      user_info_arrayhash.each do |db_row|
        username = db_row[:username]
        nickname = db_row[:nickname]

        if !username.nil_or_empty?
          last_username = username
          usernames[username] = username.split('#', 2)[0]
        end

        nicknames[nickname] = true if !nickname.nil_or_empty?
      end

      return_data[:username] = last_username
      usernames.delete(last_username)

      # Test#1234, Tsetse#1234    -> [Test, Tsetse]
      # test_nick, nick, nicktset -> [test_nick, nick, nicktset]
      # [[Test, Tsetse], [test_nick, nick, nicktset]].flatten
      return_data[:nicknames] = [usernames.values, nicknames.keys].flatten

      # user_id:   1234567890,
      # username:  'Tsetse#1234',
      # nicknames: ['Test', 'test_nick', 'nick', 'nicktset']

      #return return_data
      return_data
    end



    def update_roles_cache
      server_id = BOT_CONFIG.bot_runs_on_server_id
      server_obj = BOT_OBJ.server(server_id)
      roles_array = server_obj.roles

      # Make sure these are reset.
      @role_ids = {}
      @role_names = {}

      # Loop over all the current roles on the server
      # and store the id and name.
      roles_array.each do |role_obj|
        role_id = role_obj.id
        role_name_upcased = role_obj.name.upcase

        single_role_data_hash = {
          id:      role_id,
          name:    role_obj.name,
          uc_name: role_name_upcased
        }
        @role_ids[role_id] = DiscordEventRoleHelper.new single_role_data_hash

        # This will contain errors if there are several roles that have
        # identical names after turned into upper case.
        if @role_names.key?(role_name_upcased)
          Debug.warn 'Multiple roles that turns into the exact same name: ' + role_name_upcased
          next
        end
        @role_names[role_name_upcased] = @role_ids[role_id]
      end

      #return nil
      nil
    end



    def update_role(discord_role_obj)
      return nil if discord_role_obj.name == '@everyone' && discord_role_obj.id == BOT_CONFIG.bot_runs_on_server_id

      role_id = discord_role_obj.id
      role_name_upcased = discord_role_obj.name.upcase

      # Check if the changes that were done are not stored in this cache.
      # If the role-id exists, and the name is equal in both the old object and the event object after the update, then don't do anything.
      return nil if @role_ids.key?(role_id) && @role_ids[role_id].name == discord_role_obj.name

      # Delete the old reference the hash with upcased names has, but only if it does not refer to the '@everybody' role.
      # The hash with id-names will just be overwritten, since the id remains unchanged.
      if @role_ids.key?(role_id)
        old_role_name_upcased = @role_ids[role_id].uc_name

        # Don't delete the cached key if it is the '@everybody' role.
        @role_names.delete(old_role_name_upcased) if @role_names.key?(old_role_name_upcased) && @role_names[old_role_name_upcased].id != BOT_CONFIG.bot_runs_on_server_id
      end

      single_role_data_hash = {
        id:      role_id,
        name:    discord_role_obj.name,
        uc_name: role_name_upcased
      }
      @role_ids[role_id] = DiscordEventRoleHelper.new single_role_data_hash

      # This will contain errors if there are several roles that have
      # identical names after turned into upper case.
      if @role_names.key?(role_name_upcased) && @role_names[role_name_upcased].id != role_id
        Debug.warn 'Multiple roles that turns into the exact same name: ' + role_name_upcased
        return nil
      end
      @role_names[role_name_upcased] = @role_ids[role_id]

      #return nil
      nil
    end



    def remove_role(role_id)
      return if !@role_ids.key?(role_id)

      cached_role_obj = @role_ids[role_id]
      role_name_upcased = cached_role_obj.uc_name

      @role_ids.delete(role_id)

      # Don't delete the cached key if it is the '@everybody' role.
      @role_names.delete(role_name_upcased) if @role_names.key?(role_name_upcased) && @role_names[role_name_upcased].id != BOT_CONFIG.bot_runs_on_server_id

      #return nil
      nil
    end



    def add_user_ban(server_id, user_id)
      hash_key = +'' << server_id.to_s << ',' << user_id.to_s << ''

      @users_banned[hash_key] = Time.now.utc

      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(@users_banned, 0, false) if BOT_CONFIG.debug_spammy

      #return nil
      nil
    end



    def user_banned?(server_id, user_id)
      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(@users_banned, 0, false) if BOT_CONFIG.debug_spammy
      hash_key = +'' << server_id.to_s << ',' << user_id.to_s << ''

      return_value = false
      current_time_utc = Time.now.utc
      removal_time = 60 * 5 # Stuff done after 5 minutes will still be visible in the logs.

      # Check if the key exists.
      if @users_banned.key?(hash_key)
        banned_time_utc = @users_banned[hash_key]

        # If the user was banned a long time ago, we want to remove it from the cache.
        #   2018-10-12 20:55:31 UTC +  3 * 60 < 2018-10-12 21:00:01 UTC → true  (current time is outside of the 3 min range; it has been more than 3 min)
        #   2018-10-12 20:55:31 UTC + 10 * 60 < 2018-10-12 21:00:01 UTC → false (current time is inside the 10 min range; it has not been more than 10 min)
        if banned_time_utc + removal_time < current_time_utc
          return_value = false
          remove_user_ban(server_id, user_id)
        else
          return_value = true
        end
      end

      #return return_value
      return_value
    end



    def remove_user_ban(server_id, user_id)
      hash_key = +'' << server_id.to_s << ',' << user_id.to_s << ''

      @users_banned.delete(hash_key) if @users_banned.key?(hash_key)

      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(@users_banned, 0, false) if BOT_CONFIG.debug_spammy

      #return nil
      nil
    end



    def update_last_activity(server_id, user_id)
      @server_last_activity_hash[server_id] = {
        time:    Time.now.utc,
        user_id: user_id
      } #if server_id.positive?

      #return nil
      nil
    end



    def last_activity(server_id)
      if @server_last_activity_hash.key?(server_id)
        @server_last_activity_hash[server_id]
      else
        { time:    BOT_CONFIG.bot_startup_time,
          user_id: nil }
      end
    end



    def update_last_activity_question(server_id, activity_task_obj)
      @server_last_question[server_id] = activity_task_obj
    end



    def last_activity_question(server_id)
      return @server_last_question[server_id] if @server_last_question.key?(server_id)

      #return nil
      nil
    end



    def get_exercise_user_data(user_id)
      @exercise_users[user_id] = ExerciseUserData.new(user_id) if !@exercise_users.key?(user_id)

      #return @exercise_users[user_id]
      @exercise_users[user_id]
    end

  end
  #class BotCache
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


