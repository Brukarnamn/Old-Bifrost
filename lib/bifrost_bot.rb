#!/usr/bin/env ruby -wW2
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

# Global variables.
ROOT_DIR     = ''
SCRIPT_NAME  = ''
BOT_CONFIG   = nil
BOT_OBJ      = nil
BOT_CACHE    = nil
RATE_LIMITER = nil
DICTIONARY_CACHE = nil

# Bifrost / Askeladden v2
# The basic skeleton.
module BifrostBot
  private

  # The name of this script.
  SCRIPT_NAME = File.basename(__FILE__).freeze
  #SCRIPT_NAME = $0

  # The root folder of the bot script.
  # d:/ruby/discordbot/lib/bifrost_bot.rb
  #   → d:/ruby/discordbot/lib
  #   → d:/ruby/discordbot
  ROOT_DIR = File.dirname(File.dirname(File.expand_path(__FILE__))).freeze

  private_constant :SCRIPT_NAME, :ROOT_DIR
  #puts SCRIPT_NAME
  #puts ROOT_DIR

  # Modify the load path.
  $LOAD_PATH.unshift(ROOT_DIR + '/lib/')
  $LOAD_PATH.unshift(ROOT_DIR + '/lib/discordrb-master/lib/')
  #puts $LOAD_PATH

  # Just to make sure all the required modules and gems are present.
  # And with a better idea of which ones might be missing.
  begin
    # Turn off warnings when loading the following modules/gems
    # since we have no control over the code in them.
    $VERBOSE = false

    # Use the developer/non-stable version of discordrb since it is more up-to-date and has slightly more features. But possibly more bugs.
    require 'awesome_print'
    require 'discordrb'
    require 'net/http'
    require 'hpricot'
    #require 'nokogiri'
    #require 'rexml/document'
    require 'time'
    require 'uri'
    #require 'sqlite3'

    # Turn warnings back on for the following modules/gems.
    $VERBOSE = true

    #require_relative 'debug'
    require 'debug'
    require 'bifrost_bot/script_options'
    require 'bifrost_bot/config'
    require 'bifrost_bot/data_storage'

    Debug.colour_test
  end



  public

  #class << self
  #  public
  #
  #  def script_name
  #    SCRIPT_NAME
  #  end
  #
  #  def root_dir
  #    ROOT_DIR
  #  end
  #end



  private

  # Initialize the config class and make a new object that
  # contains all the configuration settings.
  begin
    Debug.clear_messages
    BOT_CONFIG = Config.new ARGV
  rescue ConfigurationError => error
    Debug.add_message(error.message)
    puts Debug.fetch_messages
    exit
  ensure
    #Debug.pp Debug.fetch_messages_as_array(200, true, false)
    puts Debug.fetch_messages
  end
  #Debug.pp BOT_CONFIG.to_s if BOT_CONFIG.debug_spammy

  # Open the database connection.
  #DB_OBJ = DataStorage.db_open(DATABASE_FILE)
  DataStorage.db_open(BOT_CONFIG.database_file_name)

  # Now that the Database connection is active, fetch when it was created.
  BOT_CONFIG.set_database_creation_time

  # Turn on logging to both file and screen.
  timestamp_file = Time.now.strftime(BOT_CONFIG.timestamp_format).tr(':', '-')
  log_file = File.new(File.expand_path(+ROOT_DIR << '/logs/' << timestamp_file << '.log'), 'a+')
  log_streams = [STDOUT, log_file]

  run_supressed { LOGGER = Discordrb::LOGGER = Discordrb::Logger.new(true, log_streams) }

