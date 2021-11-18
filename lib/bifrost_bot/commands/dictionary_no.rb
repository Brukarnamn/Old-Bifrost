# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the dictionary lookup to ordbok.uib.no
    # Discordrb::Commands::CommandEvent
    #
    # This has been moved over to the dictionary bot, but left for historical
    # reasons.
    #
    module DictionaryNOUiB
      extend Discordrb::Commands::CommandContainer

      command(:int102844909202347536_dict_no_ordbok_uib, BOT_CONFIG.bot_command_complex_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'ordbok_uib_no_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:complex_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert ORDBOK_NO response here.'
        #event_obj.respond 'r Insert ORDBOK_NO response here.'

        # This method shouldn't really be called at if it was a private message,
        # but just in case there was a brainfart somewhere.
        return nil if helper_obj.is_private_message

        max_results_to_show = BOT_CONFIG.max_dictionary_results_to_show

        case helper_obj.command
        when 'NB', 'BM'      #, /^BOKM(Å|AA|A)L$/
          is_nynorsk = false
          is_expanded = false
        when 'NN'            #, 'NYNORSK'
          is_nynorsk = true
          is_expanded = false
        when /^(NB|BM)[UE]$/, # 'NBU', 'NBU', 'BME', 'BME', #/^(NB|BM)[UE]$/, /^BOKM(Å|AA|A)L[\-_]?(UTVIDET|EXPANDED)$/,
          is_nynorsk = false
          is_expanded = true
        when 'NNU', 'NNE'     #                             #/^(NN)[UE]$/,    /^NYNORSK[\-_]?(UTVIDET|EXPANDED)$/
          is_nynorsk = true
          is_expanded = true
        else
          response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
          response_str = helper_obj.substitute_event_vars response_str

          event_obj.respond response_str
          return nil
        end

        ordbok_entry_hash = ordbok_uib_no_dictionary_lookup_wrapper(helper_obj.command_args_str, is_nynorsk, is_expanded, max_results_to_show)

        helper_obj.event_respond_with_embed(event_obj, ordbok_entry_hash) if !ordbok_entry_hash.empty?

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      # Do some preliminary checking on the search word.
      # Then look up this word in the dictionary and format it as en embedded Discord text-ball.
      #
      # @param search_string [String] The word to look for in the dictionary.
      # @param is_nynorsk [true,false] True if nynorsk, false if bokmål.
      # @param is_expanded [true,false] True if show more than just the words and their word classes.
      # @param max_results_to_show [Integer] The max amount of word definitions to show, even if the result itself gave more hits.
      # @return [Hash] Hash with the fields necessary to make a Discord embed.
      #
      def self.ordbok_uib_no_dictionary_lookup_wrapper(search_string, is_nynorsk = true, is_expanded = false, max_results_to_show = 5)
        # Remove strange characters.
        if /#{BOT_CONFIG.illegal_dictionary_search_characters}/.match?(search_string)
          convert_msg = Debug.msg('---------- BAD? Illegal search characters: ----------', 'red') << "\n" <<
                        Debug.msg('Changed from; ', 'yellow') << Debug.msg(search_string.to_s) << "\n" <<
                        Debug.msg('Changed into: ', 'yellow')
          #
          search_string = search_string.gsub(/#{BOT_CONFIG.illegal_dictionary_search_characters}/, '')

          puts(+convert_msg << Debug.msg(search_string.to_s))
        end

        # If you downcase the search string then dictionary entries that do in fact
        # contain upper case letters can't be found.
        # Unless regular search is turn on, but then you get multiple search hits for words.
        search_string = search_string.downcase

        # Since the results are different if you use 'bare_oppslag' or 'alle_former' store them seperately in the cache.
        encoded_search_string = +'' << (is_nynorsk ? 'nn' : 'nb') << '_' <<
                                (is_expanded ? 'alle' : 'opp') << '_' <<
                                URI.encode_www_form_component(search_string).downcase << ''
        #

        word_response_hash = DICTIONARY_CACHE.fetch_dictionary_keyvalue(encoded_search_string)
        if !word_response_hash.nil? # DICTIONARY_CACHE.key?(encoded_search_string)
          puts Debug.msg('Using memory cached dictionary values.', 'cyan') if BOT_CONFIG.debug
          #word_response_hash = DICTIONARY_CACHE[encoded_search_string]
        else
          word_response_hash = BifrostBot::OrdbokDictionary.ordbok_uib_no_dictionary_lookup(search_string, is_nynorsk, is_expanded)
          #word_response_hash[:timestamp] = Time.now.utc

          if word_response_hash.nil_or_empty?
            word_response_hash[:error] = 'Internal search error. Is the site down? Is the code broken?'
            Debug.error word_response_hash[:error]
          else
            #DICTIONARY_CACHE[encoded_search_string] = word_response_hash
            DICTIONARY_CACHE.store_dictionary_keyvalue(encoded_search_string, word_response_hash)
          end
        end

        #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(word_response_hash, 0, false) if BOT_CONFIG.debug #BOT_CONFIG.debug_spammy

        author_str = is_nynorsk ? 'Nynorskordboka' : 'Bokmålsordboka'
        footer_str = 'Universitetet i Bergen og Språkrådet © 2020'

        word_count        = word_response_hash[:length]     || 0
        ordbok_url        = word_response_hash[:url]        || ''
        ordbok_url_simple = word_response_hash[:url_simple] || ''
        #timestamp        = word_response_hash[:timestamp]  || Time.now

        base_ordbok_url   = 'https://ordbok.uib.no'
        ordbok_info_url   = +'' << base_ordbok_url << '/info/' << (is_nynorsk ? 'nob' : 'bob') << '_forkl.html'

        amount_of_search_results = if word_count > max_results_to_show
                                     +'More than [' << max_results_to_show.to_s << '](' << ordbok_url << ')'
                                   else
                                     +'[' << word_count.to_s << '](' << ordbok_url << ')'
                                   end
        #
        expanded_command_str = +'' << (is_nynorsk ? 'nn' : 'bm') << 'e'
        expanded_str = +' or try !**' << expanded_command_str << '** that searches for many of the inflected word forms too.'
        description_str = if word_count < 1
                            +'No search results for [' << search_string << '](' << ordbok_url << '). ' \
                            'You might want to modify your search' << (is_expanded ? '.' : expanded_str)
                          else
                            # [42](https://...) entries were found for [`word` (click me)](https://...).
                            # [Help](https://...).
                            +'' << amount_of_search_results << ' ' << (word_count > 1 ? 'entries were' : 'entry was') << ' found for ' \
                            '[`' << search_string << '` (click me)](' << ordbok_url << '). ' \
                            '[Help](' << ordbok_info_url << ').'
                          end
        #
        description_str += +"\n" << 'Showing only the ' << max_results_to_show.to_s << ' first results.' if word_count > max_results_to_show
        description_str = word_response_hash[:error] if !word_response_hash[:error].empty?

        ordbok_entry_hash = {
          # rubocop:disable Layout/AlignHash
          #content: (+'**' << author_str << '**: Official spellings and inflections/conjugations/declensions:' << "\n" << ordbok_url_simple),
          content: (+'**' << author_str << '**: Official spellings and inflections: ' << ordbok_url_simple),
          description: description_str,
          footer: {
            text: footer_str
          },
          fields: nil
          # rubocop:enable Layout/AlignHash
        }

        if !word_response_hash[:words].nil_or_empty?
          fields_array = []
          word_definition_counter = 1

          word_response_hash[:words].each do |single_ordbok_word_obj|
            # The field header is the list of the valid (root/base) spellings for this word.
            word_header = ''
            single_ordbok_word_obj.keywords.each do |single_keyword|
              word_header += +'' << (word_header.empty? ? '' : ' | ') << '**' << single_keyword << '**'
            end
            word_header += +' ← (*' << single_ordbok_word_obj.search_word << '*)' if !single_ordbok_word_obj.search_word.empty?

            # The field text is all the rest of the word definition.
            word_text = +'' << single_ordbok_word_obj.word_definitions_header

            single_ordbok_word_obj.word_definitions_array.each do |single_def_hash|
              #Debug.pp single_def_hash if BOT_CONFIG.debug_spammy
              word_text += "\n" if !word_text.empty?

              # If examples are going to be shown.
              # This can take a lot of space on the screen for words with lots if information.
              #word_text += +'' << single_def_hash[:text] << "\n" if !single_def_hash[:text].nil?
              #word_text += +'' << single_def_hash[:examples] << "\n" if !single_def_hash[:examples].nil?

              # If examples are not going to be shown.
              word_text += single_def_hash[:text] if single_def_hash[:text]
              word_text += ' …' if single_def_hash[:examples]
            end

            #{
            #  # Header of the field. Supports limited subsection of markdown.
            #  # Max length 256 characters.
            #  name: '',
            #  # Main text of the field. Supports markdown in addition to url.
            #  # Max length 1024 characters.
            #  value: ''
            #}
            if word_text.length > 1_020
              word_text = word_text.truncate_words(1_000)
              word_text += +"\n… ***Entry too long*** …"
            end
            fields_array.push(name:  word_header,
                              value: word_text)
            #

            word_definition_counter += 1
            break if word_definition_counter > max_results_to_show
          end
          #loop

          ordbok_entry_hash[:fields] = fields_array
        end
        #if

        #return ordbok_entry_hash
        ordbok_entry_hash
      end

    end
    #module DictionaryNOUiB
  end
  #module Commands
end
#module BifrostBot
