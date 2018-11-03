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
  class ExerciseUserData
    require 'debug'



    public

    attr_reader :user_id,
                #
                :number_of_shown,
                :number_of_answers,
                :number_of_correct,
                :number_of_wrong,
                :correct_streak_count,
                #
                :created_at,
                :updated_at,
                #
                :exercises_list,
                #
                :current_exercise,
                :category_key,
                :subcategory_key,
                :index,
                :number
    #
    attr_accessor :has_responded_in_channel



    def initialize(user_id)
      @user_id = user_id

      @number_of_shown      = 0
      @number_of_answers    = 0
      @number_of_correct    = 0
      @number_of_wrong      = 0
      @correct_streak_count = 0

      @created_at = Time.now.utc
      @updated_at = nil

      @exercises_list = []

      @current_exercise = nil
      @category_key     = nil
      @subcategory_key  = nil
      @index            = nil
      @number           = nil

      @has_responded_in_channel = false

      exercise_user_data = DataStorage.get_exercise_user_data(@user_id)
      #Debug.pp exercise_user_data

      if exercise_user_data.nil_or_empty?
        db_data_hash = {
          user_id:         @user_id,
          questions_asked: @number_of_shown,
          answered:        @number_of_answers,
          correct:         @number_of_correct,
          wrong:           @number_of_wrong,
          correct_streak:  @correct_streak_count
        }
        success = DataStorage.save_exercise_user_data(db_data_hash)
        Debug.internal('Unable to write exercise user data to database.') if !success
      else
        # Returns an array with 1 element.
        exercise_user_data = exercise_user_data.pop

        @number_of_shown      = exercise_user_data[:questions_asked]
        @number_of_answers    = exercise_user_data[:answered]
        @number_of_correct    = exercise_user_data[:correct]
        @number_of_wrong      = exercise_user_data[:wrong]
        @correct_streak_count = exercise_user_data[:correct_streak]
        @created_at           = exercise_user_data[:created_at]
      end

      #return nil
      #nil
    end
    #initialize



    def to_s
      protected_write_values = %w[
        number_of_shown
        number_of_answers
        number_of_correct
        number_of_wrong
        correct_streak_count

        exercises_list

        current_exercise
        category_key
        subcategory_key
        index
        number

        has_responded_in_channel
      ]
      protected_write_values_hash = {}

      protected_write_values.each do |method|
        value = instance_variable_get('@' + method.to_s)
        protected_write_values_hash[method] = value
      end

      #{ protected_write: protected_write_values_hash }
      +'#<BifrostBot::ExerciseUserData: ' << Debug.pp(protected_write_values_hash, 2, false)
    end



    protected

    def update_database
      db_data_hash = {
        user_id:         @user_id,
        questions_asked: @number_of_shown,
        answered:        @number_of_answers,
        correct:         @number_of_correct,
        wrong:           @number_of_wrong,
        correct_streak:  @correct_streak_count
      }
      success = DataStorage.update_exercise_user_data(db_data_hash)
      Debug.internal('Unable to write exercise user data to database.') if !success

      #return success
      success
    end



    public

    def update_new_exercise_shown(exercise_obj)
      @current_exercise = exercise_obj
      @category_key     = exercise_obj.category_key.to_s
      @subcategory_key  = exercise_obj.subcategory_key.to_s
      @index            = exercise_obj.index.to_s
      @number           = exercise_obj.number.to_s

      @number_of_shown += 1

      update_database

      #return nil
      nil
    end



    def update_correct_answer
      @number_of_answers    += 1
      @number_of_correct    += 1
      @correct_streak_count += 1

      update_database

      #return nil
      nil
    end



    def update_wrong_answer
      @number_of_answers   += 1
      @number_of_wrong     += 1
      @correct_streak_count = 0

      update_database

      #return nil
      nil
    end



    def reset_stats
      @number_of_shown      = current_exercise.nil? ? 0 : 1
      @number_of_answers    = 0
      @number_of_correct    = 0
      @number_of_wrong      = 0
      @correct_streak_count = 0

      update_database

      #return nil
      nil
    end

  end
  #class ExerciseUserData
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



