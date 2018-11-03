# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised for every dispatch received over the gateway, whether supported by discordrb or not.
    #
    # raw(attributes = {}) {|event| ... } ⇒ RawEventHandler
    #
    module RawEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/RawEvent
      raw do |event_obj|
        #puts Debug.msg('----------RawEvent----------')
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        audit_type_event = false
        event_type = event_obj.type if event_obj.respond_to?('type')

        puts(+'-----' << Debug.msg('RAW EVENT', 'cyan') << '----->> ' << event_obj.to_s << ' >> ' << (event_type.nil? ? '<undef>' : Debug.msg(event_type)) << ' <<-----') if BOT_CONFIG.debug_spammy

        #case event_type
        #when :RESUMED
        #  puts Debug.msg('Oops! Lost connection for a while.')
        #else
        #end

        #return if !audit_type_event Exception: #<LocalJumpError: unexpected return>
        next if !audit_type_event

        helper_obj = DiscordEventHelper.new event_obj
        puts Debug.msg("#{__FILE__},#{__LINE__}:"), Debug.pp(helper_obj, 0, false)

        #config_str = BOT_CONFIG.bot_event_responses[:raw_event]
        #config_str = helper_obj.substitute_event_vars config_str

        #BOT_OBJ.send_message(BOT_CONFIG.audit_spam_public_channel_id, config_str)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #RawEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  #data ⇒ Hash (also: #d) readonly
    The data of this dispatch.

  #type ⇒ Symbol (also: #t) readonly
    The type of this dispatch.

  Attributes inherited from Event
    #bot


  Instance Method Summary
  =======================

  #initialize(type, data, bot) ⇒ RawEvent constructor
    A new instance of RawEvent.
=end
