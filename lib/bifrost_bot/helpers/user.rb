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
  # Helper class set all the initial and default stuff for a user in a Discord event.
  # Because laziness.
  class DiscordEventUserHelper
    require 'debug'



    public

    attr_reader :id,
                :username,
                :discriminator,
                :distinct,
                :mention,
                :avatar_id,
                :avatar_url,
                :game,
                :bot_account
    #
    attr_accessor :nick,
                  :joined_at,
                  :roles
    #



    def bot_account?
      @bot_account
    end



    # https://discordapp.com/developers/docs/resources/user
    #
    # Discord enforces the following restrictions for usernames and nicknames:
    #   Names can contain most valid unicode characters. We limit some zero-width and non-rendering characters.
    #   Names must be between 2 and 32 characters long.
    #   Names are sanitized and trimmed of leading, trailing, and excessive internal whitespace.
    #
    # The following restrictions are additionally enforced for usernames:
    #   Names cannot contain the following substrings: '@', '#', ':', '```'.
    #   Names cannot be: 'discordtag', 'everyone', 'here'.
    #
    def initialize(user_data_hash)
      @id            = user_data_hash[:id]            || 0     # 123456789012345678 - The ID which uniquely identifies this object across Discord.
      @username      = user_data_hash[:username]      || ''    # <Someone>
      @discriminator = user_data_hash[:discriminator] || 0     # 1234
      @distinct      = user_data_hash[:distinct]      || ''    # <Someone>#1234
      @mention       = user_data_hash[:mention]       || ''    # @<Someone>#1234

      if @username.empty?
        @username = if !@distinct.empty?
                      @distinct.split('#', 2)[0]
                    elsif !@mention.empty?
                      @mention.split('#', 2)[0].split('@', 2)[1] || '<Unknown>' # Out of bounds array-index returns nil, if split failed.
                    else
                      '<Unknown>'
                    end
        #
      end
      @distinct = (+''  << @username << '#' << @discriminator) if @distinct.empty?
      @mention  = (+'@' << @username << '#' << @discriminator) if @mention.empty?

      @avatar_id     = user_data_hash[:avatar_id]     || ''    # 123456789abcdef123456789abcdef12
      @avatar_url    = user_data_hash[:avatar_url]    || ''    # https://cdn.discordapp.com/avatars/123456789012345678/123456789abcdef123456789abcdef12.webp
      @game          = user_data_hash[:game]          || ''    # The unstable bridge.
      @bot_account   = user_data_hash[:bot_account]   || false # true, false

      @nick          = user_data_hash[:nick]          || ''    # <I'm someone else>
      unsorted_roles = user_data_hash[:roles]         || {}
      @joined_at     = user_data_hash[:joined_at]     || nil   # <Time> # Time.new(2000, 1, 1, 0, 0, 0, '+00:00').utc

      # Sort the roles, so that it stays consistent and can be compared.
      @roles = {}
      unsorted_roles.keys.sort.each { |role_key| @roles[role_key] = unsorted_roles[role_key] }

      #return nil
      #nil
    end
    #initialize



    def to_s
      protected_write_values = %w[
        id
        username
        discriminator
        distinct
        mention
        avatar_id
        avatar_url
        game
        bot_account

        nick
        roles
        joined_at
      ]
      protected_write_values_hash = {}

      protected_write_values.each do |method|
        value = instance_variable_get('@' + method.to_s)
        protected_write_values_hash[method] = value
      end

      #{ protected_write: protected_write_values_hash }
      +'#<BifrostBot::DiscordEventUserHelper: ' << Debug.pp(protected_write_values_hash, 2, false)
    end
    #to_s

  end
  #class DiscordEventUserHelper
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
  http://www.rubydoc.info/github/meew0/discordrb/Discordrb/Member

  Instance Attribute Summary

    Attributes included from MemberAttributes
      #joined_at, #nick, #roles, #server

    Attributes inherited from User
      #game, #status, #stream_type, #stream_url

    Attributes included from UserAttributes
      #avatar_id, #bot_account, #discriminator, #username

    Attributes included from IDObject
      #id

  Instance Method Summary

    #add_role(role, reason = nil) ⇒ Object
      Adds one or more roles to this member.

    #colour ⇒ ColourRGB? (also: #color)
      The colour this member has.

    #colour_role ⇒ Role? (also: #color_role)
      The role this member is basing their colour on.

    #deaf ⇒ true, false (also: #deafened?)
      Whether this member is deafened server-wide.

    #display_name ⇒ String
      The name the user displays as (nickname if they have one, username otherwise).

    #highest_role ⇒ Role
      The highest role this member has.

    #hoist_role ⇒ Role?
      The role this member is being hoisted with.

    #inspect ⇒ Object
      Overwriting inspect for debug purposes.

    #modify_roles(add, remove, reason = nil) ⇒ Object
      Adds and removes roles from a member.

    #mute ⇒ true, false (also: #muted?)
      Whether this member is muted server-wide.

    #nick=(nick) ⇒ Object (also: #nickname=)

    #owner? ⇒ true, false
      Whether this member is the server owner.

    #remove_role(role, reason = nil) ⇒ Object
      Removes one or more roles from this member.

    #role?(role) ⇒ true, false
      Whether this member has the specified role.

    #roles=(role) ⇒ Object

    #self_deaf ⇒ true, false (also: #self_deafened?)
      Whether this member has deafened themselves.

    #self_mute ⇒ true, false (also: #self_muted?)
      Whether this member has muted themselves.

    #server_deafen ⇒ Object
      Server deafens this member.

    #server_mute ⇒ Object
      Server mutes this member.

    #server_undeafen ⇒ Object
      Server undeafens this member.

    #server_unmute ⇒ Object
      Server unmutes this member.

    #set_nick(nick, reason = nil) ⇒ Object (also: #set_nickname)
      Sets or resets this member's nickname.

    #set_roles(role, reason = nil) ⇒ Object
      Bulk sets a member's roles.

    #voice_channel ⇒ Channel
      The voice channel this member is in.

    Methods included from PermissionCalculator
      #defined_permission?, #permission?

    Methods inherited from User
      #await, #current_bot?, #on, #pm, #send_file, #webhook?

    Methods included from UserAttributes
      #avatar_url, #distinct, #mention

    Methods included from IDObject
      #==, #creation_time, synthesise
=end
