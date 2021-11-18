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
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # Require files from directory
    #Dir["#{File.expand_path(ROOT_DIR + '/lib/bifrost_bot')}/events/*.rb"].each { |file| require file }
    Dir["#{File.dirname(__FILE__)}/events/*.rb"].each { |file| require file }



    private

    @events = [
      ReadyEvent,              ## This event is raised when the READY packet is received, i.e. servers and channels have finished initialization.
      HeartbeatEvent,          ## This event is raised every time the bot sends a heartbeat over the galaxy.
      #DisconnectEvent,        # Seems to never trigger unless BOT_OBJ.stop is called manually. ## This event is raised when the bot has disconnected from the WebSocket, due to the Bot#stop method or external causes. It's the recommended way to do clean-up tasks.

      MessageEvent,            ## This event is raised when a message is sent to a text channel the bot is currently in.
      MessageDeleteEvent,      ## This event is raised when a message is deleted in a channel.
      MessageEditEvent,        ## This event is raised when a message is edited in a channel.
      #PrivateMessageEvent,    # We already handle this in the normal MessageEvent. ## This event is raised when a private message is sent to the bot.
      #MentionEvent,           ## This event is raised when the bot is mentioned in a message.

      ServerMemberAddEvent,    ## This event is raised when a new user joins a server.
      ServerMemberDeleteEvent, ## This event is raised when a member leaves a server.
      ServerMemberUpdateEvent, ## This event is raised when a member update happens.
      PresenceUpdateEvent,     ## This event is raised when a user's status (online/offline/idle) changes.
      UserBanEvent,            ## This event is raised when a user is banned from a server.
      UserUnbanEvent,          ## This event is raised when a user is unbanned from a server.
      ServerRoleCreateEvent,   ## This event is raised when a role is created.
      ServerRoleDeleteEvent,   ## This event is raised when a role is deleted.
      ServerRoleUpdateEvent,   ## This event is raised when a role is updated.

      VoiceStateUpdateEvent #, ## This event is raised when a user's voice state changes.
      #RawEvent,               ## This event is raised for every dispatch received over the gateway, whether supported by discordrb or not.
      #UnknownEvent            ## This event is raised for a dispatch received over the gateway that is not currently handled otherwise by discordrb.
    ]
    # Currently not handled. Maybe check for these at some time.
    #AwaitEvent,                  ## This event is raised when an Await is triggered. It provides an easy way to execute code on an await without having to rely on the await's block.
    #TypingEvent,                 ## This event is raised when somebody starts typing in a channel the bot is also in.
    #PlayingEvent,                ## This event is raised when the game a user is playing changes.
    #ReactionAddEvent,            ## This event is raised when somebody reacts to a message.
    #ReactionRemoveEvent,         ## This event is raised when somebody removes a reaction from a message.
    #ReactionRemoveAllEvent,      ## This event is raised when somebody removes all reactions from a message.
    #ChannelCreateEvent,          ## This event is raised when a channel is created.
    #ChannelDeleteEvent,          ## This event is raised when a channel is deleted.
    #ChannelUpdateEvent,          ## This event is raised when a channel is updated.
    #ChannelRecipientAddEvent,    ## This event is raised when a recipient is added to a group channel.
    #ChannelRecipientRemoveEvent, ## This event is raised when a recipient is removed from a group channel.
    #ServerCreateEvent,           ## This event is raised when a server is created respective to the bot, i.e. the bot joins a server or creates a new one itself.
    #ServerDeleteEvent,           ## This event is raised when a server is deleted, or when the bot leaves a server. (These two cases are identical to Discord.)
    #ServerUpdateEvent,           ## This event is raised when a server is updated, for example if the name or region has changed.
    #ServerEmojiChangeEvent,      ## Emoji is created/deleted/updated
    #ServerEmojiCreateEvent,      ## This event is raised when an emoji is created.
    #ServerEmojiDeleteEvent,      ## This event is raised when an emoji is deleted.
    #ServerEmojiUpdateEvent,      ## This event is raised when an emoji is updated.
    #WebhookUpdateEvent,          ## This event is raised when a webhook is updated.

    @acceptable_bot_event_responses_keys = {
      ready:               1,
      heartbeat:           1,
      raw_event:           1,

      message:             1,
      message_delete:      1,
      message_edit:        1,
      private_message:     1,
      mention:             1,

      channel_update:      1,

      member_join:         1,
      member_leave:        1,
      member_update:       1,
      presence_update:     1,
      role_update:         1,
      user_ban:            1,
      user_unban:          1,

      message_delete_mod:  0,
      member_join_mod:     0,
      member_leave_mod:    0,
      member_update_mod:   0,
      presence_update_mod: 0,

      user_has_nick:       0,
      user_modchanged:     0,
      illegal_cmd:         0,
      spamming_cmds:       0,
      command_usage:       0,
      roles_not_unique:    0,
      role_not_found:      0,
      role_added:          0,
      role_removed:        0,

      user_nicks:          0,
      user_nicks_loc:      0,
      user_messages:       0,

      user_kick:           0,
      member_rejoin:       0,
      mass_join_start:     0,
      mass_join_msg:       0,
      mass_leave:          0,
      mass_and:            0
    }



    public

    # Add the event handlers for all the events it is told to handle/react on.
    #
    # @return [nil]
    #
    def self.include!
      @events.each do |event|
        BifrostBot::BOT_OBJ.include!(event)
      end

      #return nil
      nil
    end



    # Quick check to see if the bot's response strings in the config file are acceptable.
    # To avoid obvious typos.
    #
    # @return [nil]
    #
    def self.check_config_file_event_responses
      config_event_responses = {}
      BOT_CONFIG.bot_event_responses.each_key { |key_value| config_event_responses[key_value] = true }

      config_event_responses.each_key do |key_val|
        config_event_responses.delete key_val if @acceptable_bot_event_responses_keys.key?(key_val)
      end

      config_event_responses.each_key do |key_val|
        warn_str = +'Invalid bot response key: ' << key_val.to_s << ''
        Debug.warn warn_str
      end

      #Debug.divider
      #ap config_event_responses
      #ap BOT_CONFIG.bot_event_responses

      #return nil
      nil
    end

  end
  #module Events
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
  https://www.rubydoc.info/github/meew0/discordrb/Discordrb/EventContainer

  #await(attributes = {}) {|event| ... } ⇒ AwaitEventHandler
    This event is raised when an Await is triggered. It provides an easy way to execute code on an await without having to rely on the await's block.

  #channel_create(attributes = {}) {|event| ... } ⇒ ChannelCreateEventHandler
    This event is raised when a channel is created.

  #channel_delete(attributes = {}) {|event| ... } ⇒ ChannelDeleteEventHandler
    This event is raised when a channel is deleted.

  #channel_recipient_add(attributes = {}) {|event| ... } ⇒ ChannelRecipientAddHandler
    This event is raised when a recipient is added to a group channel.

  #channel_recipient_remove(attributes = {}) {|event| ... } ⇒ ChannelRecipientRemoveHandler
    This event is raised when a recipient is removed from a group channel.

  #channel_update(attributes = {}) {|event| ... } ⇒ ChannelUpdateEventHandler
    This event is raised when a channel is updated.

  #disconnected(attributes = {}) {|event| ... } ⇒ DisconnectEventHandler
    This event is raised when the bot has disconnected from the WebSocket, due to the Bot#stop method or external causes. It's the recommended way to do clean-up tasks.

  #heartbeat(attributes = {}) {|event| ... } ⇒ HeartbeatEventHandler
    This event is raised every time the bot sends a heartbeat over the galaxy.
    This happens roughly every 40 seconds, but may happen at a lower rate should Discord change their interval.
    It may also happen more quickly for periods of time, especially for unstable connections, since discordrb rather sends a heartbeat than not if there's a choice. (You shouldn't rely on all this to be accurately timed.)
    All this makes this event useful to periodically trigger something, like doing some API request every hour, setting some kind of uptime variable or whatever else.
    The only limit is yourself.

  #member_join(attributes = {}) {|event| ... } ⇒ ServerMemberAddEventHandler
    This event is raised when a new user joins a server.

  #member_leave(attributes = {}) {|event| ... } ⇒ ServerMemberDeleteEventHandler
    This event is raised when a member leaves a server.

  #member_update(attributes = {}) {|event| ... } ⇒ ServerMemberUpdateEventHandler
    This event is raised when a member update happens.

  #mention(attributes = {}) {|event| ... } ⇒ MentionEventHandler
    This event is raised when the bot is mentioned in a message.

  #message(attributes = {}) {|event| ... } ⇒ MessageEventHandler
    This event is raised when a message is sent to a text channel the bot is currently in.

  #message_delete(attributes = {}) {|event| ... } ⇒ MessageDeleteEventHandler
    This event is raised when a message is deleted in a channel.

  #message_edit(attributes = {}) {|event| ... } ⇒ MessageEditEventHandler
    This event is raised when a message is edited in a channel.

  #playing(attributes = {}) {|event| ... } ⇒ PlayingEventHandler
    This event is raised when the game a user is playing changes.

  #pm(attributes = {}) {|event| ... } ⇒ PrivateMessageEventHandler (also: #private_message, #direct_message, #dm)
    This event is raised when a private message is sent to the bot.

  #presence(attributes = {}) {|event| ... } ⇒ PresenceEventHandler
    This event is raised when a user's status (online/offline/idle) changes.

  #raw(attributes = {}) {|event| ... } ⇒ RawEventHandler
    This event is raised for every dispatch received over the gateway, whether supported by discordrb or not.

  #reaction_add(attributes = {}) {|event| ... } ⇒ ReactionAddEventHandler
    This event is raised when somebody reacts to a message.

  #reaction_remove(attributes = {}) {|event| ... } ⇒ ReactionRemoveEventHandler
    This event is raised when somebody removes a reaction from a message.

  #reaction_remove_all(attributes = {}) {|event| ... } ⇒ ReactionRemoveAllEventHandler
    This event is raised when somebody removes all reactions from a message.

  #ready(attributes = {}) {|event| ... } ⇒ ReadyEventHandler
    This event is raised when the READY packet is received, i.e. servers and channels have finished initialization.
    It's the recommended way to do things when the bot has finished starting up.

  #server_create(attributes = {}) {|event| ... } ⇒ ServerCreateEventHandler
    This event is raised when a server is created respective to the bot, i.e. the bot joins a server or creates a new one itself.
    It should never be necessary to listen to this event as it will only ever be triggered by things the bot itself does, but one can never know.

  #server_delete(attributes = {}) {|event| ... } ⇒ ServerDeleteEventHandler
    This event is raised when a server is deleted, or when the bot leaves a server. (These two cases are identical to Discord.)

  #server_emoji(attributes = {}) {|event| ... } ⇒ ServerEmojiChangeEventHandler
    This event is raised when an emoji or collection of emojis is created/deleted/updated.

  #server_emoji_create(attributes = {}) {|event| ... } ⇒ ServerEmojiCreateEventHandler
    This event is raised when an emoji is created.

  #server_emoji_delete(attributes = {}) {|event| ... } ⇒ ServerEmojiDeleteEventHandler
    This event is raised when an emoji is deleted.

  #server_emoji_update(attributes = {}) {|event| ... } ⇒ ServerEmojiUpdateEventHandler
    This event is raised when an emoji is updated.

  #server_role_create(attributes = {}) {|event| ... } ⇒ ServerRoleCreateEventHandler
    This event is raised when a role is created.

  #server_role_delete(attributes = {}) {|event| ... } ⇒ ServerRoleDeleteEventHandler
    This event is raised when a role is deleted.

  #server_role_update(attributes = {}) {|event| ... } ⇒ ServerRoleUpdateEventHandler
    This event is raised when a role is updated.

  #server_update(attributes = {}) {|event| ... } ⇒ ServerUpdateEventHandler
    This event is raised when a server is updated, for example if the name or region has changed.

  #typing(attributes = {}) {|event| ... } ⇒ TypingEventHandler
    This event is raised when somebody starts typing in a channel the bot is also in.
    The official Discord client would display the typing indicator for five seconds after receiving this event.
    If the user continues typing after five seconds, the event will be re-raised.

  #unknown(attributes = {}) {|event| ... } ⇒ UnknownEventHandler
    This event is raised for a dispatch received over the gateway that is not currently handled otherwise by discordrb.

  #user_ban(attributes = {}) {|event| ... } ⇒ UserBanEventHandler
    This event is raised when a user is banned from a server.

  #user_unban(attributes = {}) {|event| ... } ⇒ UserUnbanEventHandler
    This event is raised when a user is unbanned from a server.

  #voice_state_update(attributes = {}) {|event| ... } ⇒ VoiceStateUpdateEventHandler
    This event is raised when a user's voice state changes.

  #webhook_update(attributes = {}) {|event| ... } ⇒ WebhookUpdateEventHandler
    This event is raised when a webhook is updated.
=end
