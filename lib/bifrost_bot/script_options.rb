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
  # Command line argument parsing.
  module ScriptOptions
    require 'debug'
    require 'awesome_print'
    require 'optparse'
    require 'ostruct'
    #require 'bifrost_bot/config'



    public

    module_function

    # Parse the command line options used to invoke the script.
    #
    # @param version [String] The version number of the script.
    # @param version_date [String] The version date of the script.
    # @param args [Array<String>] The command line arguments, ARGV.
    # @return [OpenStruct] The options parsed from the command line arguments.
    #
    def parse_command_line_options(version, version_date, args)
      options = OpenStruct.new
      options.verbose = false
      options.debug = false
      options.debug_spammy = false
      options.test_server = false
      options.live_server = false

      debug_option_parsing = false

      opt_parser = OptionParser.new do |arg_opts|
        #arg_opts.banner = "Usage: #{BifrostBot.script_name} [options]"
        arg_opts.banner = "Usage: #{SCRIPT_NAME} [options]"
        arg_opts.separator ''
        arg_opts.separator 'Specific options:'

        arg_opts.on('-t', '--test', '--dev', 'Run the bot on the test/dev server.') do
          puts 'test' if debug_option_parsing
          options.test_server = true
        end

        arg_opts.on('-l', '-L', '--live', 'LIVE', 'Run the bot on the LIVE server.') do
          puts 'live' if debug_option_parsing
          options.live_server = true
        end

        arg_opts.separator ''

        arg_opts.on('-v', '-V', '--verbose', 'Verbose mode. Show useful(?) information.') do
          puts 'verbose' if debug_option_parsing
          options.verbose = true
        end

        arg_opts.on('-d', '--debug', 'Debug mode. Show lots of debug text.') do
          puts 'debug' if debug_option_parsing
          options.debug = true
          options.verbose = true
        end

        arg_opts.on('-D', '-s', '-S', '--spammy', 'Extra debug mode. Show even more debug text.') do
          puts 'spammy' if debug_option_parsing
          options.debug_spammy = true
          options.debug = true
          options.verbose = true
        end

        arg_opts.separator ''
        arg_opts.separator 'Common options:'

        arg_opts.on_tail('-h', '-H', '--help', 'Show this message.') do
          puts arg_opts
          exit
        end

        arg_opts.on_tail('--version', 'Show version number and exit.') do
          puts "BifrostBot #{version} (#{version_date})"
          exit
        end
      end

      opt_parser.parse!(args)

      ap args if debug_option_parsing
      ap options if debug_option_parsing

      if args.length.positive?
        # Assume any remaining stuff in the ARG is indication of wanting to run on LIVE server.
        options.live_server = true
        puts 'livearg' if debug_option_parsing
      end

      # If neither test nor live has been set already, then
      # set it to be on the TEST server.
      options.test_server = true if !options.live_server && !options.test_server

      # If TEST is set, then ignore any value for LIVE, and
      # assume it is to be run on the TEST server.
      options.live_server = false if options.test_server

      ap options if debug_option_parsing

      #return options
      options
    end

    #public_class_method :parse_command_line_options
    #module_function :parse_command_line_options

  end
  #module ScriptOptions
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


