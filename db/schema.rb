#!/usr/bin/env ruby -wW2

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

# Filename of the sqlite3 database.
# Should be located in the bot's data-folder,
# unless this is changed below.
DATABASE_FILE_NAME = 'server_data.sqlite'



# The name of this script.
SCRIPT_NAME = File.basename(__FILE__).freeze
#SCRIPT_NAME = $0

# The root folder of the bot script.
# __FILE__  <-  db/schema.rb
#           ->  d:/ruby/discordbot/bifrost_bot/db/schema.rb
#           ->  d:/ruby/discordbot/bifrost_bot/db
#           ->  d:/ruby/discordbot/bifrost_bot
ROOT_DIR = File.dirname(File.dirname(File.expand_path(__FILE__))).freeze

# The full path of the sqlite3 database.
DATABASE_FILE = (ROOT_DIR + '/data/' + DATABASE_FILE_NAME).freeze



# Modify the load path.
$LOAD_PATH.unshift ROOT_DIR + '/lib/'

# Just to get a better idea of which modules/gems might be missing.
# Also excessively verbose for my own learning purposes.
begin
  begin
    # Turn off warnings for the following modules/gems
    # since we have no control over the code in them.
    $VERBOSE = false

    # Gems.
    require 'sqlite3' || raise('sqlite3')

    # Turn warnings back on for the following modules/gems.
    $VERBOSE = true

    require 'debug' || raise('debug')
  rescue LoadError
    #rescue LoadError => error
    # What to do if it fails.
    # Have to explicitly define which error we want to rescue from.
    # The file is most probably missing.
    raise
  rescue StandardError
    #rescue Exception => error
    # Some other error.
    raise
  ensure
    # This will always be done.
    #puts $LOAD_PATH
    puts ARGV
    print ''
  end
end



# Reference to the database wrapper object.
# Will be defined in the main function below.
#DATABASE = nil

################################################################################
def create_sqlite_database
  # Create the necessary tables.
  puts Debug.msg '>Creating tables ...'

  print '>Creating table ' + Debug.msg('"system"') + ' ... '
  sql = 'CREATE TABLE "system" (
    "created_at"        integer     NOT NULL
  )'
  DATABASE.execute_wrapper(__LINE__, sql)
  # "id"                integer     PRIMARY KEY ASC,
  # WITHOUT ROWID
  #"start_time" varchar(32) NOT NULL

  print '>Creating table ' + Debug.msg('"messages"') + ' ... '
  sql = 'CREATE TABLE "audits" (
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
  )'
  DATABASE.execute_wrapper(__LINE__, sql)
  #"reason"            varchar(512),
  # "updated_at"        integer,
  # "deleted_at"        integer
  # "id"                integer(8)  PRIMARY KEY ASC,
  # WITHOUT ROWID

  print '>Creating table ' + Debug.msg('"messages"') + ' ... '
  sql = 'CREATE TABLE "messages" (
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
  )'
  DATABASE.execute_wrapper(__LINE__, sql)
  # "is_edited"         boolean     DEFAULT 0,
  # "is_deleted"        boolean     DEFAULT 0,
  # "id"                integer(8)  PRIMARY KEY ASC,
  # WITHOUT ROWID

  print '>Creating table ' + Debug.msg('"user_changes"') + ' ... '
  sql = 'CREATE TABLE "user_changes" (
    "server_id"         integer     NOT NULL,
    "user_id"           integer     NOT NULL,
    "username"          varchar(64),
    "nickname"          varchar(64),
    "avatar_id"         varchar(35),
    "avatar_url"        varchar(256),
    "note"              text,
    "created_at"        integer     NOT NULL
  )'
  DATABASE.execute_wrapper(__LINE__, sql)
  # "updated_at"        integer,
  # "deleted_at"        integer
  # "id"                integer(8)  PRIMARY KEY ASC,
  # WITHOUT ROWID

  print '>Creating table ' + Debug.msg('"server_users"') + ' ... '
  sql = 'CREATE TABLE "server_users" (
    "server_id"         integer     NOT NULL,
    "user_id"           integer     NOT NULL,
    "has_joined"        boolean     NOT NULL    DEFAULT 1,
    "has_left"          boolean     NOT NULL    DEFAULT 0,
    "created_at"        integer     NOT NULL,
    "updated_at"        integer     NOT NULL
  )'
  DATABASE.execute_wrapper(__LINE__, sql)
  # "deleted_at"        integer
  # "id"                integer(8)  PRIMARY KEY ASC,
  # WITHOUT ROWID

  print '>Creating table ' + Debug.msg('"exercises"') + ' ... '
  sql = 'CREATE TABLE "exercises" (
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
  )'
  DATABASE.execute_wrapper(__LINE__, sql)
  # "id"                integer     PRIMARY KEY ASC,
  # WITHOUT ROWID

  #2017-11-18 14:20:02.882 +0000
  #current_utc_time = Time.now.utc.strftime '%Y-%m-%d %H:%M:%S.%L %z'
  #2017-11-18T14:20:02Z
  current_utc_time = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%SZ'

  print Debug.msg '>Updating database with time of creation ... '
  sql = 'INSERT INTO "system" (
    "created_at"
  ) VALUES (
    ?
  )'
  DATABASE.execute_wrapper(__LINE__, sql, [current_utc_time])

  print '>Doing database query ... '
  sql = 'select created_at, date(created_at), time(created_at) from system'
  values = DATABASE.execute_wrapper(__LINE__, sql)
  Debug.pp values
  # bin\sqlite3.exe data\server_data.sqlite
  # .tables
  #select created_at, date(created_at), time(created_at) from system

  puts Debug.msg '>Done.'
