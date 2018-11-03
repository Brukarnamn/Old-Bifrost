# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when the bot has disconnected from the WebSocket,
    # due to the Bot#stop method or external causes.
    # It's the recommended way to do clean-up tasks.
    #
    # disconnected(attributes = {}) {|event| ... } ⇒ DisconnectEventHandler
    #
    module DisconnectEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/DisconnectEvent
      disconnected do #|event_obj|
        #puts Debug.msg('----------DisconnectEvent----------')
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #DisconnectEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  Attributes inherited from Event
    #bot
=end
