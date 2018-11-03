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
  # Helper class set all the initial and default stuff for a user role in a Discord event.
  # Because laziness.
  class DiscordEventRoleHelper
    require 'debug'



    public

    attr_reader :id,
                :name,
                :uc_name
    #



    def initialize(role_data_hash)
      @id      = role_data_hash[:id]      || 0  # The ID which uniquely identifies this object across Discord.
      @name    = role_data_hash[:name]    || '' # This user role's name.
      @uc_name = role_data_hash[:uc_name] || '' # This user role's name upcased.

      #return nil
      #nil
    end
    #initialize



    def to_s
      protected_write_values = %w[
        id
        name
        uc_name
      ]
      protected_write_values_hash = {}

      protected_write_values.each do |method|
        value = instance_variable_get('@' + method.to_s)
        protected_write_values_hash[method] = value
      end

      #{ protected_write: protected_write_values_hash }
      +'#<BifrostBot::DiscordEventRoleHelper: ' << Debug.pp(protected_write_values_hash, 2, false)
    end
    #to_s

  end
  #class DiscordEventRoleHelper
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
=begin
  http://www.rubydoc.info/github/meew0/discordrb/Discordrb/Role

  Instance Attribute Summary

    #colour ⇒ ColourRGB (also: #color)
      The role colour.

    #hoist ⇒ true, false
      Whether or not this role should be displayed separately from other users.

    #managed ⇒ true, false (also: #managed?) readonly
      Whether or not this role is managed by a integration or bot.

    #mentionable ⇒ true, false (also: #mentionable?)
      Whether this role can be mentioned using a role mention.

    #name ⇒ String
      This role's name ("new role" if it hasn't been changed).

    #permissions ⇒ Permissions readonly
      This role's permissions.

    #position ⇒ Integer readonly
      The position of this role in the hierarchy.

    Attributes included from IDObject
      #id

  Instance Method Summary

    #delete(reason = nil) ⇒ Object
      Deletes this role.

    #inspect ⇒ Object
      The inspect method is overwritten to give more useful output.

    #members ⇒ Array<Member> (also: #users)
      An array of members who have this role.

    #mention ⇒ String
      A string that will mention this role, if it is mentionable.

    #packed=(packed, update_perms = true) ⇒ Object
      Changes this role's permissions to a fixed bitfield.

    Methods included from IDObject
      #==, #creation_time, synthesise
=end

