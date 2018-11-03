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
  # Helper class set all the initial and default stuff for a channel in a Discord event.
  # Because laziness.
  class ExerciseData
    require 'debug'



    public

    attr_reader :content,
                :title,
                :description,
                :footer,
                :fields,
                :category_key,
                :subcategory_key,
                :index,
                :number,
                :text_header,
                :text_start,
                :sentence,
                :meaning,
                :correct,
                :wrong,
                :text_id
    #



    def initialize(exercise_data_hash)
      # Fields for embeds.
      @content         = nil # Plain text before the embed.
      @title           = exercise_data_hash[:title] # Title header of the embed. 'title_text' in the yaml-file.
      @description     = nil # Main text to show in the embed.
      @footer = {            # Embed footer.
        text: nil
      }
      @fields          = nil # Embed fields.

      # Other fields, duplicate fields.
      @category_key    = exercise_data_hash[:category_key]    # The key in the main BOT_CONFIG.bot_exercises hash.
      @subcategory_key = exercise_data_hash[:subcategory_key] # The subkey in the selected hash.
      @index           = exercise_data_hash[:index]           # The exercise index in the array selected from the subcategory.
      @number          = exercise_data_hash[:number]          # The internal number for the selected array index and exercise.
      @text_header     = exercise_data_hash[:text_header]     # The small text explaining the main point of the exercise. 'task_text' in the yaml-file.
      @text_start      = exercise_data_hash[:text_start]      # Additional text explaining what to do.
      @sentence        = exercise_data_hash[:sentence]        # The sentence you need to do something with.
      @meaning         = exercise_data_hash[:meaning]         # The English meaning of the sentence.
      @correct         = exercise_data_hash[:correct]         # The correct answers.
      @wrong           = exercise_data_hash[:wrong]           # Hints for any wrong answers.
      @text_id         = nil # Identification to find the task again in the yaml-file.

      # Checking that the required fields are filled in.
      Debug.error 'Missing @category_key.'    if @category_key.nil_or_empty?
      Debug.error 'Missing @subcategory_key.' if @subcategory_key.nil_or_empty?
      Debug.error 'Missing @index.'           if @index.nil_or_empty?
      Debug.error 'Missing @number.'          if @number.nil_or_empty?
      Debug.error 'Missing @title.'           if @title.nil_or_empty?
      #Debug.warn 'Missing @text_header.'     if @text_header.nil_or_empty?
      #Debug.warn 'Missing @text_start.'      if @text_start.nil_or_empty?
      Debug.error 'Missing @sentence.'        if @sentence.nil_or_empty?
      #Debug.warn 'Missing @meaning.'         if @meaning.nil_or_empty?
      Debug.error 'Missing @correct.'         if @correct.nil_or_empty?
      #Debug.warn 'Missing @wrong.'           if @wrong.nil_or_empty?
      #Debug.error 'Missing @text_id.'        if @text_id.nil_or_empty?

      #return nil
      #nil
    end
    #initialize



    def to_s
      protected_write_values = %w[
        content
        title
        description
        footer
        fields

        category_key
        subcategory_key
        index
        number
        text_header
        text_start
        sentence
        meaning
        correct
        wrong
        text_id
      ]
      protected_write_values_hash = {}

      protected_write_values.each do |method|
        value = instance_variable_get('@' + method.to_s)
        protected_write_values_hash[method] = value
      end

      #{ protected_write: protected_write_values_hash }
      +'#<BifrostBot::ExerciseData: ' << Debug.pp(protected_write_values_hash, 2, false)
    end



    def to_embed_hash
      #@content = (+'**' << @title << '**' << "\n" << @description) if BOT_CONFIG.debug_spammy

      embed_data_hash = {
        content:     @content,     # Plain text before the embed.
        title:       @title,       # Title header of the embed. 'title_text' in the yaml-file.
        description: @description, # Main text to show in the embed.
        footer:      @footer,      # Embed footer.
        fields:      @fields       # Embed fields.
      }

      #return embed_data_hash
      embed_data_hash
    end



    def create_exercise_text
      # Checking that the required fields are filled in.
      return 'Missing @category_key.'    if @category_key.nil_or_empty?
      return 'Missing @subcategory_key.' if @subcategory_key.nil_or_empty?
      return 'Missing @index.'           if @index.nil_or_empty?
      return 'Missing @number.'          if @number.nil_or_empty?
      return 'Missing @title.'           if @title.nil_or_empty?
      #Debug.warn 'Missing @text_header.' if @text_header.nil_or_empty?
      #Debug.warn 'Missing @text_start.'  if @text_start.nil_or_empty?
      return 'Missing @sentence.'        if @sentence.nil_or_empty?
      #Debug.warn 'Missing @meaning.'    if @meaning.nil_or_empty?
      return 'Missing @correct.'         if @correct.nil_or_empty? # rubocop:disable Layout/EmptyLineAfterGuardClause
      #Debug.warn 'Missing @wrong.'      if @wrong.nil_or_empty?
      #return 'Missing @text_id.'        if @text_id.nil_or_empty?

      # Making sure that the values are strings when expected.
      @content      = nil # Text before the embed.
      @title        = @title.to_s # Title header of the embed. 'title_text' in the yaml-file.
      #@description = '' # Main text to show in the embed.
      @footer       = {} # Embed footer.
      @fields       = nil # Embed fields.
      @number       = @number.to_s
      @text_header  = @text_header.to_s
      @text_start   = @text_start.to_s
      @sentence     = @sentence.to_s
      @meaning      = @meaning.to_s
      return '@category_key is not a Symbol.'    if !@category_key.is_a?(Symbol)    # Should remain a Symbol
      return '@subcategory_key is not a Symbol.' if !@subcategory_key.is_a?(Symbol) # Should remain a Symbol
      return '@index is not an Integer.'         if !@index.is_a?(Integer)          # Should remain an Integer
      return '@correct is not an Array.'         if !@correct.is_a?(Array) # Should be an Array
      return '@wrong is not a Hash.'             if !@wrong.nil? && !@wrong.is_a?(Hash) # Should be a Hash

      # Id shown where Markdown works.
      @text_id = +'– Seksjon *' << @subcategory_key.to_s << '*, oppgave *' << @number.to_s << '* (' << @index.to_s << ').'
      # Embed footer where Markdown doesn't work.
      @footer[:text] = +'– Seksjon ' << @subcategory_key.to_s << ', oppgave ' << @number.to_s << ' (' << @index.to_s << ').'

      exercise_text = +'' << @text_header << (@text_header.empty? ? '' : "\n") <<
                      @text_start << (@text_start.empty? ? '' : "\n") <<
                      "\n" \
                      '**' << @sentence << '**' << "\n" <<
                      (@meaning.empty? ? '*Translation missing.*' : +'*' << @meaning << '*') << "\n" \
                      "\n"
      #

      @content = ['• To **view** this exercise at a later time you can send me a message with `vis` or type `!vis` in a channel.',
                  '• To get a **different category**, type `opp` again (or `!opp` in a channel) followed by the category name.',
                  '',
                  '**Answer** by responding in a private message with',
                  '  `svar <your answer>`',
                  'replace *`<your answer>`* with your actual answer.'].join("\n")
      #

      #'Answer by responding in a private message with **svar <your answer>**',
      #'Replace **<your answer>** with the Norwegian word(s) you think (or know) is correct.',
      #'To view this exercise at a later time you can send me a message with **vis** or type **!vis** in a channel.'].join("\n")
      #exercise_text += ['Answer by responding in a private message with `svar <your answer>`',
      #                  'Replace `<your answer>` with the Norwegian word(s) you think (or know) is correct.',
      #                  '',
      #                  'To view this exercise at a later time you can send me a message with `vis` or type `!vis` in a channel.'].join("\n")
      #
      exercise_text.gsub!(/_+/, '`_____`')

      @description = exercise_text

      #return nil
      nil
    end



    def check_answer(answer_string)
      is_correct_answer = false
      answer_string = answer_string.strip

      @correct.each do |correct_answer|
        next if !answer_string.casecmp?(correct_answer)

        is_correct_answer = true
        break
      end

      #return is_correct_answer
      is_correct_answer
    end



    def check_for_explanation(wrong_answer_string)
      wrong_answer_string = wrong_answer_string.strip
      return_str = nil

      return return_str if @wrong.nil?

      if !@wrong.is_a?(Hash)
        return_str = +'**INTERNAL ERROR**: Wrong format on “wrong answer” responses.' \
                    ' **Error key**: ' << @subcategory_key.to_s << ', ' << @number.to_s << ' (' << @index.to_s << ').'
        #
        return return_str
      end

      return_str = @wrong[wrong_answer_string.downcase] if @wrong.key?(wrong_answer_string.downcase)
      return_str = @wrong[wrong_answer_string.upcase]   if @wrong.key?(wrong_answer_string.upcase)

      if !return_str.nil?
        return_str = +'In this context **' << wrong_answer_string << '** would mean' \
                     ' ' << return_str.to_s << ''
        #
      end

      #return return_str
      return_str
    end

  end
  #class ExerciseData
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



