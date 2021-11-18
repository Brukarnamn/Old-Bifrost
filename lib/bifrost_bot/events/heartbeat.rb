# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'
    require 'time'

    # This event is raised every time the bot sends a heartbeat over the galaxy.
    # This happens roughly every 40 seconds, but may happen at a lower rate should Discord change their interval.
    # It may also happen more quickly for periods of time, especially for unstable connections, since discordrb rather sends a heartbeat than not if there's a choice. (You shouldn't rely on all this to be accurately timed.)
    # All this makes this event useful to periodically trigger something, like doing some API request every hour, setting some kind of uptime variable or whatever else.
    # The only limit is yourself.
    #
    # heartbeat(attributes = {}) {|event| ... } ⇒ HeartbeatEventHandler
    #
    module HeartbeatEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/HeartbeatEvent
      heartbeat do #|event_obj|
        puts Debug.msg('----------HeartbeatEvent----------')
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        #config_str = BOT_CONFIG.bot_event_responses[:heartbeat]
        #config_str = helper_obj.substitute_event_vars config_str
        config_str = ' ... '

        # Generate a new admin system code.
        admin_system_code = BOT_CONFIG.generate_new_system_code
        if BOT_CONFIG.debug
          LOGGER.info Debug.msg(admin_system_code) + config_str
        else
          print Debug.msg(admin_system_code) + config_str
        end

        # Checks to see if there has been inactivity for too long.
        Commands::RiddleText.check_if_inactivity_text_should_be_shown

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #HeartbeatEvent
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
=begin
  2018-10-16 17:10:41.562 heartbeat        → {"op":1,"d":7}
  2018-10-16 17:10:41.693 websocket        ← {"t"=>nil, "s"=>nil, "op"=>11, "d"=>nil}
  2018-10-16 17:10:41.694 websocket        D Received heartbeat ack for packet: {"t"=>nil, "s"=>nil, "op"=>11, "d"=>nil}
  2018-10-16 17:11:22.814 heartbeat        D Raised a Discordrb::Events::HeartbeatEvent

  #<Discordrb::Events::HeartbeatEvent:0x00000000046a1d60
=end
