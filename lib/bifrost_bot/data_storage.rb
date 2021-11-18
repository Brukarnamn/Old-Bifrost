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

=begin
  CREATE TABLE "system" (
    "created_at"        integer     NOT NULL
  )

  CREATE TABLE "audits" (
    "audit_id"          integer     NOT NULL,
    "action_type"       integer     NOT NULL,
    "server_id"         integer     NOT NULL,
    "channel_id"        integer,
    "message_id"        integer,
    "repeat_count"      integer,
    "changes"           varchar(64),
    "reason"            text,
    "target_type"       varchar(64),
    "target_id"         integer     NOT NULL,
    "user_id"           integer     NOT NULL,
    "created_at"        integer     NOT NULL,
    "edited_at"         integer
  )

  CREATE TABLE "messages" (
    "message_id"        integer     NOT NULL,
    "server_id"         integer     NOT NULL,
    "channel_id"        integer     NOT NULL,
    "user_id"           integer     NOT NULL,
    "is_private_msg"    boolean     DEFAULT 0,
    "message"           text,
    "files"             text,
    "created_at"        integer     NOT NULL,
    "edited_at"         integer,
    "deleted_at"        integer
  )

  CREATE TABLE "user_changes" (
    "server_id"         integer     NOT NULL,
    "user_id"           integer     NOT NULL,
    "username"          varchar(64),
    "nickname"          varchar(64),
    "avatar_id"         varchar(35),
    "avatar_url"        varchar(256),
    "note"              text,
    "created_at"        integer     NOT NULL
  )

  CREATE TABLE "server_users" (
    "server_id"         integer     NOT NULL,
    "user_id"           integer     NOT NULL,
    "has_joined"        boolean     NOT NULL    DEFAULT 1,
    "has_left"          boolean     NOT NULL    DEFAULT 0,
    "created_at"        integer     NOT NULL,
    "updated_at"        integer     NOT NULL
  )

  CREATE TABLE "exercises" (
    "user_id"           integer     NOT NULL,
    "questions_asked"   integer     DEFAULT 0,
    "answered"          integer     DEFAULT 0,
    "correct"           integer     DEFAULT 0,
    "wrong"             integer     DEFAULT 0,
    "correct_streak"    integer     DEFAULT 0,
    "highest_streak"    integer     DEFAULT 0,
    "resets"            integer     DEFAULT 0,
    "created_at"        integer     NOT NULL,
    "updated_at"        integer
  )
=end

