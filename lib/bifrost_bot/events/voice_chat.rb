# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a user's voice state changes.
    #
    # voice_state_update(attributes = {}) {|event| ... } ⇒ VoiceStateUpdateEventHandler
    #
    module VoiceStateUpdateEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/VoiceStateUpdateEvent
      voice_state_update do |event_obj|
        puts Debug.msg('----------VoiceStateUpdateEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #VoiceStateUpdateEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  #channel ⇒ Object readonly
    Returns the value of attribute channel.

  #deaf ⇒ Object readonly
    Returns the value of attribute deaf.

  #mute ⇒ Object readonly
    Returns the value of attribute mute.

  #old_channel ⇒ Channel? readonly
    The old channel this user was on, or nil if the user is newly joining voice.

  #self_deaf ⇒ Object readonly
    Returns the value of attribute self_deaf.

  #self_mute ⇒ Object readonly
    Returns the value of attribute self_mute.

  #server ⇒ Object readonly
    Returns the value of attribute server.

  #session_id ⇒ Object readonly
    Returns the value of attribute session_id.

  #suppress ⇒ Object readonly
    Returns the value of attribute suppress.

  #token ⇒ Object readonly
    Returns the value of attribute token.

  #user ⇒ Object readonly
    Returns the value of attribute user.

  Attributes inherited from Event
    #bot


  Instance Method Summary
  =======================

  #initialize(data, old_channel_id, bot) ⇒ VoiceStateUpdateEvent constructor
    A new instance of VoiceStateUpdateEvent.
=end
