# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a private message is sent to the bot.
    #
    # pm(attributes = {}) {|event| ... } ⇒ PrivateMessageEventHandler (also: #private_message, #direct_message, #dm)
    #
    module PrivateMessageEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/PrivateMessageEvent
      #
      # This already gets handled by the normal message event. Would have to check what kind of message type it is there.
      #
      private_message do #|event_obj|
        #puts Debug.msg('----------PrivateMessageEvent----------')
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        #helper_obj.write_message_to_db

        #config_str = BOT_CONFIG.bot_event_responses[:private_message]
        #config_str = helper_obj.substitute_event_vars config_str

        #Debug.pp(private_message_cmd: helper_obj.command,
        #         private_message_add: helper_obj.uc_command_args_str)

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #PrivateMessageEvent
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
  2017-11-21 16:32:33.629 websocket        ← {"t"=>"CHANNEL_CREATE", "s"=>54, "op"=>0, "d"=>{"type"=>1, "recipients"=>[{"username"=>"Testbot", "id"=>"123456789012345678", "discriminator"=>"6556", "avatar"=>nil}], "last_message_id"=>"987654321098765432", "id"=>"123456789012345678"}}
  2017-11-21 16:32:33.634 websocket        ← {"t"=>"MESSAGE_CREATE", "s"=>55, "op"=>0, "d"=>{
    "type"=>0,
    "tts"=>false,
    "timestamp"=>"2017-11-21T15:32:32.909000+00:00",
    "pinned"=>false,
    "nonce"=>"987654321098765432",
    "mentions"=>[],
    "mention_roles"=>[],
    "mention_everyone"=>false,
    "id"=>"987654321098765432",
    "embeds"=>[],
    "edited_timestamp"=>nil,
    "content"=>"testest setset private message teststset set",
    "channel_id"=>"123456789012345678",
    "author"=>{
      "username"=>"Testbot",
      "id"=>"123456789012345678",
      "discriminator"=>"6556",
      "avatar"=>nil},
    "attachments"=>[]}}

  #<Discordrb::Events::PrivateMessageEvent
=end
