module Debug
  public
  protected

  private

  # If support for 256 different colours
  #   for  code in {0..255};  do echo -e "\e[38;5;${code}m"'\\e[38;5;'"$code"m"\e[0m";  done
  @@colour_black  = "\e[1m\e[30m".freeze
  @@colour_red    = "\e[1m\e[31m".freeze
  @@colour_green  = "\e[1m\e[32m".freeze
  @@colour_yellow = "\e[1m\e[33m".freeze
  @@colour_blue   = "\e[1m\e[34m".freeze
  @@colour_purple = "\e[1m\e[35m".freeze
  @@colour_cyan   = "\e[1m\e[36m".freeze
  @@colour_white  = "\e[1m\e[37m".freeze
  @@colour_normal = "\e[0m".freeze

  @@indent_character = '[⮞'.freeze
  @@outdent_character = '⮘]'.freeze
  @@info_character = '·'.freeze



  public

  # Public
  # Prints out the caller's current source file and line number and current function.
  #
  # Argument
  # * message
  #   Custom message instead of the caller's current function name.
  #
  # Return
  #   nil
  # 
  def self.trace message = nil
    # For example
    #   app/controllers/welcome_controller.rb:18:in `index'
    call_stack = Kernel.caller
    @file,  @line,  @message = call_stack[0].split ':'
    @file2, @line2, @message2 = call_stack[1].split(':') if call_stack.size > 1
    #is_callstack_message = false

    # Format the file, line and function.
    if message
      message = @@colour_yellow + message + @@colour_normal
      #message = @@colour_cyan + message + @@colour_normal
    else
      #message = @message
      #is_callstack_message = true
    end

    current = caller_function_info_str(
      message: message || @message,
      is_callstack_message: (@message.nil? ? false : true),  #is_callstack_message,
      filename: @file, lineno: @line )
    #current = caller_function_info_str_old [ (message || @message), @file,  @line ]
    if message
      output = @@indent_character + ' ' + current + ' <]'
    else
      from = caller_function_info_str(
        message: @message2,
        is_callstack_message: (@message2.nil? ? false : true),
        filename: @file2, lineno: @line2 )
      #from   = caller_function_info_str_old [ @message2,             @file2, @line2 ]
      output = @@indent_character + ' ' + current + ' ← ' + from + ' <]'
    end

    puts output
    return nil
  end #trace



  # Public
  # Prints out a dividing line.
  #
  # Arguments:
  # * none
  #
  # Return:
  # * none
  #
  def self.divider message = nil, number_of_times = 7
    output = @@colour_blue

    if message
      number_of_times.times do; output += '_____'; end
      output += @@colour_cyan + message + @@colour_blue
      number_of_times.times do; output += '_____'; end
    else
      25.times do; output += '_____'; end
    end

    output += @@colour_normal
    puts output

  end #divider



  private

  # Private
  # Reformats the call stack information to a custom format.
  #
  # Arguments
  # * info_array
  #   Array containing information from the call stack:
  #   - The current function or custom message.
  #   - The current file.
  #   - The current line number.
  # * colour
  #   Specific colour to print out the some of the information in to make it easier to view on a terminal screen.
  #
  # Return
  #   String with the infomation formattet in a custom format.
  #
  #def self.caller_function_info_str info_array, colour = @@colour_normal
  def self.caller_function_info_str( hash_args = {} )
    defaults = {
      message:              '',
      message_colour:       @@colour_purple,
      is_callstack_message: true,
      filename:             '<¿filename?>',
      lineno:               '<¿lineno?>',
    }
    hash_args = defaults.merge(hash_args)

    @message              = hash_args[:message]
    @msgcolour            = hash_args[:message_colour]
    @is_callstack_message = hash_args[:is_callstack_message]
    @file                 = hash_args[:filename]
    @line                 = hash_args[:lineno]

    # Original call stack line looks for example like this.
    #   app/controllers/welcome_controller.rb:18:in `index'
    # Now split into the three array parts.
    # @message = in `index'
    if @message && @is_callstack_message && @message.class == String 
      if m = @message.match(/\Ain `(.+)'\z/)
        @message = m[1]
      end
    else
      @message = '<<root>>'
    end
    @message = @msgcolour + @message + @@colour_normal

    # @file = welcome_controller.rb
    # @file = app/controllers/welcome_controller.rb
    # @file = /home/ra/claudia/app/controllers/welcome_controller.rb
    @file ||= ''
    fileparts = @file.split %r|[/\\:]|
    if fileparts.size > 1
      path = fileparts.clip 1
      file = fileparts.last
      @file = path.join('/') + '/' + @msgcolour + file + @@colour_normal
    else
      @file = @msgcolour + @file + @@colour_normal
    end

    # @line = 18
    @line ||= ''
    @line = @@colour_purple + @line + @@colour_normal

    return @message + ' ※ ' + @file + ' @ ' + @line.to_s
  end #caller_function_info_str



  def self.caller_function_info_str_old info_array, colour = @@colour_purple
    @message, @file, @line = info_array

    # Original call stack line looks for example like this.
    #   app/controllers/welcome_controller.rb:18:in `index'
    # Now split into the three array parts.
    # @message = in `index'
    if @message && @message.class == String
      if m = @message.match(/\Ain `(.+)'\z/)
        @message = m[1]
      end
    else
      @message = '<<root>>'
    end
    @message = colour + @message + @@colour_normal

    # @file = welcome_controller.rb
    # @file = app/controllers/welcome_controller.rb
    # @file = /home/ra/claudia/app/controllers/welcome_controller.rb
    @file ||= ''
    fileparts = @file.split %r|[/\\:]|
    if fileparts.size > 1
      path = fileparts.clip 1
      file = fileparts.last
      @file = path.join('/') + '/' + colour + file + @@colour_normal
    else
      @file = colour + @file + @@colour_normal
    end

    # @line = 18
    @line ||= ''
    @line = @@colour_purple + @line + @@colour_normal

    return @message + ' ※ ' + @file + ' @ ' + @line.to_s
  end #caller_function_info_str_old



end #Debug
