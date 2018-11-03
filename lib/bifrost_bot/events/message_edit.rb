# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a message is edited in a channel.
    #
    # message_edit(attributes = {}) {|event| ... } ⇒ MessageEditEventHandler
    #
    module MessageEditEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/MessageEditEvent
      message_edit do |event_obj|
        #puts Debug.msg('----------MessageEditEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        # Store the updated message in the database.
        helper_obj.write_message_to_db

        #config_str = 'You changed the message... :thinking:'
        #
        #config_str = BOT_CONFIG.bot_event_responses[:message_edit]
        #config_str = helper_obj.substitute_event_vars config_str

        #event_obj.respond config_str

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #MessageEditEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  Attributes inherited from MessageEvent
    #author, #channel, #content, #file, #message, #saved_message, #server, #timestamp

  Attributes included from Respondable
    #channel

  Attributes inherited from Event
    #bot


  Method Summary
  ==============

  Methods inherited from MessageEvent
    #attach_file, #detach_file, #from_bot?, #initialize, #send_file, #voice

  Methods included from Respondable
    #<<, #drain, #drain_into, #send_embed, #send_message, #send_temporary_message
=end
=begin
  2017-11-21 15:43:21.806 websocket        ← {"t"=>"MESSAGE_UPDATE", "s"=>7, "op"=>0, "d"=>{
    "type"=>0,
    "tts"=>false,
    "timestamp"=>"2017-11-21T14:38:29.097000+00:00",
    "pinned"=>false,
    "nonce"=>nil,
    "mentions"=>[],
    "mention_roles"=>[],
    "mention_everyone"=>false,
    "id"=>"123456789012345678",
    "embeds"=>[],
    "edited_timestamp"=>"2017-11-21T14:43:21.147552+00:00",
    "content"=>"tetstststeeest etstset setrtsetstest testsets",
    "channel_id"=>"123456789012345678",
    "author"=>{
      "username"=>"Testbot",
      "id"=>"123456789012345678",
      "discriminator"=>"6556",
      "avatar"=>nil},
    "attachments"=>[]}}

  #<Discordrb::Events::MessageEditEvent:0x000000000332f070
=end
