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
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    public

    # Require files from directory.
    #Dir["#{File.expand_path(ROOT_DIR + '/lib/bifrost_bot')}/commands/*.rb"].each { |file| require file }
    Dir["#{File.dirname(__FILE__)}/commands/*.rb"].each { |file| require file }



    private

    # The module names that should be included.
    @commands = [
      Help,              #→ help, faq, obs, oss

      Role,              #→ role, beginner, intermediate, advanced, native, norsk, swedish, svensk, danish, dansk, dansker, nynorsk, bokmål, popcorn, comp, nsfw, ...

      DictionaryNOUiB,   #→ nb, bm, (nb|bm)u, (nb|bm)e, nn, nnu, nne
      Exercise,          #→ oppgave, oppgåve, opp, øvelse, øving, test, practise, practice, exercise, svar, answer, vis, show, status, reset
      RiddleText,        #→ juks, cheat

      UserBan,           #→ banuser
      UserInfo,          #→ userinfo

      FetchChatLog,      #→ fetch, fetchall
      Ping,              #→ ping
      ReloadSettings,    #→ reloadsettings
      ServerInformation, #→ serverinfo

      BotImpersonate,    #→ write
      SillyStuff         #→ sillystuff commands ...
    ]



    public

    # Add the command handlers for all the commands it is told to handle/react on.
    #
    # @return [nil]
    #
    def self.include!
      @commands.each do |command|
        BifrostBot::BOT_OBJ.include!(command)
      end

      #return nil
      nil
    end
    #self.include!



    # Parse the string made in a Discord message. If a match is done, then call that
    # corresponding command handler.
    #
    # Done this way to allow for more freedom than the existing CommandBot allows.
    #
    # @param event_obj [<Message-Object>] Discord's Message object that triggered the method.
    # @param is_private_message [true,false] True if it is a private message, false otherwise.
    # @param uc_command_str [String] The command to match against, in all upper case letters.
    # @return [true,false] True if there should be verification that the string matches a command, false otherwise.
    #
    def self.custom_command_parser(event_obj, is_private_message, uc_command_str)
      # BOT_CONFIG.bot_command_default_attributes[:bucket]  = :normal_cmds
      # BOT_CONFIG.bot_command_info_attributes[:bucket]     = :info_cmds
      # BOT_CONFIG.bot_command_complex_attributes[:bucket]  = :complex_cmds
      # BOT_CONFIG.bot_command_exercise_attributes[:bucket] = :exercise_cmds
      # BOT_CONFIG.bot_command_test_attributes[:bucket]     = :test_cmds
      #Debug.pp command_hash if BOT_CONFIG.debug_spammy

      command_event_obj = Discordrb::Commands::CommandEvent.new(event_obj.message, BOT_OBJ)
      empty_array       = []
      #command_as_array = [uc_command_str]
      command_is_caught = true
      verify_command    = false

      #puts '-----' + Debug.msg('customparse', 'black') + '----->c> ' + Debug.msg(uc_command_str) + ' >a> ' + Debug.msg(helper_obj.uc_command_args_str) + ' <<' if BOT_CONFIG.debug_spammy

      ############################################################################################
      # These commands might work (partially)in private messages.
      ############################################################################################
      #
      # Since the command is upcased do all the tests in upper case too.
      #
      case uc_command_str
      #→ help
      #→ faq, obs, oss
      when 'HELP',
           'FAQ', 'OBS', 'OSS'
        BOT_OBJ.execute_command(:int690284170289163650_help, command_event_obj, empty_array)
        #verify_command = true

      #→ oppgave, oppgåve, opp, øvelse, øving, test, practise, practice, exercise, svar, answer, vis, show, status, reset
      when 'OPPGAVE', 'OPPGÅVE', 'OPP', 'ØVELSE', 'ØVING', 'TEST', 'PRACTISE', 'PRACTICE', 'EXERCISE'
        BOT_OBJ.execute_command(:int503406229856943309_exercise, command_event_obj, empty_array)
        #verify_command = true
      when 'SVAR', 'ANSWER'
        BOT_OBJ.execute_command(:int124582407849755283_answer_exercise, command_event_obj, empty_array)
        #verify_command = true
      when 'VIS', 'SHOW'
        BOT_OBJ.execute_command(:int397268707654402598_reshow_exercise, command_event_obj, empty_array)
        #verify_command = true
      when 'STATUS'
        BOT_OBJ.execute_command(:int684060944247439054_exercise_status, command_event_obj, empty_array)
        #verify_command = true
      when 'RESET'
        BOT_OBJ.execute_command(:int258934473698704703_reset_exercise_status, command_event_obj, empty_array)
        verify_command = true

      #→ juks, cheat
      when 'JUKS', 'CHEAT'
        BOT_OBJ.execute_command(:int862510805397623761_show_riddle_answer, command_event_obj, empty_array)
        #verify_command = true

      #→ ping
      when 'PING'
        BOT_OBJ.execute_command(:int999168740761015147_ping, command_event_obj, empty_array)
        #verify_command = true

      #→ write
      when 'WRITE'
        BOT_OBJ.execute_command(:int209410769664380689_impersonate_bot_say, command_event_obj, empty_array)
        #verify_command = true

      #→ sillystuff commands ...
      # The individual autogenerated commands are at the bottom.
      when 'SILLYSTUFF'
        #puts 'blip'
        BOT_OBJ.execute_command(:int957803030189468496_silly_custom_responses, command_event_obj, empty_array)
        #verify_command = true

      else
        #puts '-----' + Debug.msg('nocmd: server & priv', 'black') + '----->> ' + Debug.msg(uc_command_str) + ' <<----------' if BOT_CONFIG.debug
        command_is_caught = false
      end

      #return nil # Exception: #<LocalJumpError: unexpected return>
      # Return if it is a private message.
      # We don't want the bot to handle all kinds of stuff "secretly" in
      # a private message where the channel-id is undefined.
      return verify_command if is_private_message

      # If it already got caught as a valid command just return now before trying to handle the rest of the commands.
      return verify_command if command_is_caught

      # Reset this since we start command handling again. But for public channel messages this time.
      command_is_caught = true

      ############################################################################################
      # These commands should not work in private messages.
      ############################################################################################
      #
      # Since the command is upcased do all the tests in upper case too.
      #
      case uc_command_str
      #→ role, beginner, intermediate, advanced, native, norsk, swedish, svensk, danish, dansk, dansker, nynorsk, bokmål, popcorn, comp, nsfw, ...
      # The individual autogenerated commands are at the bottom.
      when 'ROLE'
        #puts 'blip'
        BOT_OBJ.execute_command(:int879173974137803085_role, command_event_obj, empty_array)
        verify_command = true

      #→ #→ nb, bm, (nb|bm)u, (nb|bm)e, nn, nnu, nne
      # Commands moved over to the dictionary bot.
      #when 'NB', 'BM',      #, /^BOKM(Å|AA|A)L$/
      #     'NN',            #, 'NYNORSK'
      #     /^(NB|BM)[UE]$/, # 'NBU', 'NBU', 'BME', 'BME', #/^(NB|BM)[UE]$/, /^BOKM(Å|AA|A)L[\-_]?(UTVIDET|EXPANDED)$/,
      #     'NNU', 'NNE'     #                             #/^(NN)[UE]$/,    /^NYNORSK[\-_]?(UTVIDET|EXPANDED)$/
      #BOT_OBJ.execute_command(:int102844909202347536_dict_no_ordbok_uib, command_event_obj, empty_array)
      #  #verify_command = true

      #→ banuser
      when 'BANUSER'
        BOT_OBJ.execute_command(:int255038720237542980_ban_user_id, command_event_obj, empty_array)
        verify_command = true

      #→ userinfo
      when 'USERINFO'
        BOT_OBJ.execute_command(:int707750744596935852_show_user_info, command_event_obj, empty_array)
        #verify_command = true

      #→ fetch, fetchall
      when 'FETCHALL'
        BOT_OBJ.execute_command(:int843698523271581386_fetch_all_server_messages, command_event_obj, empty_array)
        #verify_command = true
      when 'FETCH'
        BOT_OBJ.execute_command(:int420823229203000431_fetch_new_messages, command_event_obj, empty_array)
        #verify_command = true

      #→ serverinfo
      when 'SERVERINFO'
        BOT_OBJ.execute_command(:int321025852557280648_show_server_information, command_event_obj, empty_array)
        #verify_command = true
      #→ reloadsettings
      when 'RELOADSETTINGS'
        BOT_OBJ.execute_command(:int422660145997257723_reload_server_configuration_files, command_event_obj, empty_array)
        #verify_command = true

      else
        #puts '-----' + Debug.msg('nocmd: server', 'black') + '----->> ' + Debug.msg(uc_command_str) + ' <<----------' if BOT_CONFIG.debug
        command_is_caught = false
      end

      # If it already got caught as a valid command just return now before trying to handle the
      # user configured commands.
      return verify_command if command_is_caught

      # Reset this since we start command handling again. But for public channel messages this time.
      command_is_caught = true

      #Debug.pp BOT_CONFIG.role_commands_hash if BOT_CONFIG.debug_spammy
      #Debug.pp BOT_CONFIG.silly_commands_hash if BOT_CONFIG.debug_spammy
      #Debug.pp BOT_CONFIG.silly_regexp_commands_hash if BOT_CONFIG.debug_spammy

      ############################################################################################
      # These commands are autogenerated based on the contents in the configuration files.
      # No checks are made if they conflict with any of the previous commands.
      ############################################################################################
      #
      if BOT_CONFIG.role_commands_hash.key?(uc_command_str)
        #puts 'blop'
        BOT_OBJ.execute_command(:int879173974137803085_role, command_event_obj, empty_array)
        verify_command = true

      elsif BOT_CONFIG.silly_commands_hash.key?(uc_command_str)
        #puts 'blap'
        BOT_OBJ.execute_command(:int957803030189468496_silly_custom_responses, command_event_obj, empty_array)
        #verify_command = true

      else
        #puts '-----' + Debug.msg('nocmd: custom', 'black') + '----->> ' + Debug.msg(uc_command_str) + ' <<----------' if BOT_CONFIG.debug
        command_is_caught = false
      end

      if BOT_CONFIG.debug_spammy
        _debug_str = +'-----' << Debug.msg('customcmd', 'black') << '----->> ' <<
                     Debug.msg(uc_command_str) << ', ' \
                     'caught: ' << Debug.msg(command_is_caught) <<
                     'verify: ' << Debug.msg(verify_command) <<
                     ' <<----------'
        #
        #puts debug_str if BOT_CONFIG.debug_spammy
      end

      #return verify_command
      verify_command
    end
    #command_parser

  end
  #module Commands
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
=begin
  https://www.rubydoc.info/gems/discordrb/Discordrb/Commands/CommandBot#execute_command-instance_method
  =====================================================================================================

  #execute_command(name, event, arguments, chained = false, check_permissions = true) ⇒ String?
    Executes a particular command on the bot. Mostly useful for internal stuff, but one can never know.

  Parameters:
  ===========

  name (Symbol) —
    The command to execute.

  event (CommandEvent) —
    The event to pass to the command.

  arguments (Array<String>) —
    The arguments to pass to the command.

  chained (true, false) (defaults to: false) —
    Whether or not it should be executed as part of a command chain. If this is false, commands that have chain_usable set to false will not work.

  check_permissions (true, false) (defaults to: true) —
    Whether permission parameters such as required_permission or permission_level should be checked.