# Bifrost / Askeladden v2
module BifrostBot
  # Module to store stuff in the database.
  module DataStorage
    require 'debug'
    require 'sqlite3'
    require 'time'
    require 'yaml'



    class << self
      public

      attr_reader :db_obj,
                  :time_format_str

      protected

      attr_writer :db_obj,
                  :time_format_str
    end



    public

    # Open the database for access and sets the internal db_obj
    # with some default options.
    #
    # @param filename [String] The filename of the Sqlite database to access.
    # @return [nil]
    #
    def self.db_open(filename)
      if !File.exist?(filename)
        Debug.error('Database file does not exist: ' + filename)
        raise ConfigurationError
      end
      Debug.pp filename

      # Create a new database and open a connection.
      @db_obj = SQLite3::Database.new(filename)

      # Try to wait for 10 seconds if there is something preventing write access.
      @db_obj.busy_timeout = 10_000

      @time_format_str = BOT_CONFIG.timestamp_format_ms

      #return @db_obj
      nil
    end



    # Close the database connection.
    #
    # @return nil
    #
    def self.db_close
      # Close the database connection.
      @db_obj.close

      #return @db_obj
      nil
    end



    #protected

    # Convert a value that would be considered a boolean value into
    # a 1 or 0, depending on its original value.
    #
    # @param boolean_value [true, false, String, Integer, Float] The value to convert.
    # @return [Integer] 1 if true, 0 if false.
    #
    def self.bool_to_int(boolean_value)
      case boolean_value
      when FalseClass, NilClass, 'false', '', 0, 0.0
        0
      else
        1
      end
    end



    public

    # Find out when the database was created.
    #
    # @return [Time] The UTC time when the database was created.
    #
    def self.find_database_creation_time
      #CREATE TABLE "system" (
      #  "created_at"        integer     NOT NULL
      #)

      sql = 'SELECT "created_at" ' \
            'FROM "system" ' \
            'LIMIT 1'
      #
      sql_exec = @db_obj.prepare(sql)

      results = sql_exec.execute
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      result_arrayhash = []
      results.each_hash do |row_data|
        results_data = {
          created_at: nil
        }
        created_at = row_data['created_at']

        results_data[:created_at] = if created_at.nil_or_empty?
                                      nil
                                    elsif !created_at.is_a?(Time)
                                      Time.parse(created_at).utc #.strftime(@time_format_str)
                                    end
        #
        result_arrayhash.push results_data
      end
      #
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      #return result_arrayhash
      result_arrayhash
    end



    # Search for a specific audit entry in the database.
    # Return its contents in Hash-form if found, or nil otherwise.
    #
    # @param audit_id [Integer] The audit-id to search for.
    # @param repeat_count [Integer, nil] The audit-id count for the audit entry that is being searched for.
    # @param changes [String] The changes done in the audit that is being searched for.
    # @param reason [String] The reason text in the audit that is being searched for.
    # @return [true, false] True if the specific audit exists already. False otherwise.
    #
    def self.find_audit_log_entry(audit_id, repeat_count: nil, changes: nil, reason: nil)
      #CREATE TABLE "audits" (
      #  "audit_id"          integer     NOT NULL,
      #  "action_type"       integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer,
      #  "message_id"        integer,
      #  "repeat_count"      integer,
      #  "changes"           varchar(64),
      #  "reason"            text,
      #  "target_type"       varchar(64),
      #  "target_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer
      #)

      # Search to see if this log entry already exists in the database table.
      # The same entry audit_id might exist already, but if so it should have a different repeat_count and edited_at timestamp.
      #      'WHERE "audit_id" = ? AND ("repeat_count" IS NULL OR "repeat_count" = ?) '
      #sql = 'SELECT "rowid", "audit_id", "action_type", "server_id", "channel_id", "message_id", ' \
      #      '  "repeat_count", "changes", "reason", "target_type", "target_id", "user_id", "created_at", "edited_at" ' \
      #      'FROM "audits" ' \
      #      'WHERE "audit_id" = ? '
      #
      sql = 'SELECT COUNT("rowid") AS count ' \
            'FROM "audits" ' \
            'WHERE "audit_id" = ? '
      #

      # 'WHERE "audit_id" = ? AND ("repeat_count" IS NULL OR "repeat_count" = ?) '
      if repeat_count.nil? && changes.nil? && reason.nil?
        #sql += 'AND "repeat_count" IS NULL '

        sql_exec = @db_obj.prepare(sql)
        results = sql_exec.execute([audit_id])
      elsif !repeat_count.nil?
        sql += 'AND "repeat_count" = ? '

        sql_exec = @db_obj.prepare(sql)
        results = sql_exec.execute([audit_id,
                                    repeat_count])
        #
      elsif !changes.nil?
        sql += 'AND "changes" = ? '

        sql_exec = @db_obj.prepare(sql)
        results = sql_exec.execute([audit_id,
                                    changes])
        #
      elsif !reason.nil?
        sql += 'AND "reason" = ? '

        sql_exec = @db_obj.prepare(sql)
        results = sql_exec.execute([audit_id,
                                    reason])
        #
      end

      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [ { "count": Integer } ] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      #return_data = nil
      count = 0
      results.each_hash { |row_data| count = row_data['count'] }
      # Ignored because of spam.
      #puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(count.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # If the same audit_id and repeat_count exists already, then return that info.
      #if result_arrayhash.length.positive?
      #  result_arrayhash = result_arrayhash[0]
      #
      #  return_data = {
      #    rowid:        result_arrayhash['rowid'],
      #    audit_id:     result_arrayhash['audit_id'],
      #    action_type:  result_arrayhash['action_type'],
      #    server_id:    result_arrayhash['server_id'],
      #    channel_id:   result_arrayhash['channel_id'],
      #    message_id:   result_arrayhash['message_id'],
      #    repeat_count: result_arrayhash['repeat_count'],
      #    changes:      result_arrayhash['changes'],
      #    reason:       result_arrayhash['reason'],
      #    target_type:  result_arrayhash['target_type'],
      #    target_id:    result_arrayhash['target_id'],
      #    user_id:      result_arrayhash['user_id'],
      #    created_at:   result_arrayhash['created_at'],
      #    edited_at:    result_arrayhash['edited_at']
      #  }
      #  created_at = return_data[:created_at]
      #  edited_at  = return_data[:edited_at]
      #
      #  return_data[:created_at] = if created_at.nil_or_empty?
      #                               nil
      #                             elsif !created_at.is_a?(Time)
      #                               Time.parse(created_at).utc #.strftime(@time_format_str)
      #                             end
      #  #
      #  return_data[:edited_at] = if edited_at.nil_or_empty?
      #                              nil
      #                            elsif !edited_at.is_a?(Time)
      #                              Time.parse(edited_at).utc #.strftime(@time_format_str)
      #                            end
      #  #
      #end

      # If the count is bigger than one, then the audit-id with the same information exists already.
      return_data = count.positive?

      #return return_data
      return_data
    end



    # Create a new audit entry in the database.
    # Return its contents as written into the database in Hash-form.
    #
    # @param audit_log_data_hash [Hash] The data columns to write into the database table.
    # @return [Hash] The contents that were written into the database table.
    #
    def self.save_audit_log_entry(audit_log_data_hash)
      #CREATE TABLE "audits" (
      #  "audit_id"          integer     NOT NULL,
      #  "action_type"       integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer,
      #  "message_id"        integer,
      #  "repeat_count"      integer,
      #  "changes"           varchar(64),
      #  "reason"            text,
      #  "target_type"       varchar(64),
      #  "target_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer
      #)

      # Double check that data is correct before storing it in the database.
      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      created_at = audit_log_data_hash[:created_at] || Time.now.utc
      created_at_utc = if created_at.is_a?(Time)
                         created_at.utc.strftime(@time_format_str)
                       else
                         Time.parse(created_at).utc.strftime(@time_format_str)
                       end
      #
      edited_at = audit_log_data_hash[:edited_at] || Time.now.utc
      edited_at_utc = if edited_at.is_a?(Time)
                        edited_at.utc.strftime(@time_format_str)
                      else
                        Time.parse(edited_at).utc.strftime(@time_format_str)
                      end
      #
      # But store the original Time objects in the return value.
      audit_log_data_hash[:created_at] = created_at
      audit_log_data_hash[:edited_at] = edited_at

      sql = 'INSERT INTO "audits" (' \
            '  "audit_id", "action_type", "server_id", "channel_id", "message_id", "repeat_count", "changes", "reason", "target_type", "target_id", "user_id", "created_at", "edited_at" ' \
            '  ) values (' \
            '   ?,          ?,             ?,           ?,            ?,            ?,              ?,         ?,        ?,             ?,           ?,         ?,            ? ' \
            '  ) '
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([audit_log_data_hash[:audit_id],
      #                            audit_log_data_hash[:action_type],
      #                            audit_log_data_hash[:server_id],
      #                            audit_log_data_hash[:channel_id],
      #                            audit_log_data_hash[:message_id],
      #                            audit_log_data_hash[:repeat_count],
      #                            audit_log_data_hash[:changes],
      #                            audit_log_data_hash[:reason],
      #                            audit_log_data_hash[:target_type],
      #                            audit_log_data_hash[:target_id],
      #                            audit_log_data_hash[:user_id],
      #                            created_at_utc,
      #                            edited_at_utc])
      #
      sql_exec.execute([audit_log_data_hash[:audit_id],
                        audit_log_data_hash[:action_type],
                        audit_log_data_hash[:server_id],
                        audit_log_data_hash[:channel_id],
                        audit_log_data_hash[:message_id],
                        audit_log_data_hash[:repeat_count],
                        audit_log_data_hash[:changes],
                        audit_log_data_hash[:reason],
                        audit_log_data_hash[:target_type],
                        audit_log_data_hash[:target_id],
                        audit_log_data_hash[:user_id],
                        created_at_utc,
                        edited_at_utc])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more updates were successfully done, false otherwise
      #number_of_database_changes.positive?
      #return audit_log_data_hash
      audit_log_data_hash
    end



    # Search for a specific message in the database.
    # Return its message-id if found, or nil otherwise.
    #
    # @param message_id [Integer] The message-id to search for.
    # @param edited_at [Time] The time the specific message-id was edited at, if there are one or more edits.
    # @return [Integer, nil] The message-id of the message entry found. Otherwise nil.
    #
    def self.find_user_message(message_id, edited_at)
      #CREATE TABLE "messages" (
      #  "message_id"        integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "is_private_msg"    boolean     DEFAULT 0,
      #  "message"           text,
      #  "files"             text,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer,
      #  "deleted_at"        integer
      #)

      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      edited_at_utc = if !edited_at.nil_or_empty? && edited_at.is_a?(Time)
                        edited_at.utc.strftime(@time_format_str)
                      elsif !edited_at.nil_or_empty?
                        Time.parse(edited_at).utc.strftime(@time_format_str)
                      else # rubocop:disable Style/EmptyElse - redundant else-clause
                        nil
                      end
      #

      # Search to see if this message already exists in the database table.
      # The same message id might exist already, but if so it should have a different edited_at timestamp.
      sql = 'SELECT COUNT("rowid") AS count ' \
            'FROM "messages" ' \
            'WHERE "message_id" = ? '
      #

      # 'WHERE "audit_id" = ? AND ("repeat_count" IS NULL OR "repeat_count" = ?) '
      if edited_at_utc.nil?
        sql += 'AND "edited_at" IS NULL ' \
               'LIMIT 1'
        #
        sql_exec = @db_obj.prepare(sql)
        results = sql_exec.execute([message_id])
      else
        sql += 'AND "edited_at" = ? ' \
               'LIMIT 1'
        #
        sql_exec = @db_obj.prepare(sql)
        results = sql_exec.execute([message_id,
                                    edited_at_utc])
        #
      end

      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [ { "count": Integer } ] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      return_data = nil
      count = 0
      results.each_hash { |row_data| count = row_data['count'] }
      # Ignored because of excessive spam.
      #puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(count.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # If the count is bigger than one, then the message-id exists already.
      return_data = message_id if count.positive?

      #return return_data
      return_data
    end



    # Create a new message entry in the database.
    # Return true on success.
    #
    # @param message_table_data_hash [Hash] The data columns to write into the database table.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.save_user_message(message_table_data_hash)
      #CREATE TABLE "messages" (
      #  "message_id"        integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "is_private_msg"    boolean     DEFAULT 0,
      #  "message"           text,
      #  "files"             text,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer,
      #  "deleted_at"        integer
      #)

      # Double check that data is correct before storing it in the database.
      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      created_at = message_table_data_hash[:created_at] || Time.now.utc
      created_at_utc = if created_at.is_a?(Time)
                         created_at.utc.strftime(@time_format_str)
                       else
                         Time.parse(created_at).utc.strftime(@time_format_str)
                       end
      #
      edited_at = message_table_data_hash[:edited_at] || nil
      edited_at_utc = if !edited_at.nil_or_empty? && edited_at.is_a?(Time)
                        edited_at.utc.strftime(@time_format_str)
                      elsif !edited_at.nil_or_empty?
                        Time.parse(edited_at).utc.strftime(@time_format_str)
                      else # rubocop:disable Style/EmptyElse - redundant else-clause
                        nil
                      end
      #

      sql = 'INSERT INTO "messages" (' \
            '  "message_id", "server_id", "channel_id", "user_id", "is_private_msg", "message", "files", "created_at", "edited_at" ' \
            '  ) values (' \
            '   ?,            ?,           ?,            ?,         ?,                ?,         ?,       ?,            ?' \
            '  ) '
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([message_table_data_hash[:message_id],
      #                            message_table_data_hash[:server_id],
      #                            message_table_data_hash[:channel_id],
      #                            message_table_data_hash[:user_id],
      #                            bool_to_int(message_table_data_hash[:is_private_msg]),
      #                            message_table_data_hash[:message],
      #                            message_table_data_hash[:files],
      #                            created_at_utc,
      #                            edited_at_utc])
      #
      sql_exec.execute([message_table_data_hash[:message_id],
                        message_table_data_hash[:server_id],
                        message_table_data_hash[:channel_id],
                        message_table_data_hash[:user_id],
                        bool_to_int(message_table_data_hash[:is_private_msg]),
                        message_table_data_hash[:message],
                        message_table_data_hash[:files],
                        created_at_utc,
                        edited_at_utc])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      # Ignored because of excessive spam.
      #puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more updates were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Fetch the message-ids of the last messages a user has made on a server.
    # Return an array if the message-ids matching the criteria.
    #
    # @param server_id [Integer] The server-id to search on.
    # @param user_id [Integer] The user-id to search for.
    # @param number_of_messages [Integer] The number of message-ids to return.
    # @param deleted_at [Time] Messages deleted after this time will still be included.
    # @return [Array<Integer>] Array containing message-ids.
    #
    def self.get_user_message_ids(server_id, user_id, number_of_messages, deleted_at)
      #CREATE TABLE "messages" (
      #  "message_id"        integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "is_private_msg"    boolean     DEFAULT 0,
      #  "message"           text,
      #  "files"             text,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer,
      #  "deleted_at"        integer
      #)

      deleted_at_utc = if deleted_at.is_a?(Time)
                         deleted_at.utc.strftime(@time_format_str)
                       elsif !deleted_at.nil_or_empty?
                         Time.parse(deleted_at).utc.strftime(@time_format_str)
                       end
      #

      sql = 'SELECT DISTINCT "message_id" ' \
            'FROM "messages" ' \
            'WHERE "server_id" = ? AND "user_id" = ? ' \
            '  AND ("deleted_at" IS NULL OR "deleted_at" > ?) ' \
            '  AND "is_private_msg" = ? ' \
            '  AND ("message" IS NOT NULL OR "files" IS NOT NULL) ' \
            'ORDER BY "message_id" DESC LIMIT ? '
      #
      sql_exec = @db_obj.prepare(sql)

      results = sql_exec.execute([server_id,
                                  user_id,
                                  deleted_at_utc,
                                  bool_to_int(false),
                                  number_of_messages])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      result_arrayhash = []
      results.each_hash { |row_data| result_arrayhash.push row_data['message_id'] }
      puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      #return result_arrayhash
      result_arrayhash
    end



    # Fetch the message contents of the message-ids provided.
    # For multiple messages with the same message-id only the last one
    # will be fetched (the message after the last edit).
    #
    # @param message_ids_array [Array<Integer>] Array of message-ids to fetch.
    # @return [Hash<Hash>] Hash with message-id keys containing the message-contents as a Hash.
    #
    def self.get_messages(message_ids_array)
      #CREATE TABLE "messages" (
      #  "message_id"        integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "is_private_msg"    boolean     DEFAULT 0,
      #  "message"           text,
      #  "files"             text,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer,
      #  "deleted_at"        integer
      #)
      return_values_hash = {}

      sql = 'SELECT "rowid", "message_id", "channel_id", "user_id", "is_private_msg", "message", "files", "created_at", "edited_at" ' \
            'FROM "messages" ' \
            'WHERE "message_id" = ? '
      #
      sql_exec = @db_obj.prepare(sql)

      message_ids_array.each do |message_id|
        results = sql_exec.execute([message_id])
        #
        puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

        results.each_hash do |row_data| #{ |row_data| result_arrayhash.push row_data }
          results_data = {
            rowid:          row_data['rowid'],
            message_id:     row_data['message_id'],
            channel_id:     row_data['channel_id'],
            user_id:        row_data['user_id'],
            is_private_msg: row_data['is_private_msg'],
            message:        row_data['message'],
            files:          row_data['files'],
            created_at:     row_data['created_at'],
            edited_at:      row_data['edited_at']
          }
          is_private_msg = results_data[:is_private_msg]
          created_at     = results_data[:created_at]
          edited_at      = results_data[:edited_at]

          # Convert 0 to false, and 1 to true.
          results_data[:is_private_msg] = if is_private_msg.nil?
                                            false
                                          elsif is_private_msg.positive?
                                            true
                                          else
                                            false
                                          end
          #

          results_data[:created_at] = if created_at.nil_or_empty?
                                        nil
                                      elsif !created_at.is_a?(Time)
                                        Time.parse(created_at).utc #.strftime(@time_format_str)
                                      end
          #
          results_data[:edited_at] = if edited_at.nil_or_empty?
                                       nil
                                     elsif !edited_at.is_a?(Time)
                                       Time.parse(edited_at).utc #.strftime(@time_format_str)
                                     end
          #
          return_values_hash[message_id] = results_data
        end
        #loop db-rows
      end
      #loop sql-exec

      # Ignored because of spam.
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(return_values_hash, 0, false) if BOT_CONFIG.debug_spammy

      #return return_values_hash
      return_values_hash
    end



    # Mark all messages with the given message-id as deleted.
    # Return true on success.
    #
    # @param message_id [Integer] The message-id of the messages to mark as deleted.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.mark_user_messages_as_deleted(message_id)
      #CREATE TABLE "messages" (
      #  "message_id"        integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "is_private_msg"    boolean     DEFAULT 0,
      #  "message"           text,
      #  "files"             text,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer,
      #  "deleted_at"        integer
      #)

      deleted_at_utc = Time.now.utc.strftime(@time_format_str)

      sql = 'UPDATE "messages" ' \
            'SET "deleted_at" = ? ' \
            'WHERE "message_id" = ? '
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([deleted_at_utc,
      #                            message_id])
      #
      sql_exec.execute([deleted_at_utc,
                        message_id])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more updates were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Search for a specific message-id in the database.
    # Return all its entries if found as an Array of Hashes, or empty Array otherwise.
    #
    # @param message_id [Integer] The message-id to search for.
    # @return [Array<Hash>] Array of Hashes containting the contents of the messages that were found. Otherwise empty Array.
    #
    def self.get_deleted_messages(message_id)
      #CREATE TABLE "messages" (
      #  "message_id"        integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "is_private_msg"    boolean     DEFAULT 0,
      #  "message"           text,
      #  "files"             text,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer,
      #  "deleted_at"        integer
      #)

      sql = 'SELECT "rowid", "message_id", "channel_id", "user_id", "is_private_msg", "message", "files", "created_at", "edited_at" ' \
            'FROM "messages" ' \
            'WHERE "message_id" = ? '
      #
      sql_exec = @db_obj.prepare(sql)

      results = sql_exec.execute([message_id])
      #
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      result_arrayhash = []
      results.each_hash do |row_data| #{ |row_data| result_arrayhash.push row_data }
        results_data = {
          rowid:          row_data['rowid'],
          message_id:     row_data['message_id'],
          channel_id:     row_data['channel_id'],
          user_id:        row_data['user_id'],
          is_private_msg: row_data['is_private_msg'],
          message:        row_data['message'],
          files:          row_data['files'],
          created_at:     row_data['created_at'],
          edited_at:      row_data['edited_at']
        }
        is_private_msg = results_data[:is_private_msg]
        created_at     = results_data[:created_at]
        edited_at      = results_data[:edited_at]

        # Convert 0 to false, and 1 to true.
        results_data[:is_private_msg] = if is_private_msg.nil?
                                          false
                                        elsif is_private_msg.positive?
                                          true
                                        else
                                          false
                                        end
        #

        results_data[:created_at] = if created_at.nil_or_empty?
                                      nil
                                    elsif !created_at.is_a?(Time)
                                      Time.parse(created_at).utc #.strftime(@time_format_str)
                                    end
        #
        results_data[:edited_at] = if edited_at.nil_or_empty?
                                     nil
                                   elsif !edited_at.is_a?(Time)
                                     Time.parse(edited_at).utc #.strftime(@time_format_str)
                                   end
        #
        result_arrayhash.push results_data
      end
      # Ignored because of spam.
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      #return result_arrayhash
      result_arrayhash
    end



    # Properly delete all messages that are "too old".
    # Return true on success.
    #
    # @param message_id [Integer] The message-id of the messages to mark as deleted.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.delete_user_messages(deleted_at_time)
      #CREATE TABLE "messages" (
      #  "message_id"        integer     NOT NULL,
      #  "server_id"         integer     NOT NULL,
      #  "channel_id"        integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "is_private_msg"    boolean     DEFAULT 0,
      #  "message"           text,
      #  "files"             text,
      #  "created_at"        integer     NOT NULL,
      #  "edited_at"         integer,
      #  "deleted_at"        integer
      #)

      # Double check that data is correct before using it.
      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      deleted_at_utc = if deleted_at_time.is_a?(Time)
                         deleted_at_time.utc.strftime(@time_format_str)
                       else
                         Time.parse(deleted_at_time).utc.strftime(@time_format_str)
                       end
      #

      sql = 'DELETE' \
            'FROM "messages" ' \
            'WHERE "deleted_at" IS NOT NULL AND "deleted_at" < ? '
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([deleted_at_utc])
      #
      sql_exec.execute([deleted_at_utc])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more deletes were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Create a user event entry in the database.
    # Return true on success.
    #
    # @param user_event_data_hash [Hash] The data columns to write into the database table.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.save_user_event(user_event_data_hash)
      #CREATE TABLE "user_changes" (
      #  "server_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "username"          varchar(64),
      #  "nickname"          varchar(64),
      #  "avatar_id"         varchar(35),
      #  "avatar_url"        varchar(256),
      #  "note"              text,
      #  "created_at"        integer     NOT NULL
      #)

      # Double check that data is correct before storing it in the database.
      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      created_at = user_event_data_hash[:created_at] || Time.now.utc
      created_at_utc = if created_at.is_a?(Time)
                         created_at.utc.strftime(@time_format_str)
                       else
                         Time.parse(created_at).utc.strftime(@time_format_str)
                       end
      #
      # But store the original Time object back in the return value.
      user_event_data_hash[:created_at] = created_at

      sql = 'INSERT INTO "user_changes" (' \
            '  "server_id", "user_id", "username", "nickname", "avatar_id", "avatar_url", "note", "created_at" ' \
            '  ) values (' \
            '   ?,           ?,         ?,          ?,          ?,           ?,           ?,       ? ' \
            '  ) '
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([user_event_data_hash[:server_id],
      #                            user_event_data_hash[:user_id],
      #                            user_event_data_hash[:username],
      #                            user_event_data_hash[:nickname],
      #                            user_event_data_hash[:avatar_id],
      #                            user_event_data_hash[:avatar_url],
      #                            user_event_data_hash[:note],
      #                            created_at_utc])
      #
      sql_exec.execute([user_event_data_hash[:server_id],
                        user_event_data_hash[:user_id],
                        user_event_data_hash[:username],
                        user_event_data_hash[:nickname],
                        user_event_data_hash[:avatar_id],
                        user_event_data_hash[:avatar_url],
                        user_event_data_hash[:note],
                        created_at_utc])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more updates were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Search for all the entries for a user in the user events table.
    # Return all the user's usernames and nicknames as an Array of Hashes, or empty Array otherwise.
    #
    # @param server_id [Integer] The server-id to search for.
    # @param user_id [Integer] The user-id to search for.
    # @return [Array<Hash>] Array of Hashes containting the contents of the user's info that were found. Otherwise empty Array.
    #
    def self.get_db_user_info(server_id, user_id)
      #CREATE TABLE "user_changes" (
      #  "server_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "username"          varchar(64),
      #  "nickname"          varchar(64),
      #  "avatar_id"         varchar(35),
      #  "avatar_url"        varchar(256),
      #  "note"              text,
      #  "created_at"        integer     NOT NULL
      #)

      sql = 'SELECT "rowid", "user_id", "username", "nickname" ' \
            'FROM "user_changes" ' \
            'WHERE "server_id" = ? AND "user_id" = ? AND ("username" IS NOT NULL AND "username" <> "") '
      #
      sql_exec = @db_obj.prepare(sql)

      results = sql_exec.execute([server_id,
                                  user_id])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      result_arrayhash = []
      results.each_hash do |row_data| #{ |row_data| result_arrayhash.push row_data }
        result_arrayhash.push(rowid:    row_data['rowid'],
                              user_id:  row_data['user_id'],
                              username: row_data['username'],
                              nickname: row_data['nickname'])
        #
      end
      # Ignored because of spam.
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      #return result_arrayhash
      result_arrayhash
    end



    # Delete all user entires made for a certain user-id.
    # Return true on success.
    #
    # @param server_id [Integer] The server-id to search for.
    # @param user_id [Integer] The user-id to search for.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.delete_db_user_info(server_id, user_id)
      #CREATE TABLE "user_changes" (
      #  "server_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "username"          varchar(64),
      #  "nickname"          varchar(64),
      #  "avatar_id"         varchar(35),
      #  "avatar_url"        varchar(256),
      #  "note"              text,
      #  "created_at"        integer     NOT NULL
      #)

      sql = 'DELETE' \
            'FROM "user_changes" ' \
            'WHERE "server_id" = ? AND "user_id" = ? '
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([server_id,
      #                            user_id])
      #
      sql_exec.execute([server_id,
                        user_id])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more deletes were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Fetch all the users from the server_users table marked as still on the
    # server.
    #
    # @param server_id [Integer] The server-id to check for the user.
    # @param updated_at [Time] Update date to compare with and do changes based on.
    # @return [Array<Hash>] Array of Hashes containting the contents of the user's info that were found. Otherwise empty Array.
    #
    def self.get_all_server_user_present(server_id)
      #CREATE TABLE "server_users" (
      #  "server_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "has_joined"        boolean     NOT NULL    DEFAULT 1,
      #  "has_left"          boolean     NOT NULL    DEFAULT 0,
      #  "created_at"        integer     NOT NULL,
      #  "updated_at"        integer     NOT NULL
      #)

      sql = 'SELECT "rowid", "user_id" ' \
            'FROM "server_users" ' \
            'WHERE "server_id" = ? AND "has_joined" = ? '
      #
      sql_exec = @db_obj.prepare(sql)

      results = sql_exec.execute([server_id,
                                  bool_to_int(true)])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      #result_arrayhash = []
      result_hash = {}
      results.each_hash do |row_data| #{ |row_data| result_arrayhash.push row_data }
        user_id = row_data['user_id']
        #result_arrayhash.push(rowid:    row_data['rowid'],
        #                      user_id:  row_data['user_id'])
        #
        result_hash[user_id] = true
      end
      # Ignored because of spam.
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      #return result_arrayhash
      #result_arrayhash
      result_hash
    end



    # Attempt to change the timestamp of updated_at for every user in
    # the server_users table that are marked as still joined/present.
    # Return true on success.
    #
    # This will fail on the very first startup of the bot, since
    # the table is not yet filled.
    #
    # @param server_id [Integer] The server-id to check for the user.
    # @param updated_at [Time] Update date to compare with and do changes based on.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.mass_update_joined_server_user_updated_timestamp(server_id, updated_at)
      #CREATE TABLE "server_users" (
      #  "server_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "has_joined"        boolean     NOT NULL    DEFAULT 1,
      #  "has_left"          boolean     NOT NULL    DEFAULT 0,
      #  "created_at"        integer     NOT NULL,
      #  "updated_at"        integer     NOT NULL
      #)

      # Double check that data is correct before storing it in the database.
      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      updated_at ||= Time.now.utc
      updated_at_utc = if updated_at.is_a?(Time)
                         updated_at.utc.strftime(@time_format_str)
                       else
                         Time.parse(updated_at).utc.strftime(@time_format_str)
                       end
      #

      sql = 'UPDATE "server_users" ' \
            'SET "updated_at" = ? ' \
            'WHERE "server_id" = ? AND "has_joined" = ? '
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([updated_at_utc,
      #                            server_id,
      #                            bool_to_int(true)])
      #
      sql_exec.execute([updated_at_utc,
                        server_id,
                        bool_to_int(true)])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more updates were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Search for a user_id in the server_users table.
    # Return true if the users exists, false otherwise.
    #
    # @param server_id [Integer] Server-id to write into the database table.
    # @param user_id [Integer] User-id to write into the database table.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.server_user_exists(server_id, user_id)
      #CREATE TABLE "server_users" (
      #  "server_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "has_joined"        boolean     NOT NULL    DEFAULT 1,
      #  "has_left"          boolean     NOT NULL    DEFAULT 0,
      #  "created_at"        integer     NOT NULL,
      #  "updated_at"        integer     NOT NULL
      #)

      sql = 'SELECT COUNT("rowid") AS count ' \
            'FROM "server_users" ' \
            'WHERE "server_id" = ? AND "user_id" = ? ' \
            'LIMIT 1'
      #
      sql_exec = @db_obj.prepare(sql)

      results = sql_exec.execute([server_id,
                                  user_id])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [ { "count": Integer } ] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      #return_data = nil
      count = 0
      results.each_hash { |row_data| count = row_data['count'] }
      # Ignored because of excessive spam.
      #puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(count.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # If the count is bigger than one, then the user-id exists already.
      #return_data = count if count.positive?

      # Return true if count is bigger than one, false otherwise
      count.positive?
    end



    # Create a new user entry in the database and set the user as joined.
    # Return true on success.
    #
    # @param server_id [Integer] Server-id to write into the database table.
    # @param user_id [Integer] User-id to write into the database table.
    # @param joined_at [Time] Join date to write into the database table.
    # @param updated_at [Time] Update date to write into the database table.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.save_server_user_joined(server_id, user_id, joined_at = nil)
      #CREATE TABLE "server_users" (
      #  "server_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "has_joined"        boolean     NOT NULL    DEFAULT 1,
      #  "has_left"          boolean     NOT NULL    DEFAULT 0,
      #  "created_at"        integer     NOT NULL,
      #  "updated_at"        integer     NOT NULL
      #)

      # Double check that data is correct before storing it in the database.
      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      joined_at ||= Time.now.utc
      joined_at_utc = if joined_at.is_a?(Time)
                        joined_at.utc.strftime(@time_format_str)
                      else
                        Time.parse(joined_at).utc.strftime(@time_format_str)
                      end
      #
      #updated_at ||= Time.now.utc
      #updated_at_utc = if updated_at.is_a?(Time)
      #                   updated_at.utc.strftime(@time_format_str)
      #                 else
      #                   Time.parse(updated_at).utc.strftime(@time_format_str)
      #                 end
      #

      sql = 'INSERT INTO "server_users" (' \
            '  "server_id", "user_id", "has_joined", "has_left", "created_at", "updated_at" ' \
            '  ) values (' \
            '   ?,           ?,         ?,            ?,          ?,            ? ' \
            '  ) '
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([server_id,
      #                            user_id,
      #                            bool_to_int(true),
      #                            bool_to_int(false),
      #                            joined_at_utc,
      #                            updated_at_utc])
      #
      sql_exec.execute([server_id,
                        user_id,
                        bool_to_int(true),
                        bool_to_int(false),
                        joined_at_utc,
                        joined_at_utc])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more updates were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Attempt to update the server_users table and set the user as joined.
    # Return true on success.
    #
    # @param server_id [Integer] The server-id to check for the user.
    # @param user_id [Integer] The unique user-id.
    # @param updated_at [Time] Update date to write into the database table.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.update_server_user_joined(server_id, user_id, updated_at = nil)
      #CREATE TABLE "server_users" (
      #  "server_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "has_joined"        boolean     NOT NULL    DEFAULT 1,
      #  "has_left"          boolean     NOT NULL    DEFAULT 0,
      #  "created_at"        integer     NOT NULL,
      #  "updated_at"        integer     NOT NULL
      #)

      # Double check that data is correct before storing it in the database.
      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      updated_at ||= Time.now.utc
      updated_at_utc = if updated_at.is_a?(Time)
                         updated_at.utc.strftime(@time_format_str)
                       else
                         Time.parse(updated_at).utc.strftime(@time_format_str)
                       end
      #

      sql = 'UPDATE "server_users" ' \
            'SET "has_joined" = ?, "has_left" = ?, "updated_at" = ? ' \
            'WHERE "server_id" = ? AND "user_id" = ? '
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([bool_to_int(true),
      #                            bool_to_int(false),
      #                            updated_at_utc,
      #                            server_id,
      #                            user_id])
      #
      sql_exec.execute([bool_to_int(true),
                        bool_to_int(false),
                        updated_at_utc,
                        server_id,
                        user_id])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more updates were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Attempt to update the server_users table and set the user as left.
    # Return true on success.
    #
    # @param server_id [Integer] The server-id to check for the user.
    # @param user_id [Integer] The unique user-id.
    # @param updated_at [Time] Update date to write into the database table.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.update_server_user_left(server_id, user_id, updated_at = nil)
      #CREATE TABLE "server_users" (
      #  "server_id"         integer     NOT NULL,
      #  "user_id"           integer     NOT NULL,
      #  "has_joined"        boolean     NOT NULL    DEFAULT 1,
      #  "has_left"          boolean     NOT NULL    DEFAULT 0,
      #  "created_at"        integer     NOT NULL,
      #  "updated_at"        integer     NOT NULL
      #)

      # Double check that data is correct before storing it in the database.
      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      updated_at ||= Time.now.utc
      updated_at_utc = if updated_at.is_a?(Time)
                         updated_at.utc.strftime(@time_format_str)
                       else
                         Time.parse(updated_at).utc.strftime(@time_format_str)
                       end
      #

      sql = 'UPDATE "server_users" ' \
            'SET "has_joined" = ?, "has_left" = ?, "updated_at" = ? ' \
            'WHERE "server_id" = ? AND "user_id" = ? '
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([bool_to_int(false),
      #                            bool_to_int(true),
      #                            updated_at_utc,
      #                            server_id,
      #                            user_id])
      #
      sql_exec.execute([bool_to_int(false),
                        bool_to_int(true),
                        updated_at_utc,
                        server_id,
                        user_id])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more updates were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Search and return the exercise data about the specified user.
    #
    # @param user_id [Integer] The user-id to search for.
    # @return [Array<Hash>] Array of Hashes containting the information about the user found. Otherwise empty Array.
    #
    def self.get_exercise_user_data(user_id)
      #CREATE TABLE "exercises" (
      #  "user_id"           integer     NOT NULL,
      #  "questions_asked"   integer     DEFAULT 0,
      #  "answered"          integer     DEFAULT 0,
      #  "correct"           integer     DEFAULT 0,
      #  "wrong"             integer     DEFAULT 0,
      #  "correct_streak"    integer     DEFAULT 0,
      #  "highest_streak"    integer     DEFAULT 0,
      #  "resets"            integer     DEFAULT 0,
      #  "created_at"        integer     NOT NULL,
      #  "updated_at"        integer
      #)

      sql = 'SELECT "user_id", "questions_asked", "answered", "correct", "wrong", "correct_streak", "highest_streak", "resets", "created_at" ' \
            'FROM "exercises" ' \
            'WHERE "user_id" = ? ' \
            'LIMIT 1'
      #
      sql_exec = @db_obj.prepare(sql)

      results = sql_exec.execute([user_id])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      result_arrayhash = []
      results.each_hash do |row_data| #{ |row_data| result_arrayhash.push row_data }
        results_data = {
          user_id:         row_data['user_id'],
          questions_asked: row_data['questions_asked'],
          answered:        row_data['answered'],
          correct:         row_data['correct'],
          wrong:           row_data['wrong'],
          correct_streak:  row_data['correct_streak'],
          highest_streak:  row_data['highest_streak'],
          resets:          row_data['resets'],
          created_at:      row_data['created_at']
        }
        created_at = results_data[:created_at]

        results_data[:created_at] = if created_at.nil_or_empty?
                                      nil
                                    elsif !created_at.is_a?(Time)
                                      Time.parse(created_at).utc #.strftime(@time_format_str)
                                    end
        #

        result_arrayhash.push results_data
      end
      # Ignored because of spam.
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      #return result_arrayhash
      result_arrayhash
    end



    # Create a new user entry in the exercise table.
    # Return true on success.
    #
    # @param user_data_hash [Hash] The data columns to write into the database table.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.save_exercise_user_data(user_data_hash)
      #CREATE TABLE "exercises" (
      #  "user_id"           integer     NOT NULL,
      #  "questions_asked"   integer     DEFAULT 0,
      #  "answered"          integer     DEFAULT 0,
      #  "correct"           integer     DEFAULT 0,
      #  "wrong"             integer     DEFAULT 0,
      #  "correct_streak"    integer     DEFAULT 0,
      #  "highest_streak"    integer     DEFAULT 0,
      #  "resets"            integer     DEFAULT 0,
      #  "created_at"        integer     NOT NULL,
      #  "updated_at"        integer
      #)

      # Double check that data is correct before storing it in the database.
      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      created_at = user_data_hash[:created_at] || Time.now.utc
      created_at_utc = if created_at.is_a?(Time)
                         created_at.utc.strftime(@time_format_str)
                       else
                         Time.parse(created_at).utc.strftime(@time_format_str)
                       end
      #
      # But store the original Time object back in the return value.
      user_data_hash[:created_at] = created_at

      sql = 'INSERT INTO "exercises" (' \
            '  "user_id", "questions_asked", "answered", "correct", "wrong", "correct_streak", "highest_streak", "resets", "created_at" ' \
            '  ) values (' \
            '   ?,         ?,                 ?,          ?,         ?,       ?,                ?,                ?,        ? ' \
            '  ) '
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([user_data_hash[:user_id],
      #                            user_data_hash[:questions_asked],
      #                            user_data_hash[:answered],
      #                            user_data_hash[:correct],
      #                            user_data_hash[:wrong],
      #                            user_data_hash[:correct_streak],
      #                            user_data_hash[:highest_streak],
      #                            user_data_hash[:resets],
      #                            created_at_utc])
      #
      sql_exec.execute([user_data_hash[:user_id],
                        user_data_hash[:questions_asked],
                        user_data_hash[:answered],
                        user_data_hash[:correct],
                        user_data_hash[:wrong],
                        user_data_hash[:correct_streak],
                        user_data_hash[:highest_streak],
                        user_data_hash[:resets],
                        created_at_utc])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more updates were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Attempt to update the exercises user data.
    #
    # @param user_data_hash [Hash] The data columns to write into the database table.
    # @return [true, false] Return true on success. False otherwise.
    #
    def self.update_exercise_user_data(user_data_hash)
      #CREATE TABLE "exercises" (
      #  "user_id"           integer     NOT NULL,
      #  "questions_asked"   integer     DEFAULT 0,
      #  "answered"          integer     DEFAULT 0,
      #  "correct"           integer     DEFAULT 0,
      #  "wrong"             integer     DEFAULT 0,
      #  "correct_streak"    integer     DEFAULT 0,
      #  "highest_streak"    integer     DEFAULT 0,
      #  "resets"            integer     DEFAULT 0,
      #  "created_at"        integer     NOT NULL,
      #  "updated_at"        integer
      #)

      # Double check that data is correct before storing it in the database.
      # Convert it to string for sqlite.
      # 2017-11-18T14:20:02Z
      # current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
      updated_at = user_data_hash[:updated_at] || Time.now.utc
      updated_at_utc = if updated_at.is_a?(Time)
                         updated_at.utc.strftime(@time_format_str)
                       else
                         Time.parse(updated_at).utc.strftime(@time_format_str)
                       end
      #

      sql = 'UPDATE "exercises" ' \
            'SET "questions_asked" = ?, "answered" = ?, "correct" = ?, "wrong" = ?, ' \
            ' "correct_streak" = ?, "highest_streak" = ?, "resets" = ?, ' \
            ' "updated_at" = ? ' \
            'WHERE "user_id" = ? ' \
      #
      sql_exec = @db_obj.prepare(sql)

      #results = sql_exec.execute([user_data_hash[:questions_asked],
      #                            user_data_hash[:answered],
      #                            user_data_hash[:correct],
      #                            user_data_hash[:wrong],
      #                            user_data_hash[:correct_streak],
      #                            user_data_hash[:highest_streak],
      #                            user_data_hash[:resets],
      #                            updated_at_utc,
      #                            user_data_hash[:user_id]])
      #
      sql_exec.execute([user_data_hash[:questions_asked],
                        user_data_hash[:answered],
                        user_data_hash[:correct],
                        user_data_hash[:wrong],
                        user_data_hash[:correct_streak],
                        user_data_hash[:highest_streak],
                        user_data_hash[:resets],
                        updated_at_utc,
                        user_data_hash[:user_id]])
      #
      puts Debug.msg(sql, 'blue') if BOT_CONFIG.debug

      # This just prints out [] so ignore.
      #result_arrayhash = []
      #results.each_hash { |row_data| result_arrayhash.push row_data }
      #puts Debug.msg("#{__FILE__},#{__LINE__}:", 'black'), Debug.pp(result_arrayhash, 0, false) if BOT_CONFIG.debug_spammy

      # The number of update changes that were done.
      number_of_database_changes = @db_obj.changes
      puts Debug.msg("#{__FILE__},#{__LINE__}: ", 'black') + Debug.msg(number_of_database_changes.to_s, 'blue') if BOT_CONFIG.debug_spammy

      # Return true if 1 or more updates were successfully done, false otherwise
      number_of_database_changes.positive?
    end



    # Read the contents of a file and parse it as YAML.
    # http://yaml.org/spec/1.2/spec.html
    #
    # @param filename [String] the (absolute) path of the file to read and parse.
    # @return [Array<Hash>] Array with the contents of the YAML-file as Hash-entries.
    #
    def self.read_yaml(filename)
      yaml_documents = []

      begin
        if File.exist?(filename)
          # If the file exists, then
          # read every YAML-document in the file,
          # and add it to the return array.
          File.open(filename) do |yaml_file|
            YAML.load_stream(yaml_file) do |single_yaml_doc|
              yaml_documents.push single_yaml_doc
            end
          end

          # >1
          if yaml_documents.length > 1
            # Continue as normal.

          # >0 but also <=1 since it didn't get caught by the previous if-test
          elsif yaml_documents.length.positive?
            yaml_documents = yaml_documents.pop

          # <= 0
          else
            yaml_documents = nil
          end
        else
          Debug.error(+'No such file or directory: ' << filename)
          Debug.add_message(+'ERROR: No such file or directory: ' << filename)
          yaml_documents = nil
        end
      rescue Psych::SyntaxError => err
        Debug.error(+'YAML syntax error: ' << err.message)
        Debug.add_message(+'ERROR: YAML syntax error: ' << err.message)
        yaml_documents = nil
      #rescue StandardError => err
      #  puts err.inspect
      #  puts err.message
      #  yaml_documents = nil
      end

      #return yaml_documents
      yaml_documents
    end
    #read_yaml



    # Read the contents of a file and return it.
    #
    # @param filename [String] the (absolute) path of the file to read.
    # @return [String] The contents of the file.
    #
    def self.read_file(filename)
      begin
        if File.exist?(filename)
          # If the file exists, then attempt to read it.
          file_contents = File.read(filename)
        else
          Debug.error(+'No such file or directory: ' << filename)
          Debug.add_message(+'ERROR: No such file or directory: ' << filename)
          file_contents = nil
        end
      #rescue
      #  Debug.error ''
      #  file_contents = nil
      rescue StandardError => err
        puts err.inspect
        puts err.message
        file_contents = nil
      end

      #return file_contents
      file_contents
    end
    #read_file

  end
  #module DataStorage
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


