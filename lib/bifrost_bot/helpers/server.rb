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
  # Helper class set all the initial and default stuff for a server in a Discord event.
  # Because laziness.
  class DiscordEventServerHelper
    require 'debug'



    public

    attr_reader :id,
                :name
    #



    def initialize(server_data_hash)
      @id   = server_data_hash[:id]   || 0   # The ID which uniquely identifies this object across Discord.
      @name = server_data_hash[:name] || ''  # This server's name.

      #return nil
      #nil
    end
    #initialize



    def to_s
      protected_write_values = %w[
        id
        name
      ]
      protected_write_values_hash = {}

      protected_write_values.each do |method|
        value = instance_variable_get('@' + method.to_s)
        protected_write_values_hash[method] = value
      end

      #{ protected_write: protected_write_values_hash }
      +'#<BifrostBot::DiscordEventServerHelper: ' << Debug.pp(protected_write_values_hash, 2, false)
    end
    #to_s

  end
  #class DiscordEventServerHelper
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
  http://www.rubydoc.info/github/meew0/discordrb/Discordrb/Server

  Instance Attribute Summary

    #afk_channel ⇒ Channel?
      The AFK voice channel of this server, or nil if none is set.

    #afk_timeout ⇒ Integer
      The amount of time after which a voice user gets moved into the AFK channel, in seconds.

    #channels ⇒ Array<Channel> readonly
      An array of all the channels (text and voice) on this server.

    #default_message_notifications ⇒ Symbol readonly
      The default message notifications settings of the server (:all = 'All messages', :mentions = 'Only @mentions').

    #emoji ⇒ Hash<Integer, Emoji> (also: #emojis) readonly
      A hash of all the emoji available on this server.

    #explicit_content_filter ⇒ Symbol (also: #content_filter_level) readonly
      The explicit content filter level of the server (:none = 'Don't scan any messages.', :exclude_roles = 'Scan messages for members without a role.', :all = 'Scan messages sent by all members.').

    #features ⇒ Array<Symbol> readonly
      The features of the server (eg. "INVITE_SPLASH").

    #large ⇒ true, false (also: #large?) readonly
      it means the members list may be inaccurate for a couple seconds after starting up the bot.

    #member_count ⇒ Integer readonly
      The absolute number of members on this server, offline or not.

    #owner ⇒ Member
      The server owner.

    #region_id ⇒ String readonly
      The ID of the region the server is on (e.g. amsterdam).

    #roles ⇒ Array<Role> readonly
      An array of all the roles created on this server.

    #verification_level ⇒ Symbol readonly
      The verification level of the server (:none = none, :low = 'Must have a verified email on their Discord account', :medium = 'Has to be registered with Discord for at least 5 minutes', :high = 'Has to be a member of this server for at least 10 minutes', :very_high = 'Must have a verified phone on their Discord account').

    #voice_states ⇒ Hash<Integer => VoiceState> readonly
      The hash (user ID => voice state) of voice states of members on this server.

    Attributes included from ServerAttributes
      #icon_id, #name

    Attributes included from IDObject
      #id

  Instance Method Summary

    #any_emoji? ⇒ true, false (also: #has_emoji?, #emoji?)
      Whether this server has any emoji or not.

    #available_voice_regions ⇒ Array<VoiceRegion>
      Collection of available voice regions to this guild.

    #ban(user, message_days = 0, reason: nil) ⇒ Object
      Bans a user from this server.

    #bans ⇒ Array<User>
      A list of banned users on this server.

    #begin_prune(days, reason = nil) ⇒ Integer (also: #prune)
      Prunes (kicks) an amount of members for inactivity.

    #create_channel(name, type = 0, bitrate: nil, user_limit: nil, permission_overwrites: [], nsfw: false, reason: nil) ⇒ Channel
      Creates a channel on this server with the given name.

    #create_role(name: 'new role', colour: 0, hoist: false, mentionable: false, packed_permissions: 104_324_161, reason: nil) ⇒ Role
      Creates a role on this server which can then be modified.

    #default_channel ⇒ Channel? (also: #general_channel)
      The default channel is the text channel on this server with the highest position that the client has Read Messages permission on.

    #delete ⇒ Object
      Deletes this server.

    #embed? ⇒ true, false (also: #widget_enabled, #widget?, #embed_enabled)
      Whether or not the server has widget enabled.

    #embed_channel ⇒ Channel? (also: #widget_channel)
      The channel the server embed will make a invite for.

    #everyone_role ⇒ Role
      The @everyone role on this server.

    #icon=(icon) ⇒ Object
      Sets the server's icon.

    #inspect ⇒ Object
      The inspect method is overwritten to give more useful output.

    #integrations ⇒ Array<Integration>
      An array of all the integrations connected to this server.

    #invites ⇒ Array<Invite>
      Requests a list of Invites to the server.

    #kick(user, reason = nil) ⇒ Object
      Kicks a user from this server.

    #leave ⇒ Object
      Leave the server.

    #member(id, request = true) ⇒ Object
      Gets a member on this server based on user ID.

    #members ⇒ Array<Member> (also: #users)
      An array of all the members on this server.

    #move(user, channel) ⇒ Object
      Forcibly moves a user into a different voice channel.

    #name=(name) ⇒ Object
      Sets the server's name.

    #online_members(include_idle: false, include_bots: true) ⇒ Array<Member> (also: #online_users)
      An array of online members on this server.

    #prune_count(days) ⇒ Integer
      Returns the amount of members that are candidates for pruning.

    #region ⇒ VoiceRegion?
      Voice region data for this server's region.

    #region=(region) ⇒ Object
      Moves the server to another region.

    #role(id) ⇒ Object
      Gets a role on this server based on its ID.

    #splash_id ⇒ String
      The hexadecimal ID used to identify this server's splash image for their VIP invite page.

    #splash_url ⇒ String?
      The splash image URL for the server's VIP invite page.

    #text_channels ⇒ Array<Channel>
      An array of text channels on this server.

    #unban(user, reason = nil) ⇒ Object
      Unbans a previously banned user from this server.

    #voice_channels ⇒ Array<Channel>
      An array of voice channels on this server.

    #webhooks ⇒ Array<Webhook>
      Requests a list of Webhooks on the server.

    #widget_banner_url(style) ⇒ String?
      The widget banner URL to the server that displays the amount of online members, server icon and server name in a stylish way.

    #widget_url ⇒ String?
      The widget URL to the server that displays the amount of online members in a stylish way.

    Methods included from ServerAttributes
      #icon_url

    Methods included from IDObject
      #==, #creation_time, synthesise
=end