=end
=begin
  https://www.rubydoc.info/gems/discordrb/Discordrb/Commands/CommandContainer#command-instance_method
  ===================================================================================================

  #command(name, attributes = {}) {|event| ... } ⇒ Command
    Adds a new command to the container.

  Parameters:
  ===========

  name (Symbol, Array<Symbol>) —
    The name of the command to add, or an array of multiple names for the command

  attributes (Hash) (defaults to: {}) —
    The attributes to initialize the command with.


  Options Hash (attributes):
  ==========================

  :permission_level (Integer) —
    The minimum permission level that can use this command, inclusive. See Discordrb::Commands::CommandBot#set_user_permission and Discordrb::Commands::CommandBot#set_role_permission.

  :permission_message (String, false) —
    Message to display when a user does not have sufficient permissions to execute a command. %name% in the message will be replaced with the name of the command. Disable the message by setting this option to false.

  :required_permissions (Array<Symbol>) —
    Discord action permissions (e.g. :kick_members) that should be required to use this command. See Permissions::Flags for a list.

  :required_roles (Array<Role>, Array<#resolve_id>) —
    Roles that user should have to use this command.

  :channels (Array<String, Integer, Channel>) —
    The channels that this command can be used on. An empty array indicates it can be used on any channel. Supersedes the command bot attribute.

  :chain_usable (true, false) —
    Whether this command is able to be used inside of a command chain or sub-chain. Typically used for administrative commands that shouldn't be done carelessly.

  :help_available (true, false) —
    Whether this command is visible in the help command. See the :help_command attribute of Discordrb::Commands::CommandBot#initialize.

  :description (String) —
    A short description of what this command does. Will be shown in the help command if the user asks for it.

  :usage (String) —
    A short description of how this command should be used. Will be displayed in the help command or if the user uses it wrong.

  :arg_types (Array<Class>) —
    An array of argument classes which will be used for type-checking. Hard-coded for some native classes, but can be used with any class that implements static method from_argument.

  :min_args (Integer) —
    The minimum number of arguments this command should have. If a user attempts to call the command with fewer arguments, the usage information will be displayed, if it exists.

  :max_args (Integer) —
    The maximum number of arguments the command should have.

  :rate_limit_message (String) —
    The message that should be displayed if the command hits a rate limit. None if unspecified or nil. %time% in the message will be replaced with the time in seconds when the command will be available again.

  :bucket (Symbol) —
    The rate limit bucket that should be used for rate limiting. No rate limiting will be done if unspecified or nil.
=end
=begin
  helper_obj => {
    "bot_runs_on_server_id": 987654321098765432,
    "bot_invoke_character": "!",
    "is_private_message": false,
    "has_server_obj": "event_obj.server",
    "server_id": 987654321098765432,
    "server_name": "Min egen testserver",
    "has_channel_obj": "event_obj.channel",
    "channel_id": 123456789012345678,
    "channel_name": "testspam",
    "channel_type": 0,
    "has_user_obj": "event_obj.user",
    "user_id": 123456789012345678,
    "user_name": "Test",
    "user_discriminator": "1234",
    "user_distinct": "Test#1234",
    "user_mention": "<@123456789012345678>",
    "user_nick": "testnick",
    "user_roles": {
      "KAFFE": 497818068001751051,
      "TE": 497822048031342592
    },
    "user_joined_at": "2018-10-01 18:16:12 +0000",
    "user_is_bot": false,
    "user_avatar_id": "123456789abcdef123456789abcdef12",
    "user_avatar_url": "https://cdn.discordapp.com/avatars/123456789012345678/123456789abcdef123456789abcdef12.webp",
    "user_game": nil,
    "message_id": 987654321098765432,
    "message": "!RolE Abc x y z æØå",
    "msg_files": [  ],
    "msg_embeds": [  ],
    "msg_timestamp": "2018-10-17 19:33:18 +0000",
    "msg_is_edited": false,
    "edited_timestamp": nil,
    "is_bot_command": true,
    "command": "ROLE",
    "command_args": [
      "Abc",
      "x",
      "y",
      "z",
      "æØå"
    ],
    "uc_command_args": [
      "ABC",
      "X",
      "Y",
      "Z",
      "ÆØÅ"
    ],
    "command_args_str": "Abc x y z æØå",
    "uc_command_args_str": "ABC X Y Z ÆØÅ"
  }
=end

