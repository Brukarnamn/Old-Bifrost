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

# Debug module with functions to help make various debug stuff easier to read.
module Debug
  @@loaded ||= false # rubocop:disable Style/ClassVars

  class << self
    public

    # 8 colour escape code definitions.
    attr_reader :colour_black,
                :colour_red,
                :colour_green,
                :colour_yellow,
                :colour_blue,
                :colour_purple,
                :colour_cyan,
                :colour_white,
                :colour_normal

    # The prefix strings to show on warnings, errors and internal errors, respectively.
    attr_accessor :warn_str,
                  :error_str,
                  :internal_error_str

    # The prefix strings to use during debug function trace.
    attr_reader :indent_character,
                :outdent_character,
                :info_character,
                :inoutdent_end_character

    attr_reader :do_indent
    alias do_indent? do_indent

    # Return a string of 1 tab identation.
    #
    # @return [String]
    #
    def indent_tab_length
      INDENT_TAB_LENGTH
    end

    # The current indentation.
    attr_reader :indent_at,
                :message_log
    #

    protected
    private

    attr_writer :indent_at,
                :message_log
    #



    public
    protected

    # Set all the class variables to their initial values.
    #
    # @return [nil]
    #
    def initialize_variables
      # @example Shell-code if the terminal supports 256 different colours:
      #   for  code in {0..255};  do echo -e "\e[38;5;${code}m"'\\e[38;5;'"$code"m"\e[0m";  done
      @colour_black  = "\e[1m\e[30m"
      @colour_red    = "\e[1m\e[31m"
      @colour_green  = "\e[1m\e[32m"
      @colour_yellow = "\e[1m\e[33m"
      @colour_blue   = "\e[1m\e[34m"
      @colour_purple = "\e[1m\e[35m"
      @colour_cyan   = "\e[1m\e[36m"
      @colour_white  = "\e[1m\e[37m"
      @colour_normal = "\e[0m"

      # Prefix strings to show on warnings, errors and internal errors.
      @warn_str           = 'WARNING: '
      @error_str          = 'ERROR: '
      @internal_error_str = 'INTERNAL ERROR: '

      # Characters used at the start of a line for indent and outdent function lines.
      @indent_character = '[⮞'
      @outdent_character = '⮘]'
      #@info_character = '·'
      @info_character = '·'

      # Characters used at the end of a line for indent and outdent function lines.
      @inoutdent_end_character = ' <]'

      # Should the indent/outdent functions actually do indenting?
      @do_indent = true

      # Current indent.
      @indent_at = 0

      # Global message log.
      @message_log = []

      #return nil
      nil
    end

    private
  end
  #class self



  private

  if !@@loaded
    # Indent amount of 1 tab identation.
    INDENT_TAB_LENGTH = '  '

    puts '----------v----------v----------v----------v----------v----------v----------v----------v----------v----------'
    #puts "... #{__FILE__},#{__LINE__}: #{@@loaded}"
    #puts "... #{__FILE__},#{__LINE__}: " + self.msg(@@loaded.to_s, 'green') # Not defined yet.
    puts "... #{__FILE__},#{__LINE__}: " + @@loaded.to_s
    initialize_variables if !@@loaded
    puts '----------^----------^----------^----------^----------^----------^----------^----------^----------^----------'
    @@loaded = true # rubocop:disable Style/ClassVars
  end



  public

  module_function

  # Print out a test message repeated in all the supported colours.
  #
  # @return [nil]
  #
  def colour_test
    %w[black red green yellow blue purple cyan white]
      .each { |colour| puts create_coloured_string('The quick brown fox jumps over the lazy dog.', colour) }

    #return nil
    nil
  end



  # Add what kind of message type it is, then print it as a coloured message to STDERR.
  #
  # @param message [String] A message to be printed to STDERR.
  # @return [nil]
  #
  def stderror_message(message = nil)
    return nil if message.nil? || message.empty?

    case __callee__
    when :warn
      message = warn_msg(message)
    when :error
      message = error_msg(message)
    when :internal
      message = internal_msg(message)
    else
      raise create_coloured_string(+@internal_error_str << '`' << __method__.to_s << '´ called by unknown alias: ' << __callee__.to_s, 'error')
    end

    STDERR.puts message

    #return nil
    nil
  end

  alias warn stderror_message
  alias error stderror_message
  alias internal stderror_message

  module_function :warn, :error, :internal



  module_function

  # Add what kind of message type it is, then return the string in
  # a coloured form.
  #
  # @param message [String] A message to assign a message type prefix.
  # @return [String] The coloured string with the message type
  #   prefix added at the start.
  #
  def coloured_warning_or_error_message(message = nil)
    return nil if message.nil? || message.empty?

    # Check the name of the originally invoked alias function.
    case __callee__
    when :warn_msg
      message = create_coloured_string(+@warn_str << message, 'warning')
    when :error_msg
      message = create_coloured_string(+@error_str << message, 'error')
    when :internal_msg
      message = create_coloured_string(+@internal_error_str << message, 'error')
    else
      raise create_coloured_string(+@internal_error_str << '`' << __method__.to_s << '´ called by unknown alias: ' << __callee__.to_s, 'error')
    end

    #return message
    message
  end

  alias warn_msg coloured_warning_or_error_message
  alias error_msg coloured_warning_or_error_message
  alias internal_msg coloured_warning_or_error_message

  module_function :warn_msg, :error_msg, :internal_msg



  module_function

  # Print out a dividing line consisting of '_____'
  #
  # @param message [String] A message to be printed in the middle of the divider string.
  # @param number_of_times [Integer] Number of times the dividing string should be printed
  #   to make up a line before and after the message.
  # @return [nil]
  #
  def divider(message = nil, number_of_times = 7)
    output = +''
    line = +''

    if message
      number_of_times.times { line << '_____' }
      output << +@colour_blue << line <<
        @colour_cyan << message.to_s <<
        @colour_blue << line <<
        @colour_normal
    else
      25.times { line << '_____' }
      output << +@colour_blue << line << @colour_normal
    end

    puts output

    #return nil
    nil
  end



  # Return the input string with coloured tags added.
  #
  # @param text_string [String] String to turn into a colour string.
  # @param colour [String] A predefined colour to turn the string into.
  # @return [String] The input string with escape codes to make it appear in colour.
  #   If the terminal doesn't support colours this will look odd.
  #
  def create_coloured_string(text_string = '', colour = 'green')
    colour_tag = case colour.upcase
                 when 'BLACK'
                   @colour_black
                 when 'RED', 'ERROR'
                   @colour_red
                 when 'GREEN'
                   @colour_green
                 when 'YELLOW', 'WARNING', 'WARN'
                   @colour_yellow
                 when 'BLUE'
                   @colour_blue
                 when 'PURPLE'
                   @colour_purple
                 when 'CYAN'
                   @colour_cyan
                 when 'WHITE'
                   @colour_white
                 when 'NORMAL'
                   @colour_normal
                 else
                   @colour_green
                 end
    #

    #return colour_tag + text_string.to_s + colour_normal
    (+colour_tag << text_string.to_s << @colour_normal)
  end

  alias msg create_coloured_string

  module_function :create_coloured_string, :msg



  module_function

  # Print out a the contents of a Hash/Array in a very verbose way.
  #
  # @param object [Object] The object or variable to print out the values for.
  # @param indent [Integer] The current indent level, determining the amount of space there will
  #   be at a start of a newline.
  # @param put_string [Boolean] Print out the current string so far.
  # @param start_text [String]
  # @return [String] The generated string containing the values of the current supplied object.
  #
  def pp(object, indent = 0, put_string = true, start_text = '')
    returnstr = +''
    indent_str = +''
    indent.times { indent_str << INDENT_TAB_LENGTH }

    indented_str = indent_str + INDENT_TAB_LENGTH
    #indented_str = indent_str
    #indent_tab_length.times { indented_str = +indented_str << ' ' }

    if object.is_a?(Hash)
      is_one_value = (object.keys.length <= 1)
      #is_one_value = (object.keys.length > 1 ? false : true)
      returnstr << #returnstr <<
        '{' << (is_one_value ? ' ' : (+"\n" << indented_str))

      i = 1
      object.each do |key, value|
        returnstr << #returnstr <<
          (key.is_a?(Symbol) ? (+@colour_red << ':' << @colour_cyan) : +'"' << @colour_cyan) <<
          key.to_s << @colour_normal <<
          (key.is_a?(Symbol) ? ' => ' : '": ')
        #puts "#{i} <? #{object.length}"

        #returnstr = +returnstr << pp(value, (indent + indent_tab_length), false)
        returnstr << #returnstr <<
          pp(value, (indent + 1), false)
        returnstr << #returnstr <<
          (i < object.keys.length ? +",\n" << indented_str : '')
        i += 1
      end

      returnstr << #returnstr <<
        (is_one_value ? ' ' : (+"\n" << indent_str)) << '}'

    elsif object.is_a?(Array)
      is_one_value = (object.length <= 1)
      returnstr << #returnstr <<
        '[' << (is_one_value ? ' ' : (+"\n" << indented_str))

      i = 1
      object.each do |value|
        #puts "#{i} <? #{object.length}"

        #returnstr = returnstr << pp(value, (indent + indent_tab_length), false)
        returnstr << #returnstr <<
          pp(value, (indent + 1), false)
        returnstr << #returnstr <<
          (i < object.length ? (+",\n" << indented_str) : '')
        i += 1
      end

      returnstr << #returnstr <<
        (is_one_value ? ' ' : (+"\n" << indent_str)) << ']'

    elsif object.is_a?(TrueClass) || object.is_a?(FalseClass)
      returnstr << #returnstr <<
        @colour_cyan << object.to_s << @colour_normal

    elsif object.is_a?(Integer) || object.is_a?(Float)
      returnstr << #returnstr <<
        @colour_cyan << object.to_s << @colour_normal

    elsif object.is_a?(NilClass)
      returnstr << #returnstr <<
        @colour_cyan << 'nil' << @colour_normal

    else
      returnstr << #returnstr <<
        '"' << @colour_green << object.to_s << @colour_normal << '"'
    end

    puts(+start_text << returnstr) if put_string

    #return returnstr
    returnstr
  end



  # Add to the message/debug log to store messages that should be shown elsewhere.
  #
  # @param message_str [String] A custom message to add to the current message log.
  # @return [nil]
  #
  def add_message(message_str)
    @message_log.push message_str

    #return nil
    nil
  end



  # Fetch all the messages from the message/debug log.
  #
  # @param clear_log_afterwards [true, false] True if the log should be cleared afterwards. False otherwise.
  # @return [String] The current message/debug log as a long string.
  #
  def fetch_messages(clear_log_afterwards = true)
    return_string = @message_log.join "\n"

    @message_log = [] if clear_log_afterwards

    #return return_string
    return_string
  end



  # Fetch all the messages from the message/debug log, but split them so each string fits inside
  # N amount of characters.
  #
  # @param max_string_length [Integer] The max length of each individual string in the return array.
  # @param markdown [true, false] True if any strings starting with DEBUG, WARNING, ERROR or INTERNAL error should be highlighted in bold.
  # @param clear_log_afterwards [true, false] True if the log should be cleared afterwards. False otherwise.
  # @return [Array<String>] The current message/debug log as an array of strings.
  #
  def fetch_messages_as_array(max_string_length = 1_999, markdown = false, clear_log_afterwards = true)
    return_array = []
    newline_character = "\n"
    merged_str = ''

    @message_log.each do |single_message_string|
      if markdown
        case single_message_string
        when /^(DEBUG|WARNING|ERROR|INTERNAL ERROR)/
          single_message_string = single_message_string.sub(/^(DEBUG|WARNING|ERROR|INTERNAL ERROR)(:)?/, '**\1**\2')
        #else
        end
      end

      #puts '> ' + single_message_string + ' <'
      if merged_str.length + newline_character.length + single_message_string.length > max_string_length
        #puts '> ' + merged_str + ' <'
        return_array.push merged_str
        merged_str = ''
      end

      merged_str += "\n" if !merged_str.empty?
      merged_str += single_message_string
    end

    #puts '> ' + merged_str + ' <'
    return_array.push merged_str if !merged_str.empty?

    @message_log = [] if clear_log_afterwards

    #return return_array
    return_array
  end



  # Clear the message/debug log.
  #
  # @return [nil]
  #
  def clear_messages
    @message_log = []

    #return nil
    nil
  end



  # Increase the indent amount after the text is printed.
  #
  # @see #trace_internal
  # @param message [String] A custom message to use instead of the caller's current function name.
  # @return [nil]
  #
  def trace_begin(message = nil)
    trace_internal @do_indent, true, message

    #return nil
    nil
  end



  # Decrease the indent amount before the text is printed.
  #
  # @see #trace_internal
  # @param message [String] A custom message to use instead of the caller's current function name.
  # @return [nil]
  #
  def trace_end(message = nil)
    trace_internal @do_indent, false, message

    #return nil
    nil
  end

  alias trace_start trace_begin
  alias trace_b trace_begin
  alias trace_s trace_begin
  alias trace_e trace_end

  module_function :trace_begin, :trace_end
  module_function :trace_start, :trace_b, :trace_s, :trace_e



  module_function

  # Print out a trace text.
  #
  # @see #trace_internal
  # @param message [String] A custom message to use instead of the caller's current function name.
  # @return [nil]
  #
  def trace(message = nil)
    trace_internal @do_indent, nil, message

    #return nil
    nil
  end



  class << self
    public
    protected

    # Print out the caller's current source file and line number and current function.
    #
    # @param is_indent [Boolean, nil] Tells if it is the start or end of a function
    #   to determine if the debug message should be indented or outdented.
    # @param message [String] A custom message to use instead of the caller's current function name.
    # @return [nil]
    #
    def trace_internal(do_indent = true, is_indent = nil, message = nil)
      # For example
      #   app/controllers/welcome_controller.rb:18:in `index'
      call_stack = Kernel.caller

      current_func = call_stack[1].split ':'
      cur_message = current_func.pop
      cur_line = current_func.pop
      cur_file = current_func.join ':'

      caller_func = call_stack.size > 2 ? call_stack[2].split(':') : []
      call_message = caller_func.pop   || ''
      call_line = caller_func.pop      || ''
      call_file = caller_func.join ':' || ''

      # Calculate how big the indent should be, and make the starter string.
      indent_string = +''
      if do_indent
        #indent_tab_spaces = ''
        #indent_tab_length.times { indent_tab_spaces = +indent_tab_spaces << ' ' }

        #Debug.inspect self.indent_at
        i = @indent_at
        #puts '>>i:>> ' + i.to_s + '<<'

        if is_indent.nil?
          i.times { indent_string << INDENT_TAB_LENGTH }
          indent_string << @info_character << ' '
        elsif is_indent
          #i.times { indent_string = +indent_string << indent_tab_spaces }
          i.times { indent_string << INDENT_TAB_LENGTH }
          i += 1

          indent_string << @indent_character << ' '
          #indent_string = +indent_string << @indent_character << ' '
        else
          i -= 1
          i = 0 if i.negative?
          i.times { indent_string << INDENT_TAB_LENGTH }
          #i.times { indent_string = +indent_string << indent_tab_spaces }

          indent_string << @outdent_character << ' '
          #indent_string = +indent_string << outdent_character << ' '
        end

        @indent_at = i
        #self.indent_at = i
        #Debug.inspect self.indent_at
      else
        indent_string << @indent_character << ' '
      end

      # Format the file, line and function.
      message = message.nil? || message.to_s.empty? ? nil : +@colour_yellow << message.to_s << @colour_normal

      #puts '-----cur-----| ' + cur_message.to_s + ' | ' + cur_line.to_s + ' | ' + cur_file.to_s + ' |-----'
      #puts '-----call----| ' + call_message.to_s + ' | ' + call_line.to_s + ' | ' + call_file.to_s + ' |-----'
      #puts '-----msg-----| ' + message.to_s + ' | ' + (message.nil? ? 'nil' : 'tekst' ) + ' |-----'

      current = caller_function_info_str(
        message:              message || cur_message,
        is_callstack_message: (message.nil? ? true : false),
        filename:             cur_file,
        lineno:               cur_line
      )

      if message
        output = indent_string << current << (do_indent ? '' : @inoutdent_end_character)
      else
        from = caller_function_info_str(
          message:              call_message,
          is_callstack_message: (call_message.nil? ? false : true),
          filename:             call_file,
          lineno:               call_line
        )
        output = indent_string << current << ' ← ' << from << (do_indent ? '' : @inoutdent_end_character)
      end

      puts output

      #return nil
      nil
    end

    #private_class_method :trace_internal



    private

    # Reformat the call stack information to a custom format.
    #
    # @param hash_args [Hash] Hash containing information from the call stack:
    # @option hash_args [String] :message ('') The current function or custom message.
    # @option hash_args [String] :message_colour (@colour_purple) The colour (as escape code) to
    #   be used on certain parts of the message to make it easier to view on
    #   a terminal screen.
    # @option hash_args [Boolean] :is_callstack_message Is the supplied message from the internal callstack?
    # @option hash_args [String] :filename The current file.
    # @option hash_args [String] :lineno The current line number.
    # @return [String] The information provided in hash_args formatted in a custom format.
    #
    def caller_function_info_str(hash_args = {})
      defaults = {
        message:              '',
        message_colour:       @colour_purple,
        is_callstack_message: true,
        filename:             '<¿filename?>',
        lineno:               '<¿lineno?>'
      }
      hash_args = defaults.merge(hash_args)

      message              = hash_args[:message].to_s
      msgcolour            = hash_args[:message_colour].to_s
      is_callstack_message = hash_args[:is_callstack_message]
      file                 = hash_args[:filename].to_s
      line                 = hash_args[:lineno].to_s

      #puts @colour_normal + '-----crat----| ' + message.to_s + ' | ' + msgcolour.to_s + ' | ' + is_callstack_message.to_s + ' | ' + file.to_s + ' | ' + line.to_s + ' |-----'

      # Original call stack line looks for example like this:
      #   app/controllers/welcome_controller.rb:18:in `index'
      # Now split into the three array parts.
      # @message = in `index'
      if is_callstack_message
        message = if !message.nil? && !message.empty? && (m = message.match(/\Ain `(?<function>.+)'\z/))
                    m[:function]
                  else
                    '<<root>>'
                  end
        #
      end
      message = +msgcolour << message << @colour_normal

      # Original call stack line looks for example like this:
      #   app/controllers/welcome_controller.rb:18:in `index'
      #

      # @file = welcome_controller.rb
      # @file = app/controllers/welcome_controller.rb
      # @file = /home/ra/claudia/app/controllers/welcome_controller.rb
      if file.empty?
        file = nil
      else
        pathname = File.dirname(file)
        filename = File.basename(file)
        file = +@colour_normal << pathname << '/' << msgcolour << filename << @colour_normal
      end

      line = if line.empty?
               nil
             else
               +@colour_purple << line << @colour_normal
             end
      #

      (+message << ' ※ ' << file << ' @ ' << line) if file && line

      #return message
      message
    end

    #private_class_method :caller_function_info_str
  end
end
#module Debug



# Extend the Object class.
class Object
  # Check if an object is nil, empty.
  #
  # @return [true,false]
  #
  def nil_or_empty?
    return true if self.nil? || (                 # rubocop:disable Style/RedundantSelf, Layout/EmptyLineAfterGuardClause
      (self.is_a?(String) && self.empty?) ||      # rubocop:disable Style/RedundantSelf
      (self.is_a?(Array) && self.empty?) ||       # rubocop:disable Style/RedundantSelf
      (self.is_a?(Hash) && self.empty?))          # rubocop:disable Style/RedundantSelf
    #
    false
  end

  # Check if an object is nil, empty or negative (< 0).
  #
  # @return [true,false]
  #
  def nil_empty_or_ltzero?
    return true if self.nil? || (                 # rubocop:disable Style/RedundantSelf, Layout/EmptyLineAfterGuardClause
      (self.is_a?(Numeric) && self.negative?) ||  # rubocop:disable Style/RedundantSelf
      (self.is_a?(String) && self.empty?) ||      # rubocop:disable Style/RedundantSelf
      (self.is_a?(Array) && self.empty?) ||       # rubocop:disable Style/RedundantSelf
      (self.is_a?(Hash) && self.empty?))          # rubocop:disable Style/RedundantSelf
    #
    false
  end
end
#class Object



# Extend the String class.
class String
  # If a string contains " as both first and last character, remove that character
  # and return the resulting string.
  #
  # @param quote_character [String] The single quote character. Default is '"'.
  # @return [String] The unmodified or modified string, if modified.
  #
  def remove_quotes(quote_character = '"')
    duplicate_string = self.dup # rubocop:disable Style/RedundantSelf

    first_char = duplicate_string[0]
    last_char = duplicate_string[-1]

    duplicate_string = duplicate_string[1..-2].to_s if first_char == last_char && quote_character == first_char

    #return duplicate_string
    duplicate_string
  end

  # If a string contains more than N lines, then return only the first N lines.
  #
  # @param lines [Integer] The maximum number of lines the string can have. Default is 10 lines.
  # @return [String] The lines joined together in a single string.
  #
  def truncate_lines(lines = 10)
    line_count = self.lines.count
    return_value = nil

    if line_count > lines
      return_value = self.lines[0..(lines - 1)]
      return_value.push "[...skipped #{line_count - lines} lines...]"
    else
      return_value = self.lines
    end

    #return return_value
    return_value.join "\n"
  end

  # If a string contains more than N characters, then split it up into
  # words and return the words that can fit into a string that has less
  # than N characters.
  # The words are divided by space or tab characters, and are truncated
  # into one single space.
  # An ellipsis is added at the end to indicate if the string was shortened.
  #
  # @param max_characters [Integer] The maximum number of characters the string can have.
  # @return [String] The string chopped off at a point where it is shorter or equal to the maximum length.
  #
  def truncate_words(max_characters)
    # Doing it on a nil or empty string doesn't make sense.
    return '' if self.nil? || self.empty? # rubocop:disable Style/RedundantSelf

    # Return if we already know the length is less than the max length.
    return self if self.length < max_characters # rubocop:disable Style/RedundantSelf

    # Substitute newlines with an escape character so it can be remembered.
    #newline_to_magic_char = "\x25\n"  # %
    #magic_char_to_newline = "\x25\s*" # %
    newline_to_magic_char = "\x1A\n"  # ^Z  SUB
    magic_char_to_newline = "\x1A\s*" # ^Z  SUB

    # Replace the string's real newlines with the magic character.
    substituted_newlines = self.gsub(/\n/, newline_to_magic_char) # rubocop:disable Style/RedundantSelf

    #puts substituted_newlines.inspect

    # Divide words by newlines, tabs and spaces. Ignore all other kinds of space.
    #split_str_array = self.split(/[\t ]+/)
    split_str_array = substituted_newlines.split(/\s+/)
    first_str = split_str_array[0]
    #puts split_str_array.inspect

    # The original string was a string with white space characters.
    return '' if first_str.nil? || first_str.empty?

    if first_str.length >= max_characters
      # If the first word in the string is longer than the max length, then brutally chop it up.
      trunc_str = self[0..(max_characters - 1)]
      trunc_str[-1] = '…'
      return trunc_str
    elsif split_str_array.length <= 1
      # Only one word, which is shorter than the max length.
      return self
    end

    spacelen = 1 # The length of ' '.length
    i = 0

    # Loop over every word in the input string.
    # Add the words as long as the total string is less than the max length.
    # Start with a non-freezed empty string +''
    trunc_str = split_str_array.each_with_object(+'') do |split_str, init_str|
      if (init_str.length + spacelen + split_str.length) >= max_characters
        # If adding to the first word makes it go over the max length limit,
        # then the return value isn't set by this point.
        # So assign it.
        init_str << split_str if i.zero?
        # Breaks and returns init_str
        break init_str
      end

      # Add to the initial string, which is also the return string.
      init_str << +' ' << split_str

      # The first string will have a space at the start.
      # We currently want to keep it.
      #init_str.strip! if i.zero?
      i += 1
    end

    # Remove the starting space.
    trunc_str.strip!

    trunc_str.gsub!(/#{magic_char_to_newline}/, "\n")

    # And then add an ellipsis at the end.
    if trunc_str.length + 1 < max_characters
      trunc_str << ' [. . .]'
    elsif trunc_str.length < max_characters
      trunc_str << '…'
    end

    #return trunc_str
    trunc_str
  end

end
#class String



# Extend the Array class.
class Array
  # Return all elements in an array except the N last.
  # Lazy way of doing [0..-3] for .clip(2)
  #
  # @param n_chars [Integer] How many N elements to remove from the end of the array.
  # @return [Array] A new array with all array elements 1 to Last-N
  #
  # @example
  #   [1,2,3,4,5].clip    => [1,2,3,4]
  #   [1,2,3,4,5].clip(2) => [1,2,3]
  #
  def clip(n_chars = 1)
    n_chars = size if n_chars >= size

    #return take size - n
    (take size - n_chars)
  end

end
#class Array



# Extend the Integer class
class Integer
  # Set the built-in max values for an integer. Without getting converted to a big-int object.
  MACHINE_BYTES = [+'foo'].pack('p').size
  # => 8

  MACHINE_BITS = MACHINE_BYTES * 8
  # => 64

  MACHINE_MAX_SIGNED = 2**(MACHINE_BITS - 1) - 1
  # => 9223372036854775807

  MACHINE_MAX_UNSIGNED = 2**MACHINE_BITS - 1
  # => 18446744073709551615
end
#class Integer



# Extend the Kernel core module.
module Kernel

  # Runs a block with warning messages supressed.
  #
  # @return [nil]
  #
  def run_supressed(&block)
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    yield block
    $VERBOSE = original_verbosity

    #return nil
    nil
  end

end
#module Kernel



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
