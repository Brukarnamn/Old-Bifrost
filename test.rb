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
  html_str = %q[<div class="artikkelinnhold"> <span class="oppslagsord b" id="67512">nokon</span> <span class="oppsgramordklasse" onclick="vise_fullformer(&quot;67512&quot;)">det.</span> (norrønt <span style="font-style: italic">nǫkkurr</span>, samandrege av fleire ord, opphavleg 'ikkje veit eg kven')<span class="utvidet"></span></div><div class="tyding utvidet" style="margin-top: 15px;"> <span style="font-family:  Arial, Verdana; font-weight: 900; font-size: 100%;">1</span> ein viss, ein eller annan, einkvan; (i fleirtal:) somme, visse (ikkje mange)<div class="doemeliste utvidet"><span class="doeme utvidet"><span style="font-style: italic">er det <span style="font-style: italic">nokon</span> kiosk i nærleiken?</span></span></div><div class="tyding utvidet" style="margin-top: 15px;"> <span class="utvidet"><img src="/grafikk/black_circle_e.png" width="6px" height="6px" /></span> i nøytrum: eitt eller anna, eitkvart<div class="doemeliste utvidet"><span class="doeme utvidet"><span style="font-style: italic">det er noko i vegen med bilen</span></span></div></div><div class="tyding utvidet" style="margin-top: 15px;"> <span class="utvidet"><img src="/grafikk/black_circle_e.png" width="6px" height="6px" /></span> ein viss ting<div class="doemeliste utvidet"><span class="doeme utvidet"><span style="font-style: italic">det hende meg noko underleg i går</span></span><span> / </span><span class="doeme utvidet"><span style="font-style: italic">han er noko i postverket</span> har ei eller anna stilling</span></div></div></div>]
  example_nodes = Hpricot(html_str)

  str = OrdbokDictionary.parse_ordbok_html_node_tree(example_nodes)
  puts '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
  Debug.pp str
end


