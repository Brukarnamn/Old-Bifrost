# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised for a dispatch received over the gateway that is not currently handled otherwise by discordrb.
    #
    # unknown(attributes = {}) {|event| ... } ⇒ UnknownEventHandler
    #
    module UnknownEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/UnknownEvent
      unknown do |event_obj|
        puts Debug.msg('----------UnknownEvent----------', 'red')
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        audit_type_event = false
        event_type = event_obj.type if event_obj.respond_to?('type')

        puts(+'-----' << Debug.msg('UNKNOWN EVENT', 'red') << '----->> ' << Debug.msg(event_obj.to_s) << ' >> ' << (event_type.nil? ? '<undef>' : Debug.msg(event_type)) << ' <<-----')

        next if !audit_type_event

        helper_obj = DiscordEventHelper.new event_obj
        puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(helper_obj, 0, false)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #UnknownEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  Attributes inherited from RawEvent
    #data, #type

  Attributes inherited from Event
    #bot


  Method Summary
  ==============

  Methods inherited from RawEvent
    #initialize
=end
