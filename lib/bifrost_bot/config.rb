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
  # Custom exception class for configuration errors.
  class ConfigurationError < StandardError
    def initialize(msg = 'CONFIGURATION ERROR: One or more configuration errors. Check the log.')
      super
    end
  end



  # Holds the bots configuration settings.
  class Config
    require 'debug'
    require 'time'



    private

    # WARNING:
    # If you add something here, the same value SHOULD BE ADDED in
    # the initialize method, and the to_s method.
    valid_read_only_methods = %w[
      valid_keys_only_in_secrets_file
      valid_keys

      version_number
      version_date

      version_file
      server_secrets_file
      server_configs_file

      client_id
      client_secret
      client_token

      timestamp_format
      timestamp_format_ms
      timestamp_format_timezone
      timestamp_format_hmsms

      is_test_server
      has_live_key
      has_test_key
      test_server_id
      live_server_id

      database_engine
      database_file_name
      database_port
      database_username
      database_password
      database_creation_time

      db_message_join
      db_message_leave
      db_message_banned
      db_message_unbanned
      db_message_user_name
      db_message_user_avatar
      db_message_user_game
      db_message_user_nick
      db_message_user_roles
      db_message_server_update
      db_message_roles_update
      db_message_channel_update

      verbose
      debug
      debug_spammy

      live_key_name
      test_key_name

      role_commands_hash
      silly_commands_hash
      silly_regexp_commands_hash
    ]
    valid_read_write_methods = %w[
      info_channel_id
      default_channel_id
      role_spam_channel_id
      generic_spam_channel_id
      audit_spam_mod_channel_id
      audit_spam_public_channel_id
      exercises_channel_id

      emoji_react_channels

      voice_chat_ping_counters
      voice_chat_rejoin_delay

      bot_runs_on_server_id
      bot_startup_time
      bot_identity
      bot_is_playing_game
      bot_invoke_character
      bot_valid_command_characters
      bot_valid_command_emoji
      bot_system_code
      bot_text_embed_color
      bot_url
      bot_command_texts_folder
      bot_event_responses
      bot_silly_texts
      bot_texts_folder
      bot_texts
      bot_inactivity_folder
      bot_inactivity_messages
      bot_exercises_folder
      bot_exercises
      bot_silly_command_default_timeout
      bot_command_default_attributes
      bot_command_info_attributes
      bot_command_complex_attributes
      bot_command_exercise_attributes
      bot_command_test_attributes

      user_max_bot_invokes_per_time_limit
      user_bot_invokes_minimum_time_frame_limit
      bot_invokes_time_frame_period
      user_max_bot_invokes_per_time_limit_complex
      user_bot_invokes_minimum_time_frame_limit_complex
      bot_invokes_time_frame_period_complex
      user_max_bot_invokes_per_time_limit_exercise
      user_bot_invokes_minimum_time_frame_limit_exercise
      bot_invokes_time_frame_period_exercise

      illegal_usernames
      illegal_messages
      illegal_messages_roleless
      moderator_ping
      developer_user_ids
      bot_impersonator_user_ids
      bot_impersonator_in_channel
      moderator_role_ids
      contributor_role_ids
      bot_text_input_echo_channels

      discord_audit_log_max_time
      user_ban_show_messages_count
      deleted_messages_timeout
      deleted_messages_purge_time

      wkhtmltoimage_exe_path
      ordbok_dictionary_css_file_path
      ordbok_dictionary_css
      word_inflection_image_folder
      illegal_dictionary_search_characters
      max_dictionary_results_to_show

      server_activity_channels
      server_inactivity_time
      server_time_interval_start
      server_time_interval_end

      user_role_commands
      user_exclusive_roles
      uc_user_role_commands
      uc_user_exclusive_roles
    ]

    #class << self
    public

    valid_read_only_methods.each { |key_method| attr_reader key_method.to_sym }
    valid_read_write_methods.each { |key_method| attr_reader key_method.to_sym }

    protected

    valid_read_write_methods.each { |key_method| attr_writer key_method.to_sym }

    private
    #end



    public

    # Show the values of all the internal variables.
    #
    # @return [String] All the internal variables and their values.
    #
    def to_s
      read_only_values = %w[
        version_number
        version_date

        version_file
        server_secrets_file
        server_configs_file

        client_id
        client_secret
        client_token

        timestamp_format
        timestamp_format_ms
        timestamp_format_timezone
        timestamp_format_hmsms

        is_test_server
        has_live_key
        has_test_key
        test_server_id
        live_server_id

        database_engine
        database_file_name
        database_port
        database_username
        database_password
        database_creation_time

        db_message_join
        db_message_leave
        db_message_banned
        db_message_unbanned
        db_message_user_name
        db_message_user_avatar
        db_message_user_game
        db_message_user_nick
        db_message_user_roles
        db_message_server_update
        db_message_roles_update
        db_message_channel_update

        verbose
        debug
        debug_spammy

        live_key_name
        test_key_name

        role_commands_hash
        silly_commands_hash
        silly_regexp_commands_hash
      ]
      #valid_keys_only_in_secrets_file
      #valid_keys
      protected_write_values = %w[
        info_channel_id
        default_channel_id
        role_spam_channel_id
        generic_spam_channel_id
        audit_spam_mod_channel_id
        audit_spam_public_channel_id
        exercises_channel_id

        emoji_react_channels

        voice_chat_ping_counters
        voice_chat_rejoin_delay

        bot_runs_on_server_id
        bot_startup_time
        bot_identity
        bot_is_playing_game
        bot_invoke_character
        bot_valid_command_characters
        bot_valid_command_emoji
        bot_system_code
        bot_text_embed_color
        bot_url
        bot_command_texts_folder
        bot_event_responses
        bot_silly_texts
        bot_texts_folder
        bot_texts
        bot_inactivity_folder
        bot_inactivity_messages
        bot_exercises_folder
        bot_exercises
        bot_silly_command_default_timeout
        bot_command_default_attributes
        bot_command_info_attributes
        bot_command_complex_attributes
        bot_command_exercises_attributes
        bot_command_test_attributes

        user_max_bot_invokes_per_time_limit
        user_bot_invokes_minimum_time_frame_limit
        bot_invokes_time_frame_period
        user_max_bot_invokes_per_time_limit_complex
        user_bot_invokes_minimum_time_frame_limit_complex
        bot_invokes_time_frame_period_complex
        user_max_bot_invokes_per_time_limit_exercise
        user_bot_invokes_minimum_time_frame_limit_exercise
        bot_invokes_time_frame_period_exercise

        illegal_usernames
        illegal_messages
        illegal_messages_roleless
        moderator_ping
        developer_user_ids
        bot_impersonator_user_ids
        bot_impersonator_in_channel
        moderator_role_ids
        contributor_role_ids
        bot_text_input_echo_channels

        discord_audit_log_max_time
        user_ban_show_messages_count
        deleted_messages_timeout
        deleted_messages_purge_time

        wkhtmltoimage_exe_path
        ordbok_dictionary_css_file_path
        ordbok_dictionary_css
        word_inflection_image_folder
        illegal_dictionary_search_characters
        max_dictionary_results_to_show

        server_activity_channels
        server_inactivity_time
        server_time_interval_start
        server_time_interval_end

        role_commands
        exclusive_roles
        uc_user_role_commands
        uc_user_exclusive_roles
      ]
      read_only_values_hash = {}
      protected_write_values_hash = {}

      read_only_values.each do |method|
        #value = eval "@#{method}"
        $VERBOSE = false # Turn off warnings if the value is nil.
        value = instance_variable_get('@' + method.to_s)
        $VERBOSE = true # Turn warnings back on

        value = value.truncate_lines if value.is_a?(String)
        read_only_values_hash[method] = value
      end

      protected_write_values.each do |method|
        #value = eval "@#{method}"
        $VERBOSE = false # Turn off warnings if the value is nil.
        value = instance_variable_get('@' + method.to_s)
        $VERBOSE = true # Turn warnings back on

        value = value.truncate_lines if value.is_a?(String)
        protected_write_values_hash[method] = value
      end

      #return
      #{ read_only: read_only_values_hash, protected_write: protected_write_values_hash }
      +'#<BifrostBot::Config: ' << Debug.pp({ read_only: read_only_values_hash, protected_write: protected_write_values_hash }, 2, false)
    end



    public

    # Create a new Config object.
    #
    # @param command_line_args [Array] The shell command line arguments, ARGV.
    # @return [#<BifrostBot::Config>]
    #
    def initialize(command_line_args)
      @version_file = (+ROOT_DIR << '/VERSION').freeze
      @server_secrets_file = (+ROOT_DIR << '/data/secrets.yml').freeze
      @server_configs_file = (+ROOT_DIR << '/data/server_configs.yml').freeze

      @timestamp_format = '%Y-%m-%d %H:%M:%S'
      @timestamp_format_ms = '%Y-%m-%d %H:%M:%S.%L %Z'
      @timestamp_format_timezone = '%Y-%m-%d %H:%M:%S %Z'
      @timestamp_format_hmsms = '%H%M%S'

      @live_key_name = 'LIVE'
      @test_key_name = 'TEST'

      @bot_runs_on_server_id = nil
      @bot_startup_time = Time.now.utc
      @database_creation_time = @bot_startup_time

      # These strings are used in the database to identify messages and events.
      @db_message_join  = 'JOIN'
      @db_message_leave = 'LEAVE'
      @db_message_banned   = 'BANNED'
      @db_message_unbanned = 'UNBANNED'
      @db_message_user_name = 'USERNAME'
      @db_message_user_avatar = 'AVATAR'
      @db_message_user_game = 'GAME'
      @db_message_user_nick = 'NICK'
      @db_message_user_roles = 'ROLES'
      @db_message_server_update = 'UPDATE server'
      @db_message_roles_update = 'UPDATE roles'
      @db_message_channel_update = 'UPDATE channel'

      @role_commands_hash = {}
      @silly_commands_hash = {}
      @silly_regexp_commands_hash = {}

      # The valid keys that should only be filled out in the secrets.yml file.
      # Give a warning if an actual value is set in the normal config file.
      @valid_keys_only_in_secrets_file = {
        CLIENT_ID:         ['client_id',          -1],
        CLIENT_SECRET:     ['client_secret',      ''],
        TOKEN:             ['client_token',       ''],
        DATABASE_USERNAME: ['database_username',  ''],
        DATABASE_PASSWORD: ['database_password',  '']
      }

      # The valid keys that can be in the config file.
      # Followed by an array of the internal class method to read/write and its default initial value.
      # - The KEY (in uppercase) is the keyword that is used in the configuration file.
      # - The value is the internal configuration variable used in the code, and its default value.
      @valid_keys = {
        DATABASE_ENGINE:                                    ['database_engine',    'sqlite'],                  # rubocop:disable Style/WordArray
        DATABASE_FILE_NAME:                                 ['database_file_name', 'data/server_data.sqlite'], #
        DATABASE_PORT:                                      ['database_port',      ''],

        CLIENT_ID:                                          ['client_id',          -1],
        CLIENT_SECRET:                                      ['client_secret',      ''],
        TOKEN:                                              ['client_token',       ''],
        DATABASE_USERNAME:                                  ['database_username',  ''],
        DATABASE_PASSWORD:                                  ['database_password',  ''],

        TEST_SERVER_ID:                                     ['test_server_id',     -1],
        LIVE_SERVER_ID:                                     ['live_server_id',     -1],

        INFO_CHANNEL_ID:                                    ['info_channel_id',                      -1],
        DEFAULT_CHANNEL_ID:                                 ['default_channel_id',                   -1],
        ROLE_SPAM_CHANNEL_ID:                               ['role_spam_channel_id',                 -1],
        GENERIC_SPAM_CHANNEL_ID:                            ['generic_spam_channel_id',              -1],
        AUDIT_SPAM_MOD_CHANNEL_ID:                          ['audit_spam_mod_channel_id',            -1],
        AUDIT_SPAM_PUBLIC_CHANNEL_ID:                       ['audit_spam_public_channel_id',         -1],
        EXERCISES_CHANNEL_ID:                               ['exercises_channel_id',                 -1],

        EMOJI_REACT_CHANNELS:                               ['emoji_react_channels',                 {}],

        VOICE_CHAT_PING_COUNTERS:                           ['voice_chat_ping_counters',             {}],
        VOICE_CHAT_REJOIN_DELAY:                            ['voice_chat_rejoin_delay',              60],

        BOT_RUNS_ON_SERVER_ID:                              ['bot_runs_on_server_id',                -1],
        BOT_STARTUP_TIME:                                   ['bot_startup_time',                     Time.now.utc],
        BOT_IDENTITY:                                       ['bot_identity',                         ''],
        BOT_IS_PLAYING_GAME:                                ['bot_is_playing_game',                  "I don't know what I'm doing", nil],

        BOT_INVOKE_CHARACTER:                               ['bot_invoke_character',                 '!'],
        BOT_VALID_COMMAND_CHARACTERS:                       ['bot_valid_command_characters',         '[a-zA-Z]+'],
        BOT_VALID_COMMAND_EMOJI:                            ['bot_valid_command_emoji',              ''],
        BOT_SYSTEM_CODE:                                    ['bot_system_code',                      ''],
        # 0xa84300  0x973c00  0x863500  0x752e00  0x642800  0x542100  0x431a00  0x321400  0x210d00  0x100600  0x000000
        BOT_TEXT_EMBED_COLOR:                               ['bot_text_embed_color',                 '0x0000ff'], # rubocop:disable Style/WordArray
        BOT_URL:                                            ['bot_url',                              ''],
        BOT_COMMAND_TEXTS_FOLDER:                           ['bot_command_texts_folder',             ''],
        BOT_EVENT_RESPONSES:                                ['bot_event_responses',                  {}],
        BOT_SILLY_TEXTS:                                    ['bot_silly_texts',                      {}],
        BOT_TEXTS_FOLDER:                                   ['bot_texts_folder',                     ''],
        BOT_TEXTS:                                          ['bot_texts',                            {}],
        BOT_INACTIVITY_FOLDER:                              ['bot_inactivity_folder',                {}],
        BOT_INACTIVITY_MESSAGES:                            ['bot_inactivity_messages',              {}],
        BOT_EXERCISES_FOLDER:                               ['bot_exercises_folder',                 {}],
        BOT_EXERCISES:                                      ['bot_exercises',                        {}],
        BOT_SILLY_COMMAND_DEFAULT_TIMEOUT:                  ['bot_silly_command_default_timeout',    120],

        USER_MAX_BOT_INVOKES_PER_TIME_LIMIT:                ['user_max_bot_invokes_per_time_limit',                5],
        USER_BOT_INVOKES_MINIMUM_TIME_FRAME_LIMIT:          ['user_bot_invokes_minimum_time_frame_limit',          1],
        BOT_INVOKES_TIME_FRAME_PERIOD:                      ['bot_invokes_time_frame_period',                      60],
        USER_MAX_BOT_INVOKES_PER_TIME_LIMIT_COMPLEX:        ['user_max_bot_invokes_per_time_limit_complex',        3],
        USER_BOT_INVOKES_MINIMUM_TIME_FRAME_LIMIT_COMPLEX:  ['user_bot_invokes_minimum_time_frame_limit_complex',  5],
        BOT_INVOKES_TIME_FRAME_PERIOD_COMPLEX:              ['bot_invokes_time_frame_period_complex',              60],
        USER_MAX_BOT_INVOKES_PER_TIME_LIMIT_EXERCISE:       ['user_max_bot_invokes_per_time_limit_exercise',       2],
        USER_BOT_INVOKES_MINIMUM_TIME_FRAME_LIMIT_EXERCISE: ['user_bot_invokes_minimum_time_frame_limit_exercise', 3],
        BOT_INVOKES_TIME_FRAME_PERIOD_EXERCISE:             ['bot_invokes_time_frame_period_exercise',             9],

        ILLEGAL_USERNAMES:                                  ['illegal_usernames',                    []],
        ILLEGAL_MESSAGES:                                   ['illegal_messages',                     []],
        ILLEGAL_MESSAGES_ROLELESS:                          ['illegal_messages_roleless',            []],
        MODERATOR_PING:                                     ['moderator_ping',                       ''],
        DEVELOPER_USER_IDS:                                 ['developer_user_ids',                   []],
        BOT_IMPERSONATOR_USER_IDS:                          ['bot_impersonator_user_ids',            []],
        BOT_IMPERSONATOR_IN_CHANNEL:                        ['bot_impersonator_in_channel',          nil],
        MODERATOR_ROLE_IDS:                                 ['moderator_role_ids',                   []],
        CONTRIBUTOR_ROLE_IDS:                               ['contributor_role_ids',                 []],
        BOT_TEXT_INPUT_ECHO_CHANNELS:                       ['bot_text_input_echo_channels',         []],

        DISCORD_AUDIT_LOG_MAX_TIME:                         ['discord_audit_log_max_time',           900],
        USER_BAN_SHOW_MESSAGES_COUNT:                       ['user_ban_show_messages_count',         0],
        DELETED_MESSAGES_TIMEOUT:                           ['deleted_messages_timeout',             -1],
        DELETED_MESSAGES_PURGE_TIME:                        ['deleted_messages_purge_time',          '00:00:00'],

        WKHTMLTOIMAGE_EXE_PATH:                             ['wkhtmltoimage_exe_path',               ''],
        ORDBOK_DICTIONARY_CSS_FILE_PATH:                    ['ordbok_dictionary_css_file_path',      ''],
        ORDBOK_DICTIONARY_CSS:                              ['ordbok_dictionary_css',                ''],
        WORD_INFLECTION_IMAGE_FOLDER:                       ['word_inflection_image_folder',         ''],
        ILLEGAL_DICTIONARY_SEARCH_CHARACTERS:               ['illegal_dictionary_search_characters', '[^ \.\-A-Za-z0-9]'],
        MAX_DICTIONARY_RESULTS_TO_SHOW:                     ['max_dictionary_results_to_show',       5],

        SERVER_ACTIVITY_CHANNELS:                           ['server_activity_channels',             {}],
        SERVER_INACTIVITY_TIME:                             ['server_inactivity_time',               3600], # 1 hour (60 * 60)
        SERVER_TIME_INTERVAL_START:                         ['server_time_interval_start',           '00:00:00'],
        SERVER_TIME_INTERVAL_END:                           ['server_time_interval_end',             '00:00:00'],

        USER_ROLE_COMMANDS:                                 ['user_role_commands',                   []],
        USER_EXCLUSIVE_ROLES:                               ['user_exclusive_roles',                 {}],
        UC_USER_ROLE_COMMANDS:                              ['uc_user_role_commands',                []],
        UC_USER_EXCLUSIVE_ROLES:                            ['uc_user_exclusive_roles',              {}]
      }
      @valid_keys.each_value do |value|
        #Debug.pp value
        instance_variable_set('@' + value[0].to_s, value[1])
      end

      # Get the current version number and date.
      begin
        #puts VERSION_FILE
        version_file_content = File.read(@version_file)

        @version_number = version_file_content.strip
        version_file_date = File.mtime(@version_file)
        @version_date = version_file_date.utc.strftime('%Y-%m-%d')
      rescue StandardError
        @version_number = '0.??'
        @version_date   = '2018-01-01'
      ensure
        # This will always be done.
        print ''
      end

      options = ScriptOptions.parse_command_line_options(@version_number, @version_date, command_line_args)
      #puts options.inspect

      @verbose = options.verbose
      @debug = options.debug
      @debug_spammy = options.debug_spammy

      @is_test_server = options.test_server
      if @is_test_server
        puts 'Starting the bot on the TEST server...' #if @verbose
      else
        puts Debug.msg('Starting the bot on the LIVE server...') #if @verbose
      end

      # Read the secret keys and tokens.
      puts(+'Reading ' << @server_secrets_file << ' ...') if @debug
      server_secret_configs = read_and_assign_server_secrets(@server_secrets_file)
      Debug.pp server_secret_configs if @debug_spammy

      load_and_reload_configuration

      # Generate a new admin system code.
      admin_system_code = generate_new_system_code
      puts(+'Starting system code: ' << Debug.msg(admin_system_code))

      #Debug.pp self.to_s

      #return nil
      #nil
    end



    public

    # Load or reload the configuration files and set/re-set the values.
    #
    # Some of the called methods might raise a ConfigurationError exception,
    # if there is something seriously wrong in the configuration files.
    #
    # @return [nil]
    #
    def load_and_reload_configuration
      # Read the file with the rest of the server configuration.
      puts(+'Reading ' << @server_configs_file << ' ...') if @debug
      Debug.add_message(+'Reading ' << @server_configs_file << ' ...')
      server_configs = read_and_assign_server_configs(@server_configs_file)

      # Additional server configurations split out into other files.
      # Mainly stuff which will be dynamic commands.
      load_bot_command_text_files

      #Debug.pp server_configs if @debug_spammy

      # Re-arranging some values for easier access.
      # Default channels ids.
      set_some_missing_values

      # The CSS used for the generation of html-to-image.
      #load_ordbok_uib_no_css

      # The text file containing various texts like FAQs, questions and so on.
      load_bot_text_content_files

      # The dynamic commands to change roles and
      # to show silly texts.
      initialize_role_and_silly_commands

      Debug.pp server_configs if @debug_spammy

      #return nil
      nil
    end



    # Fetch the database creation time from the database table.
    # Then set this value in the configuration.
    #
    # @return [nil]
    #
    def set_database_creation_time
      results_array = DataStorage.find_database_creation_time
      #Debug.pp results_array

      # Returns an array with 1 element.
      last_entry = results_array.pop

      @database_creation_time = last_entry[:created_at].localtime
      #Debug.pp @database_creation_time

      #return nil
      nil
    end



    private

    # Set some config values that can't be set until the configuration files
    # have been read.
    #
    # Might raise a ConfigurationError exception, if there is something
    # seriously wrong in the configuration files.
    #
    # @return [nil]
    #
    def set_some_missing_values
      found_exit_error = false

      BOT_OBJ.game = @bot_is_playing_game if !BOT_OBJ.nil? && !@bot_is_playing_game.nil?

      #rate_limit_message = @bot_event_responses[:spamming_cmds]
      @bot_command_default_attributes = {
        aliases:              [],    # A list of aliases that reference this command.
        permission_level:     0,     # The minimum permission level that can use this command
        permission_message:   false, # Message to display when a user does not have sufficient permissions to execute a command.  Disable the message by setting this option to false.
        required_permissions: [],    # Discord action permissions (e.g. :kick_members) that should be required to use this command.
        required_roles:       [],    # Roles required to use this command (all? comparison).
        allowed_roles:        [],    # Roles allowed to use this command (any? comparison).
        channels:             [],    # The channels that this command can be used on.
        chain_usable:         false, # Whether this command is able to be used inside of a command chain or sub-chain.
        help_available:       false, # Whether this command is visible in the help command.
        description:          nil,   # A short description of what this command does. Will be shown in the help command if the user asks for it.
        usage:                nil,   # A short description of how this command should be used.
        arg_types:            nil,   # An array of argument classes which will be used for type-checking.
        min_args:             0,     # The minimum number of arguments this command should have.
        max_args:             -1,    # The maximum number of arguments the command should have.
        rate_limit_message:   nil,   # The message that should be displayed if the command hits a rate limit.
        bucket:               nil    # The rate limit bucket that should be used for rate limiting. No rate limiting will be done if unspecified or nil.
      }
      @bot_command_info_attributes     = @bot_command_default_attributes.clone
      @bot_command_complex_attributes  = @bot_command_default_attributes.clone
      @bot_command_exercise_attributes = @bot_command_default_attributes.clone
      @bot_command_test_attributes     = @bot_command_default_attributes.clone

      # Converts the database file name to an absolute path.
      if @database_file_name.nil_or_empty?
        Debug.error 'Missing database file name.'
        Debug.add_message('ERROR: Missing database file name.')
        found_exit_error = true
      else
        @database_file_name = File.expand_path(+ROOT_DIR << '/' << @database_file_name.to_s).freeze
      end

      # User commands and the corresponding user role.
      # Upcase.
      if @user_role_commands.nil_or_empty?
        # Empty.
        # Could be intended so don't do anything special.
      elsif !@user_role_commands.is_a?(Hash)
        Debug.error 'Expected ‘user_role_commands’ to be a hash.'
        Debug.add_message('ERROR: Expected ‘user_role_commands’ to be a hash.')
        found_exit_error = true
      else
        upcased_user_role_commands = {}

        @user_role_commands.each do |key, value|
          #Debug.pp key
          #Debug.pp value
          upcased_user_role_commands[key.upcase] = value.upcase
        end

        @uc_user_role_commands = upcased_user_role_commands
      end

      # User roles the user can only have one of at the same time.
      # Upcase.
      if @user_exclusive_roles.nil_or_empty?
        # Empty.
        # Could be intended so don't do anything special.
      elsif !@user_exclusive_roles.is_a?(Array)
        Debug.error 'Expected ‘user_exclusive_roles’ to be an array.'
        Debug.add_message('ERROR: ‘user_exclusive_roles’ to be an array.')
        found_exit_error = true
      else
        #new_upcased_user_exclusive_roles_as_hash = []
        upcased_user_exclusive_roles = []

        @user_exclusive_roles.each do |value|
          #Debug.pp value

          if value.is_a?(Array)
            nested_upcased = {}
            #value.each { |nested_value| nested_upcased.push nested_value.upcase }
            value.each { |nested_value| nested_upcased[nested_value.upcase] = nil }

            upcased_user_exclusive_roles.push nested_upcased
          else
            Debug.error 'Expected ‘user_exclusive_roles’ to be an array with array(s).'
            Debug.add_message('ERROR: ‘user_exclusive_roles’ to be an array with array(s).')
            found_exit_error = true
          end
        end

        @uc_user_exclusive_roles = upcased_user_exclusive_roles
      end

      # 00:00:00 → 000000
      @server_time_interval_start = Time.parse(@server_time_interval_start).utc.strftime(@timestamp_format_hmsms)
      @server_time_interval_end   = Time.parse(@server_time_interval_end).utc.strftime(@timestamp_format_hmsms)

      # Default chat channel for the bot.
      if @default_channel_id.nil_empty_or_ltzero?
        Debug.error 'The bot is missing a default channel to send messages to.'
        Debug.add_message('ERROR: The bot is missing a default channel to send messages to.')
        found_exit_error = true
      end

      # Channel, if any, where there are rules or information or whatever about the server.
      @info_channel_id = @default_channel_id if @info_channel_id.nil_empty_or_ltzero?

      # Channel, if any, to respond to role modification responses.
      @role_spam_channel_id = @default_channel_id if @role_spam_channel_id.nil_empty_or_ltzero?

      # Channel, if any, to respond to general spam responses.
      @generic_spam_channel_id = @default_channel_id if @generic_spam_channel_id.nil_empty_or_ltzero?

      # Channel, if any, to display various changes that might or might not be of interest.
      @audit_spam_mod_channel_id = @default_channel_id if @audit_spam_mod_channel_id.nil_empty_or_ltzero?

      # Channel, if any, to display a summary of the audit messages. Should not contain revealing information.
      @audit_spam_public_channel_id = @default_channel_id if @audit_spam_public_channel_id.nil_empty_or_ltzero?

      # Channel, if any, for exercise responses.
      @exercises_channel_id = @default_channel_id if @exercises_channel_id.nil_empty_or_ltzero?

      if @info_channel_id == @default_channel_id
        Debug.warn 'Info channel is the default channel'
        Debug.add_message('WARNING: Info channel is the default channel')
      end
      if @audit_spam_mod_channel_id == @default_channel_id
        Debug.warn 'Audit mod channel is the default channel'
        Debug.add_message('WARNING: Audit mod channel is the default channel')
      end
      if @audit_spam_public_channel_id == @default_channel_id
        Debug.warn 'Audit public channel is the default channel'
        Debug.add_message('WARNING: Audit public channel is the default channel')
      end

      raise ConfigurationError if found_exit_error

      #return nil
      nil
    end



    private

    # Read and store the CSS-file for the Ordbok.uib.no site.
    #
    # @return [nil]
    #
    def load_ordbok_uib_no_css
      if @ordbok_dictionary_css_file_path.nil_or_empty?
        Debug.warn 'Missing a CSS file for the Ordbok.uib.no dictionary.'
        Debug.add_message('WARNING: Missing a CSS file for the Ordbok.uib.no dictionary.')
        return false
      end

      #filename = File.expand_path(BifrostBot.root_dir << @ordbok_dictionary_css_file_path)
      filename = File.expand_path(+ROOT_DIR << @ordbok_dictionary_css_file_path)
      @ordbok_dictionary_css_file_path = filename

      puts(+'Reading ' << filename << ' ...') if @debug
      Debug.add_message(+'Reading ' << filename << ' ...')
      @ordbok_dictionary_css = DataStorage.read_file(filename) || ''

      #return @ordbok_dictionary_css
      #return nil
      nil
    end



    public

    # Read and store the contents of the dynamic bot command files that
    # are configured based on the config files.
    #
    # @return [nil]
    #
    def load_bot_command_text_files
      if @bot_command_texts_folder.nil_or_empty?
        Debug.warn 'Missing a bot commands texts folder.'
        Debug.add_message('WARNING: Missing a bot commands texts folder.')
        return false
      end

      #folder_name = File.expand_path(BifrostBot.root_dir << @bot_texts_folder)
      folder_name = File.expand_path(+ROOT_DIR << @bot_command_texts_folder).freeze
      @bot_command_texts_folder = folder_name

      merged_yaml_hash = load_additional_files(folder_name)
      merged_yaml_hash ||= {}

      #Debug.pp merged_yaml_hash
      @bot_event_responses = merged_yaml_hash[:bot_event_responses] || {}
      @bot_silly_texts = merged_yaml_hash[:bot_silly_texts] || {}

      #Debug.pp @bot_event_responses
      #Debug.pp @bot_silly_texts
      if @bot_event_responses.nil_or_empty?
        Debug.warn '@bot_event_responses is empty!'
        Debug.add_message('WARNING: @bot_event_responses is empty!')
      end

      if @bot_silly_texts.nil_or_empty?
        Debug.warn '@bot_silly_texts is empty!'
        Debug.add_message('WARNING: @bot_silly_texts is empty!')
      end

      #return nil
      nil
    end



    # Read and store the contents of the bot text information files that
    # might be in one or more files in a configured folder.
    #
    # @return [nil]
    #
    def load_bot_text_content_files
      if @bot_texts_folder.nil_or_empty?
        Debug.warn 'Missing a bot texts folder.'
        Debug.add_message('WARNING: Missing a bot texts folder.')
      else
        #folder_name = File.expand_path(BifrostBot.root_dir << @bot_texts_folder)
        folder_name = File.expand_path(+ROOT_DIR << @bot_texts_folder).freeze
        @bot_texts_folder = folder_name

        merged_yaml_hash = load_additional_files(folder_name)

        @bot_texts = merged_yaml_hash || {}

        #Debug.pp @bot_texts
        if @bot_texts.nil_or_empty?
          Debug.warn '@bot_texts is empty!'
          Debug.add_message('WARNING: @bot_texts is empty!')
        end
      end

      ########################################################################

      if @bot_inactivity_folder.nil_or_empty?
        Debug.warn 'Missing a folder for inactivity stuff.'
        Debug.add_message('WARNING: Missing a folder for inactivity stuff.')
      else
        #folder_name = File.expand_path(BifrostBot.root_dir << @bot_inactivity_folder)
        folder_name = File.expand_path(+ROOT_DIR << @bot_inactivity_folder).freeze
        @bot_inactivity_folder = folder_name

        merged_yaml_hash = load_additional_files(folder_name)

        @bot_inactivity_messages = merged_yaml_hash || {}

        #Debug.pp @bot_inactivity_messages
        if @bot_inactivity_messages.nil_or_empty?
          Debug.warn '@bot_inactivity_messages is empty!'
          Debug.add_message('WARNING: @bot_inactivity_messages is empty!')
        end
      end

      ########################################################################

      if @bot_exercises_folder.nil_or_empty?
        Debug.warn 'Missing a folder for exercises.'
        Debug.add_message('WARNING: Missing a folder for exercises.')
      else
        #folder_name = File.expand_path(BifrostBot.root_dir << @bot_exercises_folder)
        folder_name = File.expand_path(+ROOT_DIR << @bot_exercises_folder).freeze
        @bot_exercises_folder = folder_name

        merged_yaml_hash = load_additional_files(folder_name)

        @bot_exercises = merged_yaml_hash || {}

        #Debug.pp @bot_exercises
        if @bot_exercises.nil_or_empty?
          Debug.warn '@bot_exercises is empty!'
          Debug.add_message('WARNING: @bot_exercises is empty!')
        end
      end

      #return nil
      nil
    end



    # Read and return the parsed YAML-contents of all the text files in
    # a folder.
    #
    # @param folder_name [String] The folder name where all files should be read from.
    # @return [Hash] The merged contents of all the files that were read.
    #
    def load_additional_files(folder_name)
      if !File.exist?(folder_name)
        Debug.warn 'Specified path for bot texts does not exist: ' + folder_name
        Debug.add_message('WARNING: Specified path for bot texts does not exist: ' + folder_name)
        return nil
      elsif !File.directory?(folder_name)
        Debug.warn 'Specified path for bot texts is not a folder: ' + folder_name
        Debug.add_message('WARNING: Specified path for bot texts is not a folder: ' + folder_name)
        return nil
      end

      merged_yaml_hash = {}

      Dir.entries(folder_name).select do |file|
        next if File.directory?(file)

        filename = File.expand_path(+folder_name << '/' << file)

        puts(+'Reading ' << filename << ' ...') if @debug
        Debug.add_message(+'Reading ' << filename << ' ...')
        yaml_hash = DataStorage.read_yaml(filename)

        #Debug.pp yaml_hash
        next if yaml_hash.nil_or_empty?

        yaml_hash.each_key do |key|
          if merged_yaml_hash.include?(key)
            Debug.warn "#{file}: key ‘#{key}’ is already defined in another file."
            Debug.add_message("WARNING: #{file}: key ‘#{key}’ is already defined in another file.")
          end
          merged_yaml_hash[key] = yaml_hash[key]
        end
      end

      #return merged_yaml_hash
      merged_yaml_hash
    end



    # Properly parse the configuration file contents that are
    # role commands and silly commands, so any default values etc
    # are taken care of.
    #
    # @return [nil]
    #
    def initialize_role_and_silly_commands
      # The roles that are acceptable as commands.
      # This already exists so just copy it.
      @role_commands_hash = {}
      @role_commands_hash = @uc_user_role_commands

      # The silly text responses that are acceptable as commands.
      # Since some of them can contain aliases the key-value pairs
      # are alias -> real command
      @silly_commands_hash = {}
      @silly_regexp_commands_hash = {}

      # Loop over all the entries that have been made
      # and skip those that are commented out or otherwise
      # empty.
      @bot_silly_texts.each do |command_key, value_hash|
        #Debug.pp [command_key, value_hash]
        next if value_hash.nil_or_empty?

        command_text    = value_hash[:text]    || nil
        command_timeout = value_hash[:time]    || nil
        command_aliases = value_hash[:aliases] || ''
        command_regexp  = value_hash[:regexp]  || nil

        next if command_text.nil_or_empty?

        # Initialize stuff.
        single_command_hash = {
          text: nil,
          time: nil
        }

        # If the text is an array, join it into a single string with newlines.
        single_command_hash[:text] = if command_text.is_a?(Array)
                                       command_text.join "\n"
                                     else
                                       command_text
                                     end
        #

        # If the time is nil or 0 use the default configuration time.
        # If the time is positive (greater than 0) use this value.
        # If the time is negative (less than 0) set it to -1 to indicate the message should be permanent.
        single_command_hash[:time] = if command_timeout.nil_or_empty? || command_timeout.zero?
                                       @bot_silly_command_default_timeout
                                     elsif command_timeout.positive?
                                       command_timeout
                                     else
                                       -1
                                     end
        #

        # Store this into the configuration for later use.
        if @silly_commands_hash.key?(command_key.upcase)
          Debug.warn "Command '#{command_key}' is redefined."
          Debug.add_message("WARNING: Command '#{command_key}' is redefined.")
        end
        @silly_commands_hash[command_key.upcase] = single_command_hash

        command_aliases.split(/\s+/).each do |command_alias|
          if @silly_commands_hash.key?(command_alias.upcase)
            Debug.warn "Command '#{command_alias}' is redefined."
            Debug.add_message("WARNING: Command '#{command_alias}' is redefined.")
          end
          @silly_commands_hash[command_alias.upcase] = single_command_hash
        end

        # Skip if the entry does not have a regexp defined.
        next if command_regexp.nil_or_empty?

        if @silly_regexp_commands_hash.key?(command_regexp)
          Debug.warn "Regexp command '#{command_regexp}' is redefined."
          Debug.add_message("WARNING: Regexp command '#{command_regexp}' is redefined.")
        end
        @silly_regexp_commands_hash[command_regexp] = single_command_hash
      end
      #loop

      #Debug.pp @role_commands_hash if @debug_spammy
      #Debug.pp @silly_commands_hash if @debug_spammy
      #Debug.pp @silly_regexp_commands_hash if @debug_spammy

      #return nil
      nil
    end



    public

    # Generate and store new system code that some commands require to be
    # used successfully.
    #
    # @return [String] The new system code.
    #
    def generate_new_system_code
      # Generate the alphabet from a - z, æ, ø, å
      alphabet = [*('a'..'z'), 'æ', 'ø', 'å']

      admin_system_code = +''

      # Pick a random number number from between 1..29
      # and use this number as index in the alphabet array to
      # generate a random 3 letter code.
      3.times { |_i| admin_system_code << alphabet[Random.new.rand(0..(alphabet.length - 1))] }

      @bot_system_code = admin_system_code

      #return admin_system_code
      admin_system_code
    end



    # Check if a supplied text string is equal to current system code.
    # Return true if it is. False otherwise.
    # But first create a new system code.
    #
    # @param comparison_str [String] The string to compare against the current system code.
    # @return [true,false] True if the system code is equal to the supplied string. False otherwise.
    #
    def check_system_code(comparison_str)
      return_value = @bot_system_code == comparison_str

      # Generate a new admin system code, irregardless the supplied one
      # was correct or not.
      config_str = ' ... '

      admin_system_code = BOT_CONFIG.generate_new_system_code
      LOGGER.info Debug.msg(admin_system_code) + config_str

      #return return_value
      return_value
    end



    # Check if a command string can be converted to a hash_key in any
    # of the text information files. If it can, return the actual hash-key
    # needed to get the text entry in the information file.
    # If none was found, return nil.
    #
    # @param command_string [String] Command string to search for.
    # @return [String, nil] The hash-key-string of successful, or nil otherwise.
    #
    def find_bot_help_entry(command_string)
      command_string       = command_string.upcase
      command_string_under = command_string.tr ' ', '_'
      found_entry = false

      bot_texts_hash = @bot_texts
      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(bot_texts_hash, 0, false) if BOT_CONFIG.debug_spammy

      # Loop through all the text entries and see if any of them match the command.
      bot_texts_hash.each_key do |help_lookup|
        bot_texts_entry = bot_texts_hash[help_lookup]
        mappings_array = [help_lookup.to_s.upcase]
        #Debug.pp(bot_texts_entry)

        # If the text entry is a hash then and has a mapping then add this to the
        # words to compare against.
        if bot_texts_entry.is_a?(Hash) && bot_texts_entry.key?(:mapping)
          bot_texts_mapping_command = bot_texts_entry[:mapping]

          if bot_texts_mapping_command.is_a?(Array)
            bot_texts_mapping_command.each { |bot_texts_mapping_str| mappings_array.push bot_texts_mapping_str.to_s.upcase }
          else
            mappings_array.push bot_texts_mapping_command.to_s.upcase
          end
        end

        # Compare all the entries in the mappings_array with the
        # command the function was invoked.
        mappings_array.each do |bot_texts_command|
          #puts '>>' + bot_texts_command + '<=??=>' + command_string + '||' + command_string_under + '<<'

          if bot_texts_command == command_string || bot_texts_command == command_string_under
            found_entry = true
            break
          end
        end

        return help_lookup if found_entry
      end
      #loop bot_texts

      #return nil
      nil
    end



    # Check if a section string can be converted to a hash_key in any
    # of the exercise text files. If it can, return the actual hash-key
    # needed to get the text entry in the information file.
    # If none was found, return nil.
    #
    # @param prefix [String] Main section in the texts to search through.
    # @param section_string [String] Subsection string to search for.
    # @param look_through_aliases [true,false] Should it also search through possible aliases.
    # @return [String, nil] The hash-key-string of successful, or nil otherwise.
    #
    def find_bot_message_entry(prefix, section_string, look_through_aliases = false)
      section_string       = (+'' << prefix << '_' << section_string).upcase
      section_string_under = section_string.tr ' ', '_'
      found_entry = false

      case prefix.upcase
      when 'MESSAGES'
        bot_texts_hash = @bot_inactivity_messages
      when 'EXERCISES'
        bot_texts_hash = @bot_exercises
      else
        Debug.internal 'Unknown section: ' + prefix
        return nil
      end
      #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(bot_texts_hash, 0, false) if BOT_CONFIG.debug_spammy

      # Try a simple match at first.
      bot_texts_hash.each_key do |key_lookup|
        key_lookup_str = key_lookup.to_s.upcase

        #puts '>>' + key_lookup_str + '<=??=>' + section_string + '||' + section_string_under + '<<'
        return key_lookup if key_lookup_str == section_string || key_lookup_str == section_string_under
      end

      return nil if !look_through_aliases

      # Loop through all the text entries again, and see if any of them has an alias section.
      # Then try to see if any of them match the text section that was wanted.
      bot_texts_hash.each_key do |key_lookup|
        text_entry = bot_texts_hash[key_lookup]
        mappings_array = []
        #Debug.pp(text_entry)

        # If the text entry is a hash then and has an aliases field then add this to the
        # words to compare against.
        if text_entry.is_a?(Hash) && text_entry.key?(:aliases)
          bot_texts_aliases = text_entry[:aliases]

          if bot_texts_aliases.is_a?(Array)
            bot_texts_aliases.each { |bot_texts_alias_str| mappings_array.push((+'' << prefix << '_' << bot_texts_alias_str.to_s).upcase) }
          else
            bot_texts_aliases.split(/,/).map { |bot_texts_alias_str| mappings_array.push((+'' << prefix << '_' << bot_texts_alias_str.strip).upcase) }
          end
        end
        #Debug.pp(mappings_array)

        # Compare all the entries in the mappings_array to see if the section
        # we're looking for is present.
        mappings_array.each do |bot_text_alias|
          #puts '>>' + bot_text_alias + '<=??=>' + section_string + '||' + section_string_under + '<<'
          next if !(bot_text_alias == section_string || bot_text_alias == section_string_under)

          found_entry = true
          break
        end

        return key_lookup if found_entry
      end
      #loop bot_texts

      #return nil
      nil
    end



    private

    # Reads the secret keys and tokens from a YAML-file.
    # Assigns the appropriate variables based on the contents.
    # Will use the last set of keys found.
    #
    # @param filename [String] The (absolute path to the) YAML-file containing the secret keys and tokens.
    # @return [Hash] Hash with the useful secret key values read from the file.
    #
    def read_and_assign_server_secrets(filename)
      server_secret_configs = DataStorage.read_yaml(filename)
      #Debug.pp server_secret_configs

      yaml_file_hash = {}
      return_hash = {
        has_live_key:      false,
        has_test_key:      false,
        client_id:         nil,
        client_secret:     nil,
        client_token:      nil,
        database_username: nil,
        database_password: nil
      }

      if server_secret_configs.is_a?(Array)
        server_secret_configs.each do |single_secret|
          #Debug.pp single_secret
          single_secret.each_key do |key|
            key_value = single_secret[key]

            if key.to_s.match?(/#{@live_key_name}/i)
              yaml_file_hash[@live_key_name] = key_value
              return_hash[:has_live_key] = true
            elsif key.to_s.match?(/#{@test_key_name}/i)
              yaml_file_hash[@test_key_name] = key_value
              return_hash[:has_test_key] = true
            else
              yaml_file_hash[key] = key_value
              Debug.warn(+'Unknown/unparsed key: ' << key.to_s)
              Debug.add_message(+'WARNING: Unknown/unparsed key: ' << key.to_s)
            end
          end
        end
      elsif server_secret_configs.is_a?(Hash)
        if @is_test_server
          yaml_file_hash[@test_key_name] = server_secret_configs
          return_hash[:has_test_key] = true
        else
          yaml_file_hash[@live_key_name] = server_secret_configs
          return_hash[:has_live_key] = true
        end
      else
        Debug.error(+'Failed to read server secrets: ' << filename)
        Debug.add_message(+'ERROR: Failed to read server secrets: ' << filename)
      end

      if @is_test_server && return_hash[:has_test_key]
        keys_to_use = @test_key_name
        return_hash[:has_live_key] = false
        return_hash[:has_test_key] = true
      elsif !@is_test_server && return_hash[:has_live_key]
        keys_to_use = @live_key_name
        return_hash[:has_live_key] = true
        return_hash[:has_test_key] = false
      else
        keys_to_use = nil
        Debug.error(+"Can't find the " << (@is_test_server ? @test_key_name : @live_key_name) << ' keys necessary to connect to Discord.')
        Debug.add_message(+"ERROR: Can't find the " << (@is_test_server ? @test_key_name : @live_key_name) << ' keys necessary to connect to Discord.')
        raise ConfigurationError
      end

      #raise Debug.error_msg('Missing the secret Discord connection keys.') if keys_to_use.nil?
      #Debug.pp yaml_file_hash

      return_hash[:client_id]     = yaml_file_hash[keys_to_use][:client_id]     || Debug.error(+'Missing ' << keys_to_use << ' client_id.')
      return_hash[:client_secret] = yaml_file_hash[keys_to_use][:client_secret] || Debug.error(+'Missing ' << keys_to_use << ' client_secret.')
      return_hash[:client_token]  = yaml_file_hash[keys_to_use][:token]         || Debug.error(+'Missing ' << keys_to_use << ' token.')
      return_hash[:database_username] = yaml_file_hash[keys_to_use][:database_username]
      return_hash[:database_password] = yaml_file_hash[keys_to_use][:database_password]

      @has_live_key  = return_hash[:has_live_key]
      @has_test_key  = return_hash[:has_test_key]
      @client_id     = return_hash[:client_id]
      @client_secret = return_hash[:client_secret]
      @client_token  = return_hash[:client_token]
      @database_username = return_hash[:database_username]
      @database_password = return_hash[:database_password]

      #return return_hash
      return_hash
    end



    private

    # Check if the key and key_value can be successfully applied to any of
    # the valid internal variables. Attempt to set the value,if so.
    #
    # @param key [String] Hash-key-string to attempt to change.
    # @param method [String] The internal variable that matches the key-string.
    # @param key_value [Object, String, Integer, Array, Hash] The value to change to.
    # @return [true, false] True if successfully changed, false otherwise.
    #
    def assign_class_method_value(key, method, key_value)
      return false if method.nil? || method.empty?

      #Debug.pp [key, method, key_value]
      debug_str = Debug.msg('Assigning to: ', 'normal') << Debug.msg(method) << ' ... '

      # Check if it is nil, empty or not positive.
      if key_value.nil_empty_or_ltzero?
        debug_str << 'ignored empty or negative value.'
        puts debug_str if @debug

        return false

      else
        key_upcased = key.to_s.upcase.to_sym

        if @valid_keys_only_in_secrets_file.include?(key_upcased)
          debug_str << Debug.msg('Do NOT set this in a public config file!', 'error') <<
            ' Use `' << Debug.msg(File.basename(server_secrets_file), 'cyan') << '´.'
          Debug.error debug_str
          Debug.add_message(+'ERROR: Do NOT set this key ‘' << key_upcased.to_s << '’ in a public config file!')
          return false
        end

        # The value is fetched from the valid_keys hasharray where the method is the key.
        # Fetch its current value.
        method_value = instance_variable_get('@' + method.to_s)

        if method_value.nil_or_empty?
          # Nothing worth noting. The value is already empty.
        else
          debug_str << Debug.msg('overwriting ... ', 'yellow')
        end

        # Set the instance variable named after the method.
        instance_variable_set('@' + method.to_s, key_value)

        debug_str << Debug.msg('done', 'cyan') << '.'
        puts debug_str if @debug
      end

      #return true
      true
    end



    # Read and assign values from the main configuration file.
    #
    # @param filename [String] The (absolute) path to the configuration file.
    # @return [Hash] The contents of the file as Hash key-value pairs.
    #
    def read_and_assign_server_configs(filename)
      server_configs = DataStorage.read_yaml(filename)
      #Debug.pp server_configs

      is_file_ok = false

      if server_configs.nil?
        # Failed to read the file.
      elsif server_configs.is_a?(Array)
        Debug.error(+'Unexpected file format: ' << filename)
        Debug.add_message(+'ERROR: Unexpected file format: ' << filename)
        raise ConfigurationError
      else
        is_file_ok = true
      end

      if !is_file_ok
        Debug.error(+'Failed to read server configs: ' << filename)
        Debug.add_message(+'ERROR: Failed to read server configs: ' << filename)
        raise ConfigurationError
      end

      #yaml_file_hash = {}
      server_specific_hash = {}
      merged_hash = {}

      server_configs.each_key do |key|
        method = nil
        key_upcased = key.to_s.upcase.to_sym
        key_value = server_configs[key]

        # Check if it is one of the allowed configuration options.
        if @valid_keys.include?(key_upcased)
          method = @valid_keys[key_upcased][0]
          #yaml_file_hash[key_upcased] = key_value

        # Check if it a server-id key.
        elsif key.to_s.match?(/^[0-9]+$/)
          server_specific_hash[key_upcased] = key_value

        # Otherwise it is an unknown key.
        else
          #yaml_file_hash[key] = key_value
          Debug.warn(+'Unknown/unparsed key: ' << key.to_s)
          Debug.add_message(+'WARNING: Unknown/unparsed key: ' << key.to_s)
        end

        # Don't do anything if the config-method is nil.
        if method.nil?
          puts(+'Not assigning the key-value: ' << key.to_s) if @debug

        # Try to assign the configuration key by using the config-method.
        elsif assign_class_method_value(key, method, key_value)
          merged_hash[key] = key_value

        # Setting the key failed for some reason.
        else # rubocop:disable Style/EmptyElse
          # Print nothing that hasn't already been printed.
        end
      end

      #Debug.pp yaml_file_hash
      #Debug.pp server_specific_hash
      #Debug.pp merged_hash

      @bot_runs_on_server_id = if @is_test_server && !@test_server_id.nil_empty_or_ltzero?
                                 @test_server_id
                               elsif !@is_test_server && !@live_server_id.nil_empty_or_ltzero?
                                 @live_server_id
                               else
                                 -1
                               end
      #
      server_specific_hash = server_specific_hash[@bot_runs_on_server_id.to_s.to_sym]

      if server_specific_hash.nil?
        warn_str = Debug.msg(+'No configurations for this specific server. Is this intentional?', 'yellow') << ' ' <<
                   Debug.msg(+'@live_id', 'cyan')   << ' = ' << Debug.msg(@live_server_id.to_s, 'green')  << ', ' <<
                   Debug.msg(+'@test_id', 'cyan')   << ' = ' << Debug.msg(@test_server_id.to_s, 'green')  << ', ' <<
                   Debug.msg(+'@IS_TEST', 'yellow') << ' = ' << Debug.msg(@is_test_server.to_s, 'yellow') << ''
        puts warn_str
        Debug.add_message(+'WARNING: ' << warn_str)

        return merged_hash
      end

      server_specific_hash.each_key do |key|
        method = nil
        key_upcased = key.to_s.upcase.to_sym
        key_value = server_specific_hash[key]

        if @valid_keys.include?(key_upcased)
          method = @valid_keys[key_upcased][0]
          #yaml_file_hash[key_upcased] = key_value
        else
          #yaml_file_hash[key] = key_value
          Debug.warn(+'Unknown/unparsed key: ' << key.to_s)
          Debug.add_message(+'WARNING: Unknown/unparsed key: ' << key.to_s)
        end

        if method.nil?
          puts(+'Not assigning the key-value: ' << key.to_s) if @debug
        elsif !assign_class_method_value(key, method, key_value)
          # Print nothing that hasn't already been printed.
        else
          merged_hash[key] = key_value
        end
      end

      #Debug.pp yaml_file_hash
      #Debug.pp server_specific_hash
      #Debug.pp merged_hash

      #return merged_hash
      merged_hash
    end

  end
  #class Config
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

  Modifier  Meaning
  %q[ ]     Non-interpolated String (except for \\ \[ and \])
  %Q[ ]     Interpolated String (default)
  %r[ ]     Interpolated Regexp (flags can appear after the closing delimiter)
  %i[ ]     Non-interpolated Array of symbols, separated by whitespace (after Ruby 2.0)
  %I[ ]     Interpolated Array of symbols, separated by whitespace (after Ruby 2.0)
  %w[ ]     Non-interpolated Array of words, separated by whitespace
  %W[ ]     Interpolated Array of words, separated by whitespace
  %x[ ]     Interpolated shell command
  %s[ ]     Non-interpolated symbol

  «tekst ‘ord’ tekst»
  “text ‘word’ text”
  Tankestrek, kort –  og lang —
  Tre punktum …
=end
=begin
  C1 Controls and Latin-1 Supplement
            0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+008x
    U+009x
    U+00Ax      ¡   ¢   £   ¤   ¥   ¦   §   ¨   ©   ª   «   ¬       ®   ¯
    U+00Bx  °   ±   ²   ³   ´   µ   ¶   ·   ¸   ¹   º   »   ¼   ½   ¾   ¿
    U+00Cx  À   Á   Â   Ã   Ä   Å   Æ   Ç   È   É   Ê   Ë   Ì   Í   Î   Ï
    U+00Dx  Ð   Ñ   Ò   Ó   Ô   Õ   Ö   ×   Ø   Ù   Ú   Û   Ü   Ý   Þ   ß
    U+00Ex  à   á   â   ã   ä   å   æ   ç   è   é   ê   ë   ì   í   î   ï
    U+00Fx  ð   ñ   ò   ó   ô   õ   ö   ÷   ø   ù   ú   û   ü   ý   þ   ÿ

  Latin Extended-A
            0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+010x  Ā   ā   Ă   ă   Ą   ą   Ć   ć   Ĉ   ĉ   Ċ   ċ   Č   č   Ď   ď
    U+011x  Đ   đ   Ē   ē   Ĕ   ĕ   Ė   ė   Ę   ę   Ě   ě   Ĝ   ĝ   Ğ   ğ
    U+012x  Ġ   ġ   Ģ   ģ   Ĥ   ĥ   Ħ   ħ   Ĩ   ĩ   Ī   ī   Ĭ   ĭ   Į   į
    U+013x  İ   ı   Ĳ   ĳ   Ĵ   ĵ   Ķ   ķ   ĸ   Ĺ   ĺ   Ļ   ļ   Ľ   ľ   Ŀ
    U+014x  ŀ   Ł   ł   Ń   ń   Ņ   ņ   Ň   ň   ŉ   Ŋ   ŋ   Ō   ō   Ŏ   ŏ
    U+015x  Ő   ő   Œ   œ   Ŕ   ŕ   Ŗ   ŗ   Ř   ř   Ś   ś   Ŝ   ŝ   Ş   ş
    U+016x  Š   š   Ţ   ţ   Ť   ť   Ŧ   ŧ   Ũ   ũ   Ū   ū   Ŭ   ŭ   Ů   ů
    U+017x  Ű   ű   Ų   ų   Ŵ   ŵ   Ŷ   ŷ   Ÿ   Ź   ź   Ż   ż   Ž   ž   ſ

  Latin Extended-B
            0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+018x  ƀ   Ɓ   Ƃ   ƃ   Ƅ   ƅ   Ɔ   Ƈ   ƈ   Ɖ   Ɗ   Ƌ   ƌ   ƍ   Ǝ   Ə
    U+019x  Ɛ   Ƒ   ƒ   Ɠ   Ɣ   ƕ   Ɩ   Ɨ   Ƙ   ƙ   ƚ   ƛ   Ɯ   Ɲ   ƞ   Ɵ
    U+01Ax  Ơ   ơ   Ƣ   ƣ   Ƥ   ƥ   Ʀ   Ƨ   ƨ   Ʃ   ƪ   ƫ   Ƭ   ƭ   Ʈ   Ư
    U+01Bx  ư   Ʊ   Ʋ   Ƴ   ƴ   Ƶ   ƶ   Ʒ   Ƹ   ƹ   ƺ   ƻ   Ƽ   ƽ   ƾ   ƿ
    U+01Cx  ǀ   ǁ   ǂ   ǃ   Ǆ   ǅ   ǆ   Ǉ   ǈ   ǉ   Ǌ   ǋ   ǌ   Ǎ   ǎ   Ǐ
    U+01Dx  ǐ   Ǒ   ǒ   Ǔ   ǔ   Ǖ   ǖ   Ǘ   ǘ   Ǚ   ǚ   Ǜ   ǜ   ǝ   Ǟ   ǟ
    U+01Ex  Ǡ   ǡ   Ǣ   ǣ   Ǥ   ǥ   Ǧ   ǧ   Ǩ   ǩ   Ǫ   ǫ   Ǭ   ǭ   Ǯ   ǯ
    U+01Fx  ǰ   Ǳ   ǲ   ǳ   Ǵ   ǵ   Ƕ   Ƿ   Ǹ   ǹ   Ǻ   ǻ   Ǽ   ǽ   Ǿ   ǿ
    U+020x  Ȁ   ȁ   Ȃ   ȃ   Ȅ   ȅ   Ȇ   ȇ   Ȉ   ȉ   Ȋ   ȋ   Ȍ   ȍ   Ȏ   ȏ
    U+021x  Ȑ   ȑ   Ȓ   ȓ   Ȕ   ȕ   Ȗ   ȗ   Ș   ș   Ț   ț   Ȝ   ȝ   Ȟ   ȟ
    U+022x  Ƞ   ȡ   Ȣ   ȣ   Ȥ   ȥ   Ȧ   ȧ   Ȩ   ȩ   Ȫ   ȫ   Ȭ   ȭ   Ȯ   ȯ
    U+023x  Ȱ   ȱ   Ȳ   ȳ   ȴ   ȵ   ȶ   ȷ   ȸ   ȹ   Ⱥ   Ȼ   ȼ   Ƚ   Ⱦ   ȿ
    U+024x  ɀ   Ɂ   ɂ   Ƀ   Ʉ   Ʌ   Ɇ   ɇ   Ɉ   ɉ   Ɋ   ɋ   Ɍ   ɍ   Ɏ   ɏ

  Latin Extended Additional
            0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+1E0x  Ḁ   ḁ   Ḃ   ḃ   Ḅ   ḅ   Ḇ   ḇ   Ḉ   ḉ   Ḋ   ḋ   Ḍ   ḍ   Ḏ   ḏ
    U+1E1x  Ḑ   ḑ   Ḓ   ḓ   Ḕ   ḕ   Ḗ   ḗ   Ḙ   ḙ   Ḛ   ḛ   Ḝ   ḝ   Ḟ   ḟ
    U+1E2x  Ḡ   ḡ   Ḣ   ḣ   Ḥ   ḥ   Ḧ   ḧ   Ḩ   ḩ   Ḫ   ḫ   Ḭ   ḭ   Ḯ   ḯ
    U+1E3x  Ḱ   ḱ   Ḳ   ḳ   Ḵ   ḵ   Ḷ   ḷ   Ḹ   ḹ   Ḻ   ḻ   Ḽ   ḽ   Ḿ   ḿ
    U+1E4x  Ṁ   ṁ   Ṃ   ṃ   Ṅ   ṅ   Ṇ   ṇ   Ṉ   ṉ   Ṋ   ṋ   Ṍ   ṍ   Ṏ   ṏ
    U+1E5x  Ṑ   ṑ   Ṓ   ṓ   Ṕ   ṕ   Ṗ   ṗ   Ṙ   ṙ   Ṛ   ṛ   Ṝ   ṝ   Ṟ   ṟ
    U+1E6x  Ṡ   ṡ   Ṣ   ṣ   Ṥ   ṥ   Ṧ   ṧ   Ṩ   ṩ   Ṫ   ṫ   Ṭ   ṭ   Ṯ   ṯ
    U+1E7x  Ṱ   ṱ   Ṳ   ṳ   Ṵ   ṵ   Ṷ   ṷ   Ṹ   ṹ   Ṻ   ṻ   Ṽ   ṽ   Ṿ   ṿ
    U+1E8x  Ẁ   ẁ   Ẃ   ẃ   Ẅ   ẅ   Ẇ   ẇ   Ẉ   ẉ   Ẋ   ẋ   Ẍ   ẍ   Ẏ   ẏ
    U+1E9x  Ẑ   ẑ   Ẓ   ẓ   Ẕ   ẕ   ẖ   ẗ   ẘ   ẙ   ẚ   ẛ   ẜ   ẝ   ẞ   ẟ
    U+1EAx  Ạ   ạ   Ả   ả   Ấ   ấ   Ầ   ầ   Ẩ   ẩ   Ẫ   ẫ   Ậ   ậ   Ắ   ắ
    U+1EBx  Ằ   ằ   Ẳ   ẳ   Ẵ   ẵ   Ặ   ặ   Ẹ   ẹ   Ẻ   ẻ   Ẽ   ẽ   Ế   ế
    U+1ECx  Ề   ề   Ể   ể   Ễ   ễ   Ệ   ệ   Ỉ   ỉ   Ị   ị   Ọ   ọ   Ỏ   ỏ
    U+1EDx  Ố   ố   Ồ   ồ   Ổ   ổ   Ỗ   ỗ   Ộ   ộ   Ớ   ớ   Ờ   ờ   Ở   ở
    U+1EEx  Ỡ   ỡ   Ợ   ợ   Ụ   ụ   Ủ   ủ   Ứ   ứ   Ừ   ừ   Ử   ử   Ữ   ữ
    U+1EFx  Ự   ự   Ỳ   ỳ   Ỵ   ỵ   Ỷ   ỷ   Ỹ   ỹ   Ỻ   ỻ   Ỽ   ỽ   Ỿ   ỿ

  https://no.wikipedia.org/wiki/Anf%C3%B8rselstegn
    norsk   «ord»
            «tekst ‘ord’ tekst»
            «tekst «ord» tekst»

    svensk  ”ord”
            »ord«
            »ord»
            ”text ’ord’ text”
            »text ’ord’ text»

    dansk   »ord«
            „ord“
            »tekst »ord« tekst«
            „tekst „ord“ tekst“

    engelsk “word”
            ‘word’
            “text ‘word’ text”
            ‘text “word” text’

    tysk    „Wort“
            »Wort«
            „Text ‚Wort‘ Text“
            »Text ›Wort‹ Text«
            «Text ‹Wort› Text»   Vanligst i hele Sveits og i Liechtenstein.

    fransk  « mot »
            « texte « mot » texte »
            « texte “mot” texte »

    spansk  «palabra»
            «texto ’palabra’ texto»

    italiensk   «parola»
                «testo «parola» testo»

    Anführungszeichen in verschiedenen Sprachen Sprache
                Standard                Alternative
                primär  sekundär2   primär  sekundär2
      Afrikaans     „…”     ‚…’
      Albanisch     «…»     ‹…›     “…„     ‘…‚
      Arabisch  «…»     ‹…›     “…”     ‘…’
      Armenisch     «…»     „…“     "…"     “…”
      Baskisch  «…»     ‹…›
      Brasilianisch     “…”     «…»
      Bulgarisch    „…“     ‚…‘
      Chinesisch (China)    “…”     ‘…’
      Chinesisch (Taiwan)   「…」     『…』
      Dänisch   „…“     ‚…‘     »…«     ›…‹
      Deutsch3  „…“     ‚…‘     »…«     ›…‹
      Englisch (UK)*    ‘…’     “…”     “…”     ‘…’
      Englisch (USA)*   “…”     ‘…’     ‘…’     “…”
      Estnisch  „…”     „…”
      Finnisch  ”…”     ’…’     »…»     ’…’
      Französisch   « … »   ‹ … ›1  “ … ”   ‘ … ’
      Georgisch     „…“         «…»
      Griechisch    «…»     “…”
      Grönländisch
      Hebräisch     “…”     «…»     “…„
      Indonesisch   ”…”     ’…’
      Irisch    “…”     ‘…’
      Isländisch    „…“     ‚…‘
      Italienisch   «…»         “…”     ‘…’
      Japanisch     「…」     『…』
      Katalanisch   «…»     “…”     “…”     ‘…’
      Koreanisch    “…”     ‘…’
      Kroatisch     „…”         »…«     ›…‹
      Lettisch  „…“     ‚…‘     "…"     '…'
      Litauisch     „…“     ‚…‘     "…"     '…'
      Niederländisch    “…”     ‘…’     „…”     ‚…’
      Norwegisch    «…»     ‘…’     „...”   ’...’ oder ,...’
      Polnisch  „…”     «…»     »…«
      Portugiesisch     «…»     “…”     “…”     ‘…’
      Rumänisch     „…”     «…»
      Russisch  «…»     „…“     “…”     “…”
      Schwedisch    ”…”     ’…’     »…»     ›…›
      Schweiz   «…»     ‹…›     „…“ oder “…”    ‚…‘ oder ‘…’
      Serbisch  „…“     ‚…‘     »…«     ›…‹
      Slowakisch    „…“     ‚…‘     »…«     ›…‹
      Slowenisch    „…“     ‚…‘     »…«     ›…‹
      Sorbisch  „…“     ‚…‘
      Spanisch  «…»     ‹…›1    “…”     ‘…’
      Thailändisch  “…”     ‘…’
      Tschechisch   „…“     ‚…‘     »…«     ›…‹
      Türkisch  “…”     ‘…’     "…"     '…'
      Ukrainisch    «…»     „…“     „…“
      Ungarisch     „…”         »…«
      Weißrussisch  «…»     „…“     „…“

  https://no.wikipedia.org/wiki/Hardt_mellomrom
    Koder

    I Unicode er det U+00A0 og kalles «No-Break Space».
    I ISO/IEC 8859 er det 0xA0.
    I KOI8-R er det 0x9A.
    I EBCDIC er det 0x41 og kalles «No-Break Space».
    I noen versjoner av utvidet ASCII blir tegn 255 (0xFF) et hardt mellomrom.
    I HTML skrives det som &nbsp;, &#160; eller &#xa0;.
    I TeX brukes en tilde (~) for å få frem tegnet.

    Tekstbehandlere kan bruke forskjellige metoder for å få frem andre versjoner av tegnet på tastaturet. Eksempler:

    Standardkombinasjonen i Microsoft Word er Ctrl+Shift+MELLOMROM.
    I WordPerfect kalles tegnet «hard space», og snarveien er Ctrl+MELLOMROM.
    I OpenOffice.org er snarveien Ctrl+MELLOMROM.
    I Vims insert mode, bruk Ctrl+K N S.
    I Mac OS er snarveien TILVALG+MELLOMROM.
    Det kan virke som om Microsoft PowerPoint ikke har noen snarvei for å få frem tegnet slik som Words Ctrl+Shift+MELLOMROM. Likevel fungerer to metoder; «Alt+0160» eller å bruke Sett inn → Symbol...-boksen.

  General Punctuation
            0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+201x  ‐       ‒   –   —   ―   ‖   ‗   ‘   ’   ‚   ‛   “   ”   „   ‟
    U+202x  †   ‡   •   ‣   ․   ‥   …   ‧
    U+203x  ‰   ‱   ′   ″   ‴   ‵   ‶   ‷   ‸   ‹   ›   ※   ‼   ‽   ‾   ‿
    U+204x  ⁀   ⁁   ⁂   ⁃   ⁄   ⁅   ⁆   ⁇   ⁈   ⁉   ⁊   ⁋   ⁌   ⁍   ⁎   ⁏
    U+205x  ⁐   ⁑   ⁒   ⁓   ⁔   ⁕   ⁖   ⁗   ⁘   ⁙   ⁚   ⁛   ⁜   ⁝   ⁞
    U+206x      ƒ() ×   ,   +

  Arrows
    https://en.wikipedia.org/wiki/Arrow_(symbol)
            0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+219x  ←   ↑   →   ↓   ↔   ↕   ↖   ↗   ↘   ↙   ↚   ↛   ↜   ↝   ↞   ↟
    U+21Ax  ↠   ↡   ↢   ↣   ↤   ↥   ↦   ↧   ↨   ↩   ↪   ↫   ↬   ↭   ↮   ↯
    U+21Bx  ↰   ↱   ↲   ↳   ↴   ↵   ↶   ↷   ↸   ↹   ↺   ↻   ↼   ↽   ↾   ↿
    U+21Cx  ⇀   ⇁   ⇂   ⇃   ⇄   ⇅   ⇆   ⇇   ⇈   ⇉   ⇊   ⇋   ⇌   ⇍   ⇎   ⇏
    U+21Dx  ⇐   ⇑   ⇒   ⇓   ⇔   ⇕   ⇖   ⇗   ⇘   ⇙   ⇚   ⇛   ⇜   ⇝   ⇞   ⇟
    U+21Ex  ⇠   ⇡   ⇢   ⇣   ⇤   ⇥   ⇦   ⇧   ⇨   ⇩   ⇪   ⇫   ⇬   ⇭   ⇮   ⇯
    U+21Fx  ⇰   ⇱   ⇲   ⇳   ⇴   ⇵   ⇶   ⇷   ⇸   ⇹   ⇺   ⇻   ⇼   ⇽   ⇾   ⇿

  Miscellaneous Symbols and Arrows
            0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+2B0x  ⬀   ⬁   ⬂   ⬃   ⬄   ⬅   ⬆   ⬇   ⬈   ⬉   ⬊   ⬋   ⬌   ⬍   ⬎   ⬏
    U+2B1x  ⬐   ⬑   ⬒   ⬓   ⬔   ⬕   ⬖   ⬗   ⬘   ⬙   ⬚   ⬛   ⬜   ⬝   ⬞   ⬟
    U+2B2x  ⬠   ⬡   ⬢   ⬣   ⬤   ⬥   ⬦   ⬧   ⬨   ⬩   ⬪   ⬫   ⬬   ⬭   ⬮   ⬯
    U+2B3x  ⬰   ⬱   ⬲   ⬳   ⬴   ⬵   ⬶   ⬷   ⬸   ⬹   ⬺   ⬻   ⬼   ⬽   ⬾   ⬿
    U+2B4x  ⭀   ⭁   ⭂   ⭃   ⭄   ⭅   ⭆   ⭇   ⭈   ⭉   ⭊   ⭋   ⭌   ⭍   ⭎   ⭏
    U+2B5x  ⭐   ⭑   ⭒   ⭓   ⭔   ⭕   ⭖   ⭗   ⭘   ⭙   ⭚   ⭛   ⭜   ⭝   ⭞   ⭟
    U+2B6x  ⭠   ⭡   ⭢   ⭣   ⭤   ⭥   ⭦   ⭧   ⭨   ⭩   ⭪   ⭫   ⭬   ⭭   ⭮   ⭯
    U+2B7x  ⭰   ⭱   ⭲   ⭳           ⭶   ⭷   ⭸   ⭹   ⭺   ⭻   ⭼   ⭽   ⭾   ⭿
    U+2B8x  ⮀   ⮁   ⮂   ⮃   ⮄   ⮅   ⮆   ⮇   ⮈   ⮉   ⮊   ⮋   ⮌   ⮍   ⮎   ⮏
    U+2B9x  ⮐   ⮑   ⮒   ⮓   ⮔   ⮕           ⮘   ⮙   ⮚   ⮛   ⮜   ⮝   ⮞   ⮟
    U+2BAx  ⮠   ⮡   ⮢   ⮣   ⮤   ⮥   ⮦   ⮧   ⮨   ⮩   ⮪   ⮫   ⮬   ⮭   ⮮   ⮯
    U+2BBx  ⮰   ⮱   ⮲   ⮳   ⮴   ⮵   ⮶   ⮷   ⮸   ⮹               ⮽   ⮾   ⮿
    U+2BCx  ⯀   ⯁   ⯂   ⯃   ⯄   ⯅   ⯆   ⯇   ⯈       ⯊   ⯋   ⯌   ⯍   ⯎   ⯏
    U+2BDx  ⯐   ⯑
    U+2BEx                                                  ⯬   ⯭   ⯮   ⯯

  Miscellaneous Symbols
            0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+260x  ☀   ☁   ☂   ☃   ☄   ★   ☆   ☇   ☈   ☉   ☊   ☋   ☌   ☍   ☎   ☏
    U+261x  ☐   ☑   ☒   ☓   ☔   ☕   ☖   ☗   ☘   ☙   ☚   ☛   ☜   ☝   ☞   ☟
    U+262x  ☠   ☡   ☢   ☣   ☤   ☥   ☦   ☧   ☨   ☩   ☪   ☫   ☬   ☭   ☮   ☯
    U+263x  ☰   ☱   ☲   ☳   ☴   ☵   ☶   ☷   ☸   ☹   ☺   ☻   ☼   ☽   ☾   ☿
    U+264x  ♀   ♁   ♂   ♃   ♄   ♅   ♆   ♇   ♈   ♉   ♊   ♋   ♌   ♍   ♎   ♏
    U+265x  ♐   ♑   ♒   ♓   ♔   ♕   ♖   ♗   ♘   ♙   ♚   ♛   ♜   ♝   ♞   ♟
    U+266x  ♠   ♡   ♢   ♣   ♤   ♥   ♦   ♧   ♨   ♩   ♪   ♫   ♬   ♭   ♮   ♯
    U+267x  ♰   ♱   ♲   ♳   ♴   ♵   ♶   ♷   ♸   ♹   ♺   ♻   ♼   ♽   ♾   ♿
    U+268x  ⚀   ⚁   ⚂   ⚃   ⚄   ⚅   ⚆   ⚇   ⚈   ⚉   ⚊   ⚋   ⚌   ⚍   ⚎   ⚏
    U+269x  ⚐   ⚑   ⚒   ⚓   ⚔   ⚕   ⚖   ⚗   ⚘   ⚙   ⚚   ⚛   ⚜   ⚝   ⚞   ⚟
    U+26Ax  ⚠   ⚡   ⚢   ⚣   ⚤   ⚥   ⚦   ⚧   ⚨   ⚩   ⚪   ⚫   ⚬   ⚭   ⚮   ⚯
    U+26Bx  ⚰   ⚱   ⚲   ⚳   ⚴   ⚵   ⚶   ⚷   ⚸   ⚹   ⚺   ⚻   ⚼   ⚽   ⚾   ⚿
    U+26Cx  ⛀   ⛁   ⛂   ⛃   ⛄   ⛅   ⛆   ⛇   ⛈   ⛉   ⛊   ⛋   ⛌   ⛍   ⛎   ⛏
    U+26Dx  ⛐   ⛑   ⛒   ⛓   ⛔   ⛕   ⛖   ⛗   ⛘   ⛙   ⛚   ⛛   ⛜   ⛝   ⛞   ⛟
    U+26Ex  ⛠   ⛡   ⛢   ⛣   ⛤   ⛥   ⛦   ⛧   ⛨   ⛩   ⛪   ⛫   ⛬   ⛭   ⛮   ⛯
    U+26Fx  ⛰   ⛱   ⛲   ⛳   ⛴   ⛵   ⛶   ⛷   ⛸   ⛹   ⛺   ⛻   ⛼   ⛽   ⛾   ⛿

  Dingbats
            0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+270x  ✀   ✁   ✂   ✃   ✄   ✅   ✆   ✇   ✈   ✉   ✊   ✋   ✌   ✍   ✎   ✏
    U+271x  ✐   ✑   ✒   ✓   ✔   ✕   ✖   ✗   ✘   ✙   ✚   ✛   ✜   ✝   ✞   ✟
    U+272x  ✠   ✡   ✢   ✣   ✤   ✥   ✦   ✧   ✨   ✩   ✪   ✫   ✬   ✭   ✮   ✯
    U+273x  ✰   ✱   ✲   ✳   ✴   ✵   ✶   ✷   ✸   ✹   ✺   ✻   ✼   ✽   ✾   ✿
    U+274x  ❀   ❁   ❂   ❃   ❄   ❅   ❆   ❇   ❈   ❉   ❊   ❋   ❌   ❍   ❎   ❏
    U+275x  ❐   ❑   ❒   ❓   ❔   ❕   ❖   ❗   ❘   ❙   ❚   ❛   ❜   ❝   ❞   ❟
    U+276x  ❠   ❡   ❢   ❣   ❤   ❥   ❦   ❧   ❨   ❩   ❪   ❫   ❬   ❭   ❮   ❯
    U+277x  ❰   ❱   ❲   ❳   ❴   ❵   ❶   ❷   ❸   ❹   ❺   ❻   ❼   ❽   ❾   ❿
    U+278x  ➀   ➁   ➂   ➃   ➄   ➅   ➆   ➇   ➈   ➉   ➊   ➋   ➌   ➍   ➎   ➏
    U+279x  ➐   ➑   ➒   ➓   ➔   ➕   ➖   ➗   ➘   ➙   ➚   ➛   ➜   ➝   ➞   ➟
    U+27Ax  ➠   ➡   ➢   ➣   ➤   ➥   ➦   ➧   ➨   ➩   ➪   ➫   ➬   ➭   ➮   ➯
    U+27Bx  ➰   ➱   ➲   ➳   ➴   ➵   ➶   ➷   ➸   ➹   ➺   ➻   ➼   ➽   ➾   ➿

  Miscellaneous Symbols and Pictographs
              0     1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+1F30x     🌀   🌁   🌂   🌃   🌄   🌅   🌆   🌇   🌈   🌉   🌊   🌋   🌌   🌍   🌎   🌏
    U+1F31x     🌐   🌑   🌒   🌓   🌔   🌕   🌖   🌗   🌘   🌙   🌚   🌛   🌜   🌝   🌞   🌟
    U+1F32x     🌠   🌡   🌢   🌣   🌤   🌥   🌦   🌧   🌨   🌩   🌪   🌫   🌬   🌭   🌮   🌯
    U+1F33x     🌰   🌱   🌲   🌳   🌴   🌵   🌶   🌷   🌸   🌹   🌺   🌻   🌼   🌽   🌾   🌿
    U+1F34x     🍀   🍁   🍂   🍃   🍄   🍅   🍆   🍇   🍈   🍉   🍊   🍋   🍌   🍍   🍎   🍏
    U+1F35x     🍐   🍑   🍒   🍓   🍔   🍕   🍖   🍗   🍘   🍙   🍚   🍛   🍜   🍝   🍞   🍟
    U+1F36x     🍠   🍡   🍢   🍣   🍤   🍥   🍦   🍧   🍨   🍩   🍪   🍫   🍬   🍭   🍮   🍯
    U+1F37x     🍰   🍱   🍲   🍳   🍴   🍵   🍶   🍷   🍸   🍹   🍺   🍻   🍼   🍽   🍾   🍿
    U+1F38x     🎀   🎁   🎂   🎃   🎄   🎅   🎆   🎇   🎈   🎉   🎊   🎋   🎌   🎍   🎎   🎏
    U+1F39x     🎐   🎑   🎒   🎓   🎔   🎕   🎖   🎗   🎘   🎙   🎚   🎛   🎜   🎝   🎞   🎟
    U+1F3Ax     🎠   🎡   🎢   🎣   🎤   🎥   🎦   🎧   🎨   🎩   🎪   🎫   🎬   🎭   🎮   🎯
    U+1F3Bx     🎰   🎱   🎲   🎳   🎴   🎵   🎶   🎷   🎸   🎹   🎺   🎻   🎼   🎽   🎾   🎿
    U+1F3Cx     🏀   🏁   🏂   🏃   🏄   🏅   🏆   🏇   🏈   🏉   🏊   🏋   🏌   🏍   🏎   🏏
    U+1F3Dx     🏐   🏑   🏒   🏓   🏔   🏕   🏖   🏗   🏘   🏙   🏚   🏛   🏜   🏝   🏞   🏟
    U+1F3Ex     🏠   🏡   🏢   🏣   🏤   🏥   🏦   🏧   🏨   🏩   🏪   🏫   🏬   🏭   🏮   🏯
    U+1F3Fx     🏰   🏱   🏲   🏳   🏴   🏵   🏶   🏷   🏸   🏹   🏺   🏻   🏼   🏽   🏾   🏿
    U+1F40x     🐀   🐁   🐂   🐃   🐄   🐅   🐆   🐇   🐈   🐉   🐊   🐋   🐌   🐍   🐎   🐏
    U+1F41x     🐐   🐑   🐒   🐓   🐔   🐕   🐖   🐗   🐘   🐙   🐚   🐛   🐜   🐝   🐞   🐟
    U+1F42x     🐠   🐡   🐢   🐣   🐤   🐥   🐦   🐧   🐨   🐩   🐪   🐫   🐬   🐭   🐮   🐯
    U+1F43x     🐰   🐱   🐲   🐳   🐴   🐵   🐶   🐷   🐸   🐹   🐺   🐻   🐼   🐽   🐾   🐿
    U+1F44x     👀   👁   👂   👃   👄   👅   👆   👇   👈   👉   👊   👋   👌   👍   👎   👏
    U+1F45x     👐   👑   👒   👓   👔   👕   👖   👗   👘   👙   👚   👛   👜   👝   👞   👟
    U+1F46x     👠   👡   👢   👣   👤   👥   👦   👧   👨   👩   👪   👫   👬   👭   👮   👯
    U+1F47x     👰   👱   👲   👳   👴   👵   👶   👷   👸   👹   👺   👻   👼   👽   👾   👿
    U+1F48x     💀   💁   💂   💃   💄   💅   💆   💇   💈   💉   💊   💋   💌   💍   💎   💏
    U+1F49x     💐   💑   💒   💓   💔   💕   💖   💗   💘   💙   💚   💛   💜   💝   💞   💟
    U+1F4Ax     💠   💡   💢   💣   💤   💥   💦   💧   💨   💩   💪   💫   💬   💭   💮   💯
    U+1F4Bx     💰   💱   💲   💳   💴   💵   💶   💷   💸   💹   💺   💻   💼   💽   💾   💿
    U+1F4Cx     📀   📁   📂   📃   📄   📅   📆   📇   📈   📉   📊   📋   📌   📍   📎   📏
    U+1F4Dx     📐   📑   📒   📓   📔   📕   📖   📗   📘   📙   📚   📛   📜   📝   📞   📟
    U+1F4Ex     📠   📡   📢   📣   📤   📥   📦   📧   📨   📩   📪   📫   📬   📭   📮   📯
    U+1F4Fx     📰   📱   📲   📳   📴   📵   📶   📷   📸   📹   📺   📻   📼   📽   📾   📿
    U+1F50x     🔀   🔁   🔂   🔃   🔄   🔅   🔆   🔇   🔈   🔉   🔊   🔋   🔌   🔍   🔎   🔏
    U+1F51x     🔐   🔑   🔒   🔓   🔔   🔕   🔖   🔗   🔘   🔙   🔚   🔛   🔜   🔝   🔞   🔟
    U+1F52x     🔠   🔡   🔢   🔣   🔤   🔥   🔦   🔧   🔨   🔩   🔪   🔫   🔬   🔭   🔮   🔯
    U+1F53x     🔰   🔱   🔲   🔳   🔴   🔵   🔶   🔷   🔸   🔹   🔺   🔻   🔼   🔽   🔾   🔿
    U+1F54x     🕀   🕁   🕂   🕃   🕄   🕅   🕆   🕇   🕈   🕉   🕊   🕋   🕌   🕍   🕎   🕏
    U+1F55x     🕐   🕑   🕒   🕓   🕔   🕕   🕖   🕗   🕘   🕙   🕚   🕛   🕜   🕝   🕞   🕟
    U+1F56x     🕠   🕡   🕢   🕣   🕤   🕥   🕦   🕧   🕨   🕩   🕪   🕫   🕬   🕭   🕮   🕯
    U+1F57x     🕰   🕱   🕲   🕳   🕴   🕵   🕶   🕷   🕸   🕹   🕺   🕻   🕼   🕽   🕾   🕿
    U+1F58x     🖀   🖁   🖂   🖃   🖄   🖅   🖆   🖇   🖈   🖉   🖊   🖋   🖌   🖍   🖎   🖏
    U+1F59x     🖐   🖑   🖒   🖓   🖔   🖕   🖖   🖗   🖘   🖙   🖚   🖛   🖜   🖝   🖞   🖟
    U+1F5Ax     🖠   🖡   🖢   🖣   🖤   🖥   🖦   🖧   🖨   🖩   🖪   🖫   🖬   🖭   🖮   🖯
    U+1F5Bx     🖰   🖱   🖲   🖳   🖴   🖵   🖶   🖷   🖸   🖹   🖺   🖻   🖼   🖽   🖾   🖿
    U+1F5Cx     🗀   🗁   🗂   🗃   🗄   🗅   🗆   🗇   🗈   🗉   🗊   🗋   🗌   🗍   🗎   🗏
    U+1F5Dx     🗐   🗑   🗒   🗓   🗔   🗕   🗖   🗗   🗘   🗙   🗚   🗛   🗜   🗝   🗞   🗟
    U+1F5Ex     🗠   🗡   🗢   🗣   🗤   🗥   🗦   🗧   🗨   🗩   🗪   🗫   🗬   🗭   🗮   🗯
    U+1F5Fx     🗰   🗱   🗲   🗳   🗴   🗵   🗶   🗷   🗸   🗹   🗺   🗻   🗼   🗽   🗾   🗿

  Emoticons
              0     1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+1F60x     😀   😁   😂   😃   😄   😅   😆   😇   😈   😉   😊   😋   😌   😍   😎   😏
    U+1F61x     😐   😑   😒   😓   😔   😕   😖   😗   😘   😙   😚   😛   😜   😝   😞   😟
    U+1F62x     😠   😡   😢   😣   😤   😥   😦   😧   😨   😩   😪   😫   😬   😭   😮   😯
    U+1F63x     😰   😱   😲   😳   😴   😵   😶   😷   😸   😹   😺   😻   😼   😽   😾   😿
    U+1F64x     🙀   🙁   🙂   🙃   🙄   🙅   🙆   🙇   🙈   🙉   🙊   🙋   🙌   🙍   🙎   🙏

  Supplemental Symbols and Pictographs
              0     1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    U+1F90x
    U+1F91x     🤐   🤑   🤒   🤓   🤔   🤕   🤖   🤗   🤘   🤙   🤚   🤛   🤜   🤝   🤞
    U+1F92x     🤠   🤡   🤢   🤣   🤤   🤥   🤦   🤧
    U+1F93x     🤰           🤳   🤴   🤵   🤶   🤷   🤸   🤹   🤺   🤻   🤼   🤽   🤾
    U+1F94x     🥀   🥁   🥂   🥃   🥄   🥅   🥆   🥇   🥈   🥉   🥊   🥋
    U+1F95x     🥐   🥑   🥒   🥓   🥔   🥕   🥖   🥗   🥘   🥙   🥚   🥛   🥜   🥝   🥞
    U+1F96x
    U+1F97x
    U+1F98x     🦀   🦁   🦂   🦃   🦄   🦅   🦆   🦇   🦈   🦉   🦊   🦋   🦌   🦍   🦎   🦏
    U+1F99x     🦐   🦑
    U+1F9Ax
    U+1F9Bx
    U+1F9Cx     🧀
    U+1F9Dx
    U+1F9Ex
    U+1F9Fx
=end



