# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot commands.
  module Commands
    require 'debug'

    # Handle the reload of the server configuration files.
    # Discordrb::Commands::CommandEvent
    module RiddleText
      extend Discordrb::Commands::CommandContainer

      command(:int862510805397623761_show_riddle_answer, BOT_CONFIG.bot_command_default_attributes) do |event_obj|
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj
        rate_limit_symbol = (+'riddle_view_' << helper_obj.server_id.to_s << '_' << helper_obj.user_id.to_s).to_sym
        rate_limit_time = RATE_LIMITER.rate_limited?(:normal_cmds, rate_limit_symbol)

        if rate_limit_time
          rate_limit_str = BOT_CONFIG.bot_event_responses[:spamming_cmds]
          rate_limit_str = helper_obj.substitute_event_vars(rate_limit_str, rate_limit_time.round(1))
          event_obj.channel.send_temporary_message(rate_limit_str, 60)

          return nil
        end

        #event_obj << '<< Insert RIDDLE VIEW response here.'
        #event_obj.respond 'r Insert RIDDLE VIEW response here.'

        # This method can be used in both private and public.
        #return nil if helper_obj.is_private_message

        if !(helper_obj.user_is_server_contributor? || helper_obj.user_is_server_moderator?)
          response_str = BOT_CONFIG.bot_event_responses[:illegal_cmd]
          response_str = helper_obj.substitute_event_vars response_str

          event_obj.respond response_str
          return nil
        end

        last_activity_obj = BOT_CACHE.last_activity_question(helper_obj.server_id)
        #Debug.pp last_activity_obj
        return nil if last_activity_obj.nil?

        answer_str = if last_activity_obj.answer.nil_or_empty?
                       'An answer is missing.'
                     else
                       last_activity_obj.answer
                     end
        #

        # If the supplied commandargument is 'list' show the list.
        if helper_obj.uc_command_args_str.match?(/^LIST/)
          cheater_str = last_activity_obj.list_user_peeks.join ', '

          response_str = +'These people have looked up the answer (so far):' << "\n" << cheater_str
          event_obj.respond response_str

          return nil
        end

        # Add a list of who has seen the answer so far.
        last_activity_obj.add_user_peek(helper_obj.user_distinct)

        # Show the answer if it is not a private message, and the supplied argument equals the questions little cheat code
        if !helper_obj.is_private_message && last_activity_obj.check_answer_code(helper_obj.uc_command_args_str)
          response_str = +'||' << answer_str << '||'
          event_obj.respond response_str

          return nil
        end

        # Otherwise, send a private message to the user with the answer and the cheat code.
        question_str = if last_activity_obj.question.nil_or_empty?
                         '<No text>'
                       else
                         last_activity_obj.question
                       end
        #
        response_str = +'━━━ __**Text/riddle/task shown**__ (if any) ━━━' << "\n" <<
                       question_str << "\n" \
                       '━━━ __**Supplied answer**__ (if any) ━━━' << "\n" <<
                       answer_str << "\n" \
                       '━━━━━━━━━━━━━━━━━━━━' << "\n" \
                       'You can show the answer in any channel if you add this cheat code: **' << last_activity_obj.answer_code << "**\n" \
                       'You can see who else watched this if you add: **list**' << "\n" \
                       'Until then, maybe try to provide hints?'
        #
        event_obj.author.pm(response_str)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end



      def self.check_if_inactivity_text_should_be_shown
        # Fetch the basic information first.
        server_id = BOT_CONFIG.bot_runs_on_server_id
        last_server_activity = BOT_CACHE.last_activity(server_id)
        last_server_activity_time = last_server_activity[:time]
        last_server_activity_user_id = last_server_activity[:user_id]
        #Debug.pp(server: server_id, last_activity: last_server_activity) if BOT_CONFIG.debug_spammy

        # Skip the rest if the last active user was the bot itself.
        #puts last_server_activity_user_id == BOT_CONFIG.client_id
        return nil if last_server_activity_user_id == BOT_CONFIG.client_id

        # If the time of last acitivy was too long ago, try to make some activity.
        #   2018-10-12 20:55:31 UTC +  3 * 60 < 2018-10-12 21:00:01 UTC → true  (current time is outside of the 3 min range; it has been more than 3 min)
        #   2018-10-12 20:55:31 UTC + 10 * 60 < 2018-10-12 21:00:01 UTC → false (current time is inside the 10 min range; it has not been more than 10 min)
        server_inactivity_time = BOT_CONFIG.server_inactivity_time
        current_time_utc = Time.now.utc
        #Debug.pp(time_now: current_time_utc, time_last: last_server_activity_time, wait: server_inactivity_time) if BOT_CONFIG.debug_spammy

        #puts last_server_activity_time + server_inactivity_time > current_time_utc
        return nil if last_server_activity_time + server_inactivity_time > current_time_utc

        # Check if it inside the time interval where the bot should do anything.
        # To avoid possibly creating a lot of stuff happening when most users (or maybe mods?) are asleep anyway.
        current_hour_minute = current_time_utc.strftime(BOT_CONFIG.timestamp_format_hmsms)
        interval_start = BOT_CONFIG.server_time_interval_start
        interval_end   = BOT_CONFIG.server_time_interval_end
        Debug.pp(hour_now: current_hour_minute, hour_start: interval_start, hour_end: interval_end) if BOT_CONFIG.debug_spammy

        # If the change to UTC made them change date and thus made the
        # end be less than the start, or if they just were entered that way
        # Then flip them around and change the logic tests accordingly.
        if interval_start < interval_end
          # Accept between f.ex. '02:00:00' and '24:00:00', otherwise return.

          #puts current_hour_minute < interval_start
          #puts current_hour_minute > interval_end
          Debug.pp('cur<start': current_hour_minute < interval_start, 'cur>end': current_hour_minute > interval_end, outside: (current_hour_minute < interval_start || current_hour_minute > interval_end)) #if BOT_CONFIG.debug_spammy

          outside_accepted_time_interval = (current_hour_minute < interval_start || current_hour_minute > interval_end)
        else
          # Entered as accept between f.ex. '11:00:00' and '03:00:00', otherwise return.
          # Flip values. Do not accept between '03:00:00' and '11:00:00', otherwise accept.
          temp_time_start = interval_start
          interval_start = interval_end
          interval_end   = temp_time_start

          #puts current_hour_minute < interval_start
          #puts current_hour_minute > interval_end
          #puts !(current_hour_minute < interval_start || current_hour_minute > interval_end)
          Debug.pp('cur<start': current_hour_minute < interval_start, 'cur>end': current_hour_minute > interval_end, outside: !(current_hour_minute < interval_start || current_hour_minute > interval_end)) #if BOT_CONFIG.debug_spammy

          outside_accepted_time_interval = !(current_hour_minute < interval_start || current_hour_minute > interval_end)
        end
        return nil if outside_accepted_time_interval

        # Update that the last activity was now to prevent if from do the same stuff
        # if nobody else did anything.
        BOT_CACHE.update_last_activity(server_id, BOT_CONFIG.client_id)

        # Fetch the information about the last activity, if anything exists.
        last_activity_obj = BOT_CACHE.last_activity_question(server_id)
        last_channel_id = last_activity_obj.channel_id if !last_activity_obj.nil?

        # Do stuff to find out which channel to post to.
        # Remove the last used channel to alternate between them all.
        # Also remove channels that don't have any text, but are added to check for activity.
        possible_output_channels = BOT_CONFIG.server_activity_channels.dup

        possible_output_channels.delete(last_channel_id)

        possible_output_channels.each_key do |channel_id|
          #puts channel_id, possible_output_channels[channel_id]
          possible_output_channels.delete(channel_id) if possible_output_channels[channel_id].nil?
        end

        possible_output_channels = possible_output_channels.keys
        Debug.pp(hash: BOT_CONFIG.server_activity_channels, all_keys: possible_output_channels, last: last_channel_id) if BOT_CONFIG.debug_spammy

        # Pick a random number number from between 1..arraylength
        # and use this number as index in the channel-id array to
        # pick the channel.
        selected_channel_id = if possible_output_channels.length.positive?
                                possible_output_channels[Random.new.rand(0..(possible_output_channels.length - 1))]
                              else
                                # Only one activity channel has been given, so keep using that one.
                                BOT_CONFIG.server_activity_channels.keys[0]
                              end
        #
        #Debug.pp(keys_left: possible_output_channels, picked: selected_channel_id) if BOT_CONFIG.debug_spammy


        # Default text to use if the rest of the stuff fails.
        default_str = +'Insert random text here, sent to channel-id: ' << selected_channel_id.to_s << ".\n" \
                      'Choose text from **' << BOT_CONFIG.server_activity_channels[selected_channel_id].to_s << '**.' \
                      ' Chosen after ' << server_inactivity_time.to_s << ' seconds of inactivity' \
                      ' and because the current time (' << current_time_utc.to_s << ') is' \
                      ' between **S**: ' << interval_start << ' **E**: ' << interval_end << '.'
        #
        activity_task_obj = choose_random_text_to_display(server_id, selected_channel_id, default_str)
        BOT_CACHE.update_last_activity_question(server_id, activity_task_obj)

        #return nil
        nil
      end



      def self.choose_random_text_to_display(server_id, display_in_channel_id, default_message_str = ':thinking:')
        #BOT_OBJ.send_message(display_in_channel_id, default_message_str)
        activity_data_hash = {
          server_id:     server_id,
          channel_id:    display_in_channel_id,
          hash_key_word: nil,
          array_index:   nil,
          question:      nil,
          answer:        nil
        }

        key_mapping = BOT_CONFIG.server_activity_channels[display_in_channel_id]
        bot_text_key_entry = BOT_CONFIG.find_bot_message_entry('MESSAGES', key_mapping)
        #Debug.pp bot_text_key_entry

        if !bot_text_key_entry
          message_to_show = default_message_str
        else
          bot_texts_response_array = BOT_CONFIG.bot_inactivity_messages[bot_text_key_entry]
          bot_texts_array_random_index = Random.new.rand(0..(bot_texts_response_array.length - 1))

          activity_data_hash[:hash_key_word] = bot_text_key_entry
          activity_data_hash[:array_index]   = bot_texts_array_random_index

          response_entry = bot_texts_response_array[bot_texts_array_random_index]
          #puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(response_entry, 0, false) if BOT_CONFIG.debug_spammy

          message_to_show = if response_entry.is_a?(Hash)
                              if response_entry.key?(:q)
                                response_entry[:q]
                              elsif response_entry.key?(:Q)
                                response_entry[:Q]
                              else
                                +'' << default_message_str << "\n" << 'Index entry ' << bot_texts_array_random_index.to_s << ' unfortunately has errors. Contents unavailable.'
                              end
                              #
                            elsif response_entry.is_a?(Array)
                              response_entry.join "\n"
                            else
                              response_entry
                            end
          #
          answer_to_store = if response_entry.is_a?(Hash)
                              if response_entry.key?(:a)
                                response_entry[:a]
                              elsif response_entry.key?(:A)
                                response_entry[:A]
                              else
                                +'' << 'Index entry ' << bot_texts_array_random_index.to_s << ' unfortunately has errors. Contents unavailable.'
                              end
                              #
                            else # rubocop:disable Style/EmptyElse
                              nil
                            end
          #
          message_to_show = message_to_show.join("\n") if message_to_show.is_a?(Array)
          answer_to_store = answer_to_store.join("\n") if answer_to_store.is_a?(Array)

          activity_data_hash[:question] = message_to_show
          activity_data_hash[:answer]   = answer_to_store
        end
        #Debug.pp message_to_show if BOT_CONFIG.debug_spammy

        BOT_OBJ.send_message(display_in_channel_id, message_to_show)

        activity_task_obj = ActivityTask.new(activity_data_hash)
        puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(activity_task_obj, 0, false) if BOT_CONFIG.debug_spammy

        #return activity_task_obj
        activity_task_obj
      end

    end
    #module RiddleText
  end
  #module Commands
end
#module BifrostBot
