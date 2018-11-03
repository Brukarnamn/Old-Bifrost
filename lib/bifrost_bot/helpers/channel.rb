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
  class DiscordEventChannelHelper
    require 'debug'



    public

    attr_reader :id,
                :name,
                :type
    #



    def initialize(channel_data_hash)
      @id   = channel_data_hash[:id]   || 0   # The ID which uniquely identifies this object across Discord.
      @name = channel_data_hash[:name] || ''  # This channel's name.
      @type = channel_data_hash[:type] || 0   # 0: text, 1: private, 2: voice, 3: group

      #return nil
      #nil
    end
    #initialize



    def to_s
      protected_write_values = %w[
        id
        name
        type
      ]
      protected_write_values_hash = {}

      protected_write_values.each do |method|
        value = instance_variable_get('@' + method.to_s)
        protected_write_values_hash[method] = value
      end

      #{ protected_write: protected_write_values_hash }
      +'#<BifrostBot::DiscordEventChannelHelper: ' << Debug.pp(protected_write_values_hash, 2, false)
    end
    #to_s

  end
  #class DiscordEventChannelHelper
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
  http://www.rubydoc.info/github/meew0/discordrb/Discordrb/Channel

  Instance Attribute Summary

    #bitrate ⇒ Integer
      The bitrate (in bps) of the channel.

    #name ⇒ String
      This channel's name.

    #nsfw ⇒ true, false (also: #nsfw?)
      If this channel is marked as nsfw.

    #owner_id ⇒ Integer? readonly
      The id of the owner of the group channel or nil if this is not a group channel.

    #position ⇒ Integer
      The channel's position on the channel list.

    #recipients ⇒ Array<Recipient>? readonly
      The array of recipients of the private messages, or nil if this is not a Private channel.

    #server ⇒ Server? readonly
      The server this channel is on.

    #topic ⇒ String
      The channel's topic.

    #type ⇒ Integer readonly
      The type of this channel (0: text, 1: private, 2: voice, 3: group).

    #user_limit ⇒ Integer (also: #limit)
      The amount of users that can be in the channel.

    Attributes included from IDObject
      #id

  Instance Method Summary

    #add_group_users(user_ids) ⇒ Channel (also: #add_group_user)
      Adds a user to a Group channel.

    #await(key, attributes = {}, &block) ⇒ Object
      Add an Await for a message in this channel.

    #create_group(user_ids) ⇒ Channel
      Creates a Group channel.

    #default_channel? ⇒ true, false (also: #default?)
      Whether or not this channel is the default channel.

    #define_overwrite(thing, allow = 0, deny = 0, reason: nil) ⇒ Object
      Defines a permission overwrite for this channel that sets the specified thing to the specified allow and deny permission sets, or change an existing one.

    #delete(reason = nil) ⇒ Object
      Permanently deletes this channel.

    #delete_message(message) ⇒ Object
      Deletes a message on this channel.

    #delete_messages(messages, strict = false) ⇒ Object
      Deletes a collection of messages.

    #delete_overwrite(target, reason = nil) ⇒ Object
      Deletes a permission overwrite for this channel.

    #group? ⇒ true, false
      Whether or not this channel is a group channel.

    #history(amount, before_id = nil, after_id = nil, around_id = nil) ⇒ Array<Message>
      Retrieves some of this channel's message history.

    #inspect ⇒ Object
      The inspect method is overwritten to give more useful output.

    #invites ⇒ Array<Invite>
      Requests a list of Invites to the channel.

    #leave_group ⇒ Object (also: #leave)
      Leaves the group.

    #load_message(message_id) ⇒ Message (also: #message)
      Returns a single message from this channel's history by ID.

    #make_invite(max_age = 0, max_uses = 0, temporary = false, unique = false, reason = nil) ⇒ Invite (also: #invite)
      Creates a new invite to this channel.

    #member_overwrites ⇒ Overwrite
      Any member-type permission overwrites on this channel.

    #mention ⇒ String
      A string that will mention the channel as a clickable link on Discord.

    #permission_overwrites(type = nil) ⇒ Object (also: #overwrites)
      This channel's permission overwrites.

    #pins ⇒ Array<Message>
      Requests all pinned messages of a channel.

    #pm? ⇒ true, false
      Whether or not this channel is a PM channel.

    #private? ⇒ true, false
      Whether or not this channel is a PM or group channel.

    #prune(amount, strict = false) ⇒ Object
      Delete the last N messages on this channel.

    #recipient ⇒ Recipient?
      The recipient of the private messages, or nil if this is not a PM channel.

    #remove_group_users(user_ids) ⇒ Channel (also: #remove_group_user)
      Removes a user from a group channel.

    #role_overwrites ⇒ Overwrite
      Any role-type permission overwrites on this channel.

    #send_embed(message = '', embed = nil) {|embed| ... } ⇒ Message
      Convenience method to send a message with an embed.

    #send_file(file, caption: nil, tts: false) ⇒ Object
      Sends a file to this channel.

    #send_message(content, tts = false, embed = nil) ⇒ Message (also: #send)
      Sends a message to this channel.

    #send_multiple(content) ⇒ Object
      Sends multiple messages to a channel.

    #send_temporary_message(content, timeout, tts = false, embed = nil) ⇒ Object
      Sends a temporary message to this channel.

    #split_send(content) ⇒ Object
      Splits a message into chunks whose length is at most the Discord character limit, then sends them individually.

    #start_typing ⇒ Object
      Starts typing, which displays the typing indicator on the client for five seconds.

    #text? ⇒ true, false
      Whether or not this channel is a text channel.

    #update(name: @name, bitrate: @bitrate, user_limit: @user_limit, topic: @topic, position: @position, reason: nil) ⇒ Object
      Updates this channel's settings.

    #users ⇒ Array<Member>
      The list of users currently in this channel.

    #voice? ⇒ true, false
      Whether or not this channel is a voice channel.

    #webhooks ⇒ Array<Webhook>
      Requests a list of Webhooks on the channel.

    Methods included from IDObject
      #==, #creation_time, synthesise
=end


