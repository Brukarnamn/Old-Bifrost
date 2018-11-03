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
  # Helper class to keep track of when and where an activity question was made.
  # And what the answer is.
  class ActivityTask
    require 'debug'
    require 'time'

    public

    attr_reader :time,
                :server_id,
                :channel_id,
                :hash_key_word,
                :array_index,
                :question,
                :answer,
                :answer_code
    #
    attr_accessor :answer_peeks
    #



    def initialize(activity_data_hash)
      @time          = Time.now.utc
      @server_id     = activity_data_hash[:server_id]     || nil
      @channel_id    = activity_data_hash[:channel_id]    || nil
      @hash_key_word = activity_data_hash[:hash_key_word] || nil
      @array_index   = activity_data_hash[:array_index]   || nil
      @question      = activity_data_hash[:question]      || nil
      @answer        = activity_data_hash[:answer]        || nil
      @answer_code   = nil
      @answer_peeks  = {}

      # Fill in @answer_code with a 3-letter code to make the answer visible to everybody.
      generate_code

      #return nil
      #nil
    end



    def to_s
      protected_write_values = %w[
        server_id
        channel_id
        hash_key_word
        array_index
        question
        answer
        answer_code

        answer_peeks
      ]
      protected_write_values_hash = {}

      protected_write_values.each do |method|
        value = instance_variable_get('@' + method.to_s)
        protected_write_values_hash[method] = value
      end

      #{ protected_write: protected_write_values_hash }
      +'#<BifrostBot::ActivityTask: ' << Debug.pp(protected_write_values_hash, 2, false)
    end
    #to_s



    def generate_code
      # Generate the alphabet from a - z
      alphabet = [*('A'..'H'), 'i', *('J'..'Z'), 'Æ', 'Ø', 'Å']

      public_code = +''

      # Pick a random number number from between 1..26
      # and use this number as index in the alphabet array to
      # generate a random 3 letter code.
      2.times { |_i| public_code << alphabet[Random.new.rand(0..(alphabet.length - 1))] }

      @answer_code = public_code

      #return public_code
      public_code
    end



    def check_answer_code(check_str)
      return true if @answer_code.casecmp?(check_str)

      #return false
      false
    end



    def add_user_peek(user_distinct_str)
      @answer_peeks[user_distinct_str] = true
    end



    def list_user_peeks
      @answer_peeks.keys
    end

  end
  #class ActivityTask
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