=begin
  Attributes to initialize a normal Bot with:
  ===========================================
  https://www.rubydoc.info/gems/discordrb/Discordrb/Bot#initialize-instance_method

  log_mode (Symbol) —
    The mode this bot should use for logging. See Logger#mode= for a list of modes.

  token (String) —
    The token that should be used to log in. If your bot is a bot account, you have to specify this. If you're logging in as a user, make sure to also set the account type to :user so discordrb doesn't think you're trying to log in as a bot.

  client_id (Integer) —
    If you're logging in as a bot, the bot's client ID.

  type (Symbol) —
    This parameter lets you manually overwrite the account type. This needs to be set when logging in as a user, otherwise discordrb will treat you as a bot account. Valid values are :user and :bot.

  name (String) —
    Your bot's name. This will be sent to Discord with any API requests, who will use this to trace the source of excessive API requests; it's recommended to set this to something if you make bots that many people will host on their servers separately.

  fancy_log (true, false) —
    Whether the output log should be made extra fancy using ANSI escape codes. (Your terminal may not support this.)

  suppress_ready (true, false) —
    Whether the READY packet should be exempt from being printed to console. Useful for very large bots running in debug or verbose log_mode.

  parse_self (true, false) —
    Whether the bot should react on its own messages. It's best to turn this off unless you really need this so you don't inadvertently create infinite loops.

  shard_id (Integer) —
    The number of the shard this bot should handle. See https://github.com/hammerandchisel/discord-api-docs/issues/17 for how to do sharding.

  num_shards (Integer) —
    The total number of shards that should be running. See https://github.com/hammerandchisel/discord-api-docs/issues/17 for how to do sharding.

  redact_token (true, false) —
    Whether the bot should redact the token in logs. Default is true.

  ignore_bots (true, false) —
    Whether the bot should ignore bot accounts or not. Default is false.


  Additional attributes to initialize the CommandBot with:
  ========================================================
  https://www.rubydoc.info/gems/discordrb/Discordrb/Commands/CommandBot#initialize-instance_method

  :prefix (String, Array<String>, #call) —
    The prefix that should trigger this bot's commands. It can be:
      * Any string (including the empty string).
        This has the effect that if a message starts with the prefix, the prefix will be stripped and the rest of the chain will be parsed as a command chain.
        Note that it will be literal - if the prefix is "hi" then the corresponding trigger string for a command called "test" would be "hitest".
        Don't forget to put spaces in if you need them!
      * An array of prefixes.
        Those will behave similarly to setting one string as a prefix, but instead of only one string, any of the strings in the array can be used.
      * Something Proc-like (responds to :call) that takes a Message object as an argument and returns either the command chain in raw form or nil if the given
        message shouldn't be parsed.
        This can be used to make more complicated dynamic prefixes (e. g. based on server), or even something else entirely (suffixes, or most adventurous, infixes).

  :advanced_functionality (true, false) —
    Whether to enable advanced functionality (very powerful way to nest commands into chains, see https://github.com/meew0/discordrb/wiki/Commands#command-chain-syntax for info. Default is false.

  :help_command (Symbol, Array<Symbol>, false) —
    The name of the command that displays info for other commands. Use an array if you want to have aliases. Default is "help". If none should be created, use false as the value.

  :command_doesnt_exist_message (String) —
    The message that should be displayed if a user attempts to use a command that does not exist. If none is specified, no message will be displayed. In the message, you can use the string '%command%' that will be replaced with the name of the command.

  :no_permission_message (String) —
    The message to be displayed when NoPermission error is raised.

  :spaces_allowed (true, false) —
    Whether spaces are allowed to occur between the prefix and the command. Default is false.

  :webhook_commands (true, false) —
    Whether messages sent by webhooks are allowed to trigger commands. Default is true.

  :channels (Array<String, Integer, Channel>) —
    The channels this command bot accepts commands on. Superseded if a command has a 'channels' attribute.

  :previous (String) —
    Character that should designate the result of the previous command in a command chain (see :advanced_functionality). Default is '~'.

  :chain_delimiter (String) —
    Character that should designate that a new command begins in the command chain (see :advanced_functionality). Default is '>'.

  :chain_args_delim (String) —
    Character that should separate the command chain arguments from the chain itself (see :advanced_functionality). Default is ':'.

  :sub_chain_start (String) —
    Character that should start a sub-chain (see :advanced_functionality). Default is '['.

  :sub_chain_end (String) —
    Character that should end a sub-chain (see :advanced_functionality). Default is ']'.

  :quote_start (String) —
    Character that should start a quoted string (see :advanced_functionality). Default is '"'.

  :quote_end (String) —
    Character that should end a quoted string (see :advanced_functionality). Default is '"'.

  :ignore_bots (true, false) —
    Whether the bot should ignore bot accounts or not. Default is false.
=end
  bot_initialize_options = {
    token:          BOT_CONFIG.client_token,
    client_id:      BOT_CONFIG.client_id,
    name:           'Bifrost' + (BOT_CONFIG.is_test_server ? ' Dev' : ''),
    parse_self:     true,    # # Whether the bot should react on its own messages. Turned on so the bot will store its own responses. BE CAREFUL OF LOOPS!
    ignore_bots:    false,   # Whether the bot should ignore bot accounts or not. Default is false.
    fancy_log:      (BOT_CONFIG.debug ? true : false), # Whether the output log should be made extra fancy using ANSI escape codes.
    log_mode:       :normal, # The mode this bot should use for logging.

    # https://www.rubydoc.info/gems/discordrb/Discordrb/Commands/CommandBot#initialize-instance_method
    prefix:                 '§|§|§', # The prefix that should trigger this bot's commands, but for command bot.
    spaces_allowed:         false,   # Whether spaces are allowed to occur between the prefix and the command. Default is false.
    help_command:           false,   # The name of the command that displays help. If none should be created, use false as the value.
    advanced_functionality: false,   # Whether to enable advanced functionality. Default is false.
    webhook_commands:       false    # Whether messages sent by webhooks are allowed to trigger commands. Default is true.
  }

  if BOT_CONFIG.debug_spammy
    # A little bit more spammy logs.
    #bot_initialize_options[:log_mode] = :debug if BOT_CONFIG.debug_spammy
    #bot_initialize_options[:log_mode] = :verbose if BOT_CONFIG.debug
  end

  # Turn off warnings since we have no control over the code in Discordrb. :-(
  $VERBOSE = false

  # Then start Bifrost as a new command bot instance.
  run_supressed { BOT_OBJ = Discordrb::Commands::CommandBot.new bot_initialize_options }
  #BOT_OBJ = Discordrb::Commands::CommandBot.new bot_initialize_options
  #BOT_OBJ = Discordrb::Bot.new bot_initialize_options

  # Rate limiting.
  RATE_LIMITER = Discordrb::Commands::SimpleRateLimiter.new
  # Create a new rate limiting bucket that allows associated commands to be executed
  # at most 2 times every 30 seconds, and with a hard limit of 10 seconds between each usage.
  RATE_LIMITER.bucket(:test_cmds, limit: 2, time_span: 30, delay: 10)

  RATE_LIMITER.bucket(:normal_cmds,
                      limit:     BOT_CONFIG.user_max_bot_invokes_per_time_limit,
                      time_span: BOT_CONFIG.bot_invokes_time_frame_period,
                      delay:     BOT_CONFIG.user_bot_invokes_minimum_time_frame_limit)
  RATE_LIMITER.bucket(:info_cmds,
                      limit:     BOT_CONFIG.user_max_bot_invokes_per_time_limit_complex,
                      time_span: BOT_CONFIG.bot_invokes_time_frame_period_complex,
                      delay:     BOT_CONFIG.user_bot_invokes_minimum_time_frame_limit_complex)
  RATE_LIMITER.bucket(:complex_cmds,
                      limit:     BOT_CONFIG.user_max_bot_invokes_per_time_limit_complex,
                      time_span: BOT_CONFIG.bot_invokes_time_frame_period_complex,
                      delay:     BOT_CONFIG.user_bot_invokes_minimum_time_frame_limit_complex)
  RATE_LIMITER.bucket(:exercise_cmds,
                      limit:     BOT_CONFIG.user_max_bot_invokes_per_time_limit_exercise,
                      time_span: BOT_CONFIG.bot_invokes_time_frame_period_exercise,
                      delay:     BOT_CONFIG.user_bot_invokes_minimum_time_frame_limit_exercise)
  #
  #BOT_CONFIG.bot_command_default_attributes[:bucket]  = :normal_cmds
  #BOT_CONFIG.bot_command_info_attributes[:bucket]     = :info_cmds
  #BOT_CONFIG.bot_command_complex_attributes[:bucket]  = :complex_cmds
  #BOT_CONFIG.bot_command_exercise_attributes[:bucket] = :exercise_cmds
  #BOT_CONFIG.bot_command_test_attributes[:bucket]     = :test_cmds

  # Load all the files in the lib/bifrost_bot folder
  # and the helpers in the lib/bifrost_bot/helpers
  # that have not been loaded already.
  dir_name = (File.expand_path(+ROOT_DIR << '/lib/bifrost_bot') << '/*rb').freeze
  Dir[dir_name].each { |file| require file }

  dir_name = (File.expand_path(+ROOT_DIR << '/lib/bifrost_bot/helpers') << '/*rb').freeze
  Dir[dir_name].each { |file| require file }

  dir_name = (File.expand_path(+ROOT_DIR << '/lib/bifrost_bot/other') << '/*rb').freeze
  Dir[dir_name].each { |file| require file }

  # See lib/commands.rb and lib/events.rb.
  # Load all the command modules and event handler modules.
  Commands.include!
  Events.include!

  # Do some basic typo checking.
  Events.check_config_file_event_responses

  # Helper object to store some server and user stuff.
  BOT_CACHE = BotCache.new

  # Reset the dictionary cache to be empty.
  DICTIONARY_CACHE = DictionaryCache.new

  # Turn off warnings since we have no control over the code in Discordrb.
  $VERBOSE = false

  # Start the bot.
  # If it runs as a normal bot this will make it loop.
  # If it runs as a command bot it will not loop automatically.
  #puts BOT_OBJ.to_yaml
  BOT_OBJ.run

  # Join the bot's thread back with the main thread:
  #BOT_OBJ.join

  # Do an infinitive loop.
  # Depending on how the bot was started this code should never be done.
  loop do
    puts '.'
    sleep(42)
  end

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


