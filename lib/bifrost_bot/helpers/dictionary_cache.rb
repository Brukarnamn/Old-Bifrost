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
  # Helper class to store all the cached dictionary entires.
  # Because laziness.
  class DictionaryCache
    require 'debug'



    public

    attr_reader :keywords,
                :dictionary_sites
    #



    def initialize
      @keywords =         {} # Hash which contains all the memory cached dictionary entries.
      @dictionary_sites = {} # Contains dictionary sites.

      #return nil
      #nil
    end



    def to_s
      protected_write_values = %w[
        keywords
        dictionary_sites
      ]
      protected_write_values_hash = {}

      protected_write_values.each do |method|
        value = instance_variable_get('@' + method.to_s)
        protected_write_values_hash[method] = value
      end

      #{ protected_write: protected_write_values_hash }
      +'#<BifrostBot::DictionaryCache: ' << Debug.pp(protected_write_values_hash, 2, false)
    end
    #to_s



    # @param key_entry [String] The key to search for in the @keywords hash.
    # @return [Hash, nil] The Hash from the hash-key entry if the key exists, nil otherwise.
    def fetch_dictionary_keyvalue(key_entry)
      return nil if !@keywords.key?(key_entry)

      #return @keywords[key_entry]
      @keywords[key_entry]
    end



    # @param key_entry [String] The key to store the value for in the @keywords hash.
    # @param key_value [Hash] The value to store for in the hash-key.
    def store_dictionary_keyvalue(key_entry, key_value)
      @keywords[key_entry] = key_value
    end

  end
  #class DictionaryCache
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
