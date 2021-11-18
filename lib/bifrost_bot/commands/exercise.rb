# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the exercises.
    # Discordrb::Commands::CommandEvent
    module Exercise
      extend Discordrb::Commands::CommandContainer

      command(:int503406229856943309_exercise, BOT_CONFIG.bot_command_exercise_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'show_exercise_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:exercise_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert EXERCISE response here.'
        #event_obj.respond 'r Insert EXERCISE response here.'

        exercise_obj_or_error_str = choose_exercise(exercise_category: helper_obj.command_args_str)

        # If it is a string, and not an object, something went wrong. Display it.
        if exercise_obj_or_error_str.is_a?(String)
          event_obj.respond exercise_obj_or_error_str
          return nil
        end

        exercise_user_obj = BOT_CACHE.get_exercise_user_data(helper_obj.user_id)
        exercise_user_obj.update_new_exercise_shown(exercise_obj_or_error_str)
        #Debug.pp exercise_user_obj

        exercise_embed_data_hash = exercise_obj_or_error_str.to_embed_hash
        embed_return_hash = helper_obj.create_discord_embed(exercise_embed_data_hash)
        content = embed_return_hash[:content]
        embed_obj = embed_return_hash[:embed]

        if helper_obj.is_private_message
          event_obj.send_embed(content, embed_obj)
        else
          event_obj.author.pm.send_embed(content, embed_obj)

          public_channel_msg = +'' << helper_obj.user_mention << ', please check your private messages.'
          event_obj.channel.send_temporary_message(public_channel_msg, 10) if !exercise_user_obj.has_responded_in_channel
          exercise_user_obj.has_responded_in_channel = true
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      command(:int124582407849755283_answer_exercise, BOT_CONFIG.bot_command_exercise_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'answer_exercise_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:exercise_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert EXERCISE ANSWER response here.'
        #event_obj.respond 'r Insert EXERCISE ANSWER response here.'

        exercise_user_obj = BOT_CACHE.get_exercise_user_data(helper_obj.user_id)
        exercise_obj = exercise_user_obj.current_exercise
        #Debug.pp exercise_user_obj

        if exercise_obj.nil?
          event_obj.respond 'You have not started on any (new) exercises yet. Or I forgot what you did after I had a brief nap.'
          return nil
        end

        return nil if helper_obj.command_args_str.empty?

        response_str = +'**' << helper_obj.command_args_str << '** is '
        correct_response = exercise_obj.check_answer(helper_obj.command_args_str)
        #Debug.pp correct_response

        if correct_response
          exercise_user_obj.update_correct_answer
          #Debug.pp exercise_user_obj

          response_str += '**correct**! Well done. '

          correct_streak = exercise_user_obj.correct_streak_count
          response_str += if correct_streak < 10
                            ':ok_hand:'
                          elsif correct_streak < 50
                            ':sunglasses:'
                          elsif correct_streak < 100
                            ':nerd:'
                          else
                            ':nerd: :100:'
                          end
          #
        else
          exercise_user_obj.update_wrong_answer
          #Debug.pp exercise_user_obj

          response_str += '**wrong**. :confused:'
          answer_explanation = exercise_obj.check_for_explanation(helper_obj.command_args_str)

          response_str += +"\n" << answer_explanation if !answer_explanation.nil?
        end
        event_obj.author.pm(response_str)

        if !helper_obj.is_private_message
          public_channel_msg = +'' << helper_obj.user_mention << ', please check your private messages.'
          event_obj.channel.send_temporary_message(public_channel_msg, 10) if !exercise_user_obj.has_responded_in_channel
          exercise_user_obj.has_responded_in_channel = true
        end

        if correct_response
          exercise_obj_or_error_str = choose_exercise(exercise_category_keyword: exercise_obj.category_key)

          # If it is a string, and not an object, something went wrong. Display it.
          if exercise_obj_or_error_str.is_a?(String)
            event_obj.respond exercise_obj_or_error_str
            return nil
          end

          #exercise_user_obj = BOT_CACHE.get_exercise_user_data(helper_obj.user_id)
          exercise_user_obj.update_new_exercise_shown(exercise_obj_or_error_str)
          #Debug.pp exercise_user_obj

          exercise_embed_data_hash = exercise_obj_or_error_str.to_embed_hash
          embed_return_hash = helper_obj.create_discord_embed(exercise_embed_data_hash)
          content = embed_return_hash[:content]
          embed_obj = embed_return_hash[:embed]

          sleep 1.5
          event_obj.author.pm.send_embed(content, embed_obj)
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      command(:int397268707654402598_reshow_exercise, BOT_CONFIG.bot_command_exercise_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'reshow_exercise_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:exercise_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert EXERCISE RE-SHOW response here.'
        #event_obj.respond 'r Insert EXERCISE RE-SHOW response here.'

        exercise_user_obj = BOT_CACHE.get_exercise_user_data(helper_obj.user_id)
        exercise_obj = exercise_user_obj.current_exercise
        #Debug.pp exercise_user_obj

        if exercise_obj.nil?
          event_obj.respond 'You have not started on any (new) exercises yet. Or I forgot what you did after I had a brief nap.'
          return nil
        end

        exercise_embed_data_hash = exercise_obj.to_embed_hash
        embed_return_hash = helper_obj.create_discord_embed(exercise_embed_data_hash)
        content = embed_return_hash[:content]
        embed_obj = embed_return_hash[:embed]

        if helper_obj.is_private_message
          event_obj.send_embed(content, embed_obj)
        else
          event_obj.author.pm.send_embed(content, embed_obj)

          public_channel_msg = +'' << helper_obj.user_mention << ', please check your private messages.'
          event_obj.channel.send_temporary_message(public_channel_msg, 10) if !exercise_user_obj.has_responded_in_channel
          exercise_user_obj.has_responded_in_channel = true
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      command(:int684060944247439054_exercise_status, BOT_CONFIG.bot_command_exercise_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'exercise_status_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:exercise_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert EXERCISE STATUS response here.'
        #event_obj.respond 'r Insert EXERCISE STATUS response here.'

        if !helper_obj.is_private_message && !helper_obj.command_args_str.empty?
          tagged_user = BOT_OBJ.parse_mention(helper_obj.command_args_str)
          # <User username=Bifrost-dev id=361603350975741952 discriminator=0209>
          #ap tagged_user
        end

        show_user_id = if tagged_user.nil? || tagged_user.class != Discordrb::User
                         helper_obj.user_id
                       else
                         tagged_user.id
                       end
        #
        exercise_user_obj = BOT_CACHE.get_exercise_user_data(show_user_id)
        show_user_obj = BOT_CACHE.get_server_user(BOT_CONFIG.bot_runs_on_server_id, show_user_id)
        #Debug.pp show_user_obj

        user_status_embed_hash = {
          author: {
            icon_url: show_user_obj.avatar_url,
            name:     +'' << show_user_obj.username << (show_user_obj.nick.nil_or_empty? ? '' : +' → ' << show_user_obj.nick)
          },
          footer: {
            #text: 'Statistics since the last time I slept.'
            text: +'– Statistics since ' << exercise_user_obj.created_at.to_s
          },
          #timestamp: BOT_CONFIG.bot_startup_time,
          fields: []
        }

        stat_values = {
          'Exercises shown:':        exercise_user_obj.number_of_shown.to_s,
          'Answers made:':           exercise_user_obj.number_of_answers.to_s,
          'Current correct streak:': exercise_user_obj.correct_streak_count.to_s,
          'Highest correct streak:': exercise_user_obj.highest_correct_streak_count.to_s,
          'Correct:':                exercise_user_obj.number_of_correct.to_s,
          'Wrong:':                  exercise_user_obj.number_of_wrong.to_s,
          'Stat resets:':            exercise_user_obj.reset_count.to_s
        }
        stat_values.each do |key, value|
          user_status_embed_hash[:fields].push(name: key, value: value, inline: true)
        end

        embed_return_hash = helper_obj.create_discord_embed(user_status_embed_hash)
        content = embed_return_hash[:content]
        embed_obj = embed_return_hash[:embed]

        event_obj.send_embed(content, embed_obj)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      command(:int258934473698704703_reset_exercise_status, BOT_CONFIG.bot_command_exercise_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'exercise_status_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:exercise_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert RESET EXERCISE STATUS response here.'
        #event_obj.respond 'r Insert RESET EXERCISE STATUS response here.'

        exercise_user_obj = BOT_CACHE.get_exercise_user_data(helper_obj.user_id)
        exercise_user_obj.reset_stats

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      def self.choose_exercise(exercise_category: nil, exercise_category_keyword: nil)
        #return_string = nil
        exercises_data_hash = BOT_CONFIG.bot_exercises
        exercise_obj_hash = {}

        return_string = 'No exercises have been added yet.'
        return return_string if !exercises_data_hash.length.positive?

        lookup_hash = choose_exercise_category(exercise_category: exercise_category, exercise_category_keyword: exercise_category_keyword)
        return lookup_hash[:error] if !lookup_hash[:error].nil?

        exercise_category_entry_key = lookup_hash[:key]
        lookup_hash = choose_exercise_subcategory(exercise_category_entry_key)
        return lookup_hash[:error] if !lookup_hash[:error].nil?

        exercise_subcategory_entry_key  = lookup_hash[:key]
        exercise_obj_hash[:title]       = lookup_hash[:title_text]
        exercise_obj_hash[:text_header] = lookup_hash[:task_text]

        lookup_hash = choose_exercise_question_from_subcategory(exercise_category_entry_key, exercise_subcategory_entry_key)
        return lookup_hash[:error] if !lookup_hash[:error].nil?

        exercise_subcategory_array_random_index = lookup_hash[:key]
        exercise_subcategory_array = exercises_data_hash[exercise_category_entry_key][exercise_subcategory_entry_key]
        chosen_exercise_data_hash  = exercise_subcategory_array[exercise_subcategory_array_random_index]

        if BOT_CONFIG.debug_spammy
          _debug_data_hash = {
            key:    exercise_category_entry_key,
            subkey: exercise_subcategory_entry_key,
            index:  exercise_subcategory_array_random_index,
            data:   chosen_exercise_data_hash
          }
          #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(_debug_data_hash, 0, false) if BOT_CONFIG.debug_spammy
        end

        # Now that an exercise has been selected, fill in some of the extra information before making a new object.
        #exercise_obj_hash[:content] = nil # Generated by object
        #exercise_obj_hash[:title] = nil # Set earlier
        #exercise_obj_hash[:description] = nil # Generated by object
        #exercise_obj_hash[:footer] = nil # Generated by object
        #exercise_obj_hash[:fields] = nil # Generated by object
        exercise_obj_hash[:category_key] = exercise_category_entry_key
        exercise_obj_hash[:subcategory_key] = exercise_subcategory_entry_key
        exercise_obj_hash[:index] = exercise_subcategory_array_random_index
        exercise_obj_hash[:number] = chosen_exercise_data_hash[:number]
        #exercise_obj_hash[:text_header] = nil # Set earlier
        #exercise_obj_hash[:text_start] = nil # Set below
        exercise_obj_hash[:sentence] = chosen_exercise_data_hash[:sentence]
        exercise_obj_hash[:meaning] = chosen_exercise_data_hash[:meaning]
        exercise_obj_hash[:correct] = chosen_exercise_data_hash[:correct]
        exercise_obj_hash[:wrong] = chosen_exercise_data_hash[:wrong]
        #exercise_obj_hash[:text_id] = nil # Generated by object

        if exercise_obj_hash[:number].nil_or_empty? || exercise_obj_hash[:sentence].nil_or_empty? || exercise_obj_hash[:correct].nil_or_empty?
          return_string = +'**INTERNAL ERROR**: Not enough data to show an exercise properly.' \
                          ' **Error key**: ' << exercise_subcategory_array_random_index.to_s << ' ← ' << exercise_subcategory_entry_key.to_s
          #
          return return_string
        end

        extra_text_hash = exercise_subcategory_array[0]
        task_text_str = ''

        if extra_text_hash.nil_or_empty? || !extra_text_hash.is_a?(Hash)
          return_string = +'**INTERNAL ERROR**: Unexpected format in the exercise data. **Error key**: Extra ← ' << exercise_subcategory_entry_key.to_s << ''
          return return_string
        end

        extra_text_hash.each do |number_regexp, number_regexp_text|
          next if !exercise_obj_hash[:number].to_s.match?(/^#{number_regexp}$/)

          task_text_str += +'' << (task_text_str.empty? ? '' : "\n") << number_regexp_text
        end
        exercise_obj_hash[:text_start] = task_text_str

        chosen_exercise_obj = ExerciseData.new(exercise_obj_hash)
        error_str = chosen_exercise_obj.create_exercise_text

        return error_str if !error_str.nil?

        if BOT_CONFIG.debug_spammy
          _debug_data_hash = {
            exeobjhash: exercise_obj_hash,
            exeobj:     chosen_exercise_obj
          }
          #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(_debug_data_hash, 0, false) if BOT_CONFIG.debug_spammy
        end

        # All seems to have gone well, so returning the object.
        #return chosen_exercise_obj
        chosen_exercise_obj
      end




      def self.choose_exercise_category(exercise_category: nil, exercise_category_keyword: nil)
        exercises_data_hash = BOT_CONFIG.bot_exercises
        return_datahash = {
          key:   nil,
          error: nil
        }

        # If a keyword is supplied, try to use that.
        # If a category keyword is supplied, try to choose an exercise from that category.
        if exercise_category_keyword
          exercise_category_entry_key = exercise_category_keyword if exercises_data_hash.key?(exercise_category_keyword)
        elsif exercise_category
          exercise_category_entry_key = BOT_CONFIG.find_bot_message_entry('EXERCISES', exercise_category, true)
        end

        # Otherwise, choose a main category at random.
        if exercise_category_entry_key.nil?
          exercises_data_hashkeys_array = exercises_data_hash.keys
          exercise_category_random_index = Random.new.rand(0..(exercises_data_hashkeys_array.length - 1))

          exercise_category_entry_key = exercises_data_hashkeys_array[exercise_category_random_index]
        end
        #Debug.pp(index: exercise_category_random_index, key: exercise_category_entry_key) if BOT_CONFIG.debug_spammy

        return_datahash[:key]   = exercise_category_entry_key
        return_datahash[:error] = '**INTERNAL ERROR**: There was an internal error when choosing an exercise category.' if exercise_category_entry_key.nil?

        #return return_datahash
        return_datahash
      end



      def self.choose_exercise_subcategory(exercise_category_entry_key)
        exercises_data_hash = BOT_CONFIG.bot_exercises
        return_datahash = {
          key:        nil,
          error:      nil,
          title_text: nil,
          task_text:  nil
        }

        exercise_category_hash = exercises_data_hash[exercise_category_entry_key] if exercises_data_hash.key?(exercise_category_entry_key)
        if exercise_category_hash.nil?
          return_datahash[:error] = +'**INTERNAL ERROR**: No data found for category. **Error key**: ' << exercise_category_entry_key.to_s
          return return_datahash
        end

        # Choose a random sub-category from within the main category.
        exercise_category_hashkeys_array = exercise_category_hash.keys
        filtered_exercise_category_hashkeys_array = []

        exercise_category_hashkeys_array.each do |subcategory_key|
          #puts subcategory_key
          case subcategory_key.to_s
          when 'aliases'
            # Do nothing.
            next
          when 'title_text'
            return_datahash[:title_text] = exercise_category_hash[subcategory_key]
            next
          when 'task_text'
            return_datahash[:task_text] = exercise_category_hash[subcategory_key]
            next
          else
            filtered_exercise_category_hashkeys_array.push subcategory_key
          end
        end

        if !filtered_exercise_category_hashkeys_array.length.positive?
          return_datahash[:error] = +'No exercises have been added to this category – yet. **Error key**: ' << exercise_category_entry_key.to_s
          return return_datahash
        end

        exercise_subcategory_random_index = Random.new.rand(0..(filtered_exercise_category_hashkeys_array.length - 1))
        exercise_subcategory_entry_key = filtered_exercise_category_hashkeys_array[exercise_subcategory_random_index]

        #Debug.pp(index: exercise_subcategory_random_index, subkey: exercise_subcategory_entry_key) if BOT_CONFIG.debug_spammy

        return_datahash[:key]   = exercise_subcategory_entry_key
        return_datahash[:error] = '**INTERNAL ERROR**: There was an internal error when choosing an exercise sub-category.' if exercise_subcategory_entry_key.nil?

        #return return_datahash
        return_datahash
      end



      def self.choose_exercise_question_from_subcategory(exercise_category_entry_key, exercise_subcategory_entry_key)
        exercises_data_hash = BOT_CONFIG.bot_exercises
        return_datahash = {
          key:   nil,
          error: nil
        }

        exercise_category_hash = exercises_data_hash[exercise_category_entry_key] if exercises_data_hash.key?(exercise_category_entry_key)
        if exercise_category_hash.nil?
          return_datahash[:error] = +'**INTERNAL ERROR**: No data found for category. **Error key**: ' << exercise_category_entry_key.to_s
          return return_datahash
        end

        exercise_subcategory_array = exercise_category_hash[exercise_subcategory_entry_key] if exercise_category_hash.key?(exercise_subcategory_entry_key)
        if exercise_subcategory_array.nil?
          return_datahash[:error] = +'**INTERNAL ERROR**: No data found for subcategory. **Error key**: ' << exercise_subcategory_entry_key.to_s
          return return_datahash
        elsif !exercise_subcategory_array.is_a?(Array)
          return_datahash[:error] = +'**INTERNAL ERROR**: Unexpected format for this section. **Error key**: ' << exercise_subcategory_entry_key.to_s
          return return_datahash
        elsif exercise_subcategory_array.length < 2
          return_datahash[:error] = +'**INTERNAL ERROR**: Not enough data to show an exercise properly. **Error key**: ' << exercise_subcategory_entry_key.to_s
          return return_datahash
        end

        # Choose a random exercise from the array.
        # The first array element should contain extra information to display.
        exercise_subcategory_array_random_index = Random.new.rand(1..(exercise_subcategory_array.length - 1))

        #Debug.pp(key: exercise_category_entry_key, subkey: exercise_subcategory_entry_key, index: exercise_subcategory_array_random_index) if BOT_CONFIG.debug_spammy

        return_datahash[:key] = exercise_subcategory_array_random_index

        #return return_datahash
        return_datahash
      end

    end
    #module Exercise
  end
  #module Commands
end
#module BifrostBot
