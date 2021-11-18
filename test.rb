#!/usr/bin/env ruby -wW2

# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# The name of this script.
SCRIPT_NAME = File.basename(__FILE__).freeze
#SCRIPT_NAME = $0

# The root folder of the bot script.
# d:/ruby/discordbot/test.rb
#   → d:/ruby/discordbot
ROOT_DIR = File.dirname(File.expand_path(__FILE__)).freeze

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
  require 'uri'
  #require 'sqlite3'

  # Turn warnings back on for the following modules/gems.
  $VERBOSE = true

  #require_relative 'debug'
  require 'debug'
  #require 'bifrost_bot/script_options'
  #require 'bifrost_bot/config'
  #require 'bifrost_bot/data_storage'
  require 'bifrost_bot/other/dictionary_ordbok_uib_no'

  Debug.colour_test
  #Debug.pp ARGV
end

# Set some of the configuration options manually.
BOT_CONFIG = OpenStruct.new
BOT_CONFIG.debug = true
BOT_CONFIG.debug_spammy = true

##################################################################################################
# The actual test stuff
#
BOT_CONFIG.illegal_dictionary_search_characters = '[^ \.\-\p{L}\p{M}]'
BOT_CONFIG.word_inflection_image_folder = 'e:/bifrost-discordbot'

test_ordbok = true
test_parser = false
is_nynorsk = false

if test_ordbok
  #search_word = ARGV[0] || 'huff'
  #search_word = 'vere'; is_nynorsk = true
  #search_word = 'veke'; is_nynorsk = true
  #search_word = 'noko'; is_nynorsk = true
  #search_word = 'huff'
  #search_word = 'gjere'; is_nynorsk = true
  #search_word = 'ass'
  search_word = 'si'

  #blåbærsyltetøy
  #hjelp
  #i hvert fall
  #merkelig
  #noko
  #nokon
  #nokre
  #sko
  #huff
  #glad
  #test
  #veke
  #vere
  #være

  #is_nynorsk = false
  #is_fritekst = false
  results = BifrostBot::OrdbokDictionary.ordbok_uib_no_dictionary_lookup(search_word, is_nynorsk)
  puts '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
  Debug.pp results
end

if test_parser
  html_str = %q[<div class="artikkelinnhold"></div>]
  example_nodes = Hpricot(html_str)

  str = OrdbokDictionary.parse_ordbok_html_node_tree(example_nodes)
  puts '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
  Debug.pp str
end