end



################################################################################
class Database
  public

  # This gets called after the object is destroyed.
  FINALIZER = lambda do |object_id|
    puts 'In the finalizer lambda.'
    puts 'self.object_id = ' + object_id.inspect
    # This will give a warning line:
    # warning: instance variable @db_obj not initialized
    puts '@db_obj = ' + (@db_obj.nil? ? 'nil' : @db_obj.inspect)
  end

  def initialize
    # Delete the database.
    puts Debug.msg '>Deleting ' + DATABASE_FILE
    File.unlink DATABASE_FILE if File.exist?(DATABASE_FILE)

    # Create a new database and open a connection.
    @db_obj = SQLite3::Database.new(DATABASE_FILE)
    @db_obj.busy_timeout = 1_000

    puts Debug.msg 'Created database connection.'

    # The FINALIZER gets called after the object is destroyed.
    ObjectSpace.define_finalizer(self, FINALIZER)
  end

  # This is not a magic method in Ruby.
  # It does not get called automatically.
  def finalize
    @db_obj.close
    puts Debug.msg 'Closed database connection.'
  end

  def execute_wrapper(line_number, sql_str, *sql_args)
    result_hash = []

    begin
      prepared_sql = @db_obj.prepare(sql_str)
    rescue SQLite3::SQLException => error
      @db_obj.interrupt
      puts Debug.msg('Failed', 'red')
      puts Debug.msg('SQL before line ' + line_number.to_s, 'red') + ': ' + error.message
    else
      puts Debug.msg('OK') + ' '
      #Debug.pp sql_args

      sql_result = prepared_sql.execute(sql_args)
      sql_result.each_hash { |row_data| result_hash.push row_data }
      sql_result.close
    end

    result_hash
  end
end



################################################################################
def check_if_database_exists_and_should_create
  Debug.divider

  # Just to make sure the script isn't started by accident.  (I never did that... Never...)
  if File.exist?(DATABASE_FILE)
    puts Debug.msg('Database file: ' + DATABASE_FILE)
    puts Debug.msg('This will ', 'yellow') + Debug.msg('DELETE', 'red') + Debug.msg(' the existing database!', 'yellow')
    print Debug.msg('Continue? [Yes/No] ', 'yellow')
    response = gets

    response.strip!
    puts 'You typed:'
    Debug.pp(response)

    if response.match?(/^yes$/i)
      puts 'Continuing ...'
      return true
    else
      puts 'Stopping ...'
      return false
    end
  end

  #return true
  true
end



# Call the method right above before we do stuff.
if check_if_database_exists_and_should_create
  DATABASE = Database.new
else
  exit
end
create_sqlite_database
DATABASE.finalize
