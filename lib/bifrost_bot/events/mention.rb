# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when the bot is mentioned in a message.
    #
    # mention(attributes = {}) {|event| ... } ⇒ MentionEventHandler
    #
    module MentionEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/MentionEvent
      mention do |event_obj|
        #puts Debug.msg('----------MentionEvent----------')
        helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        # Ignore the bot's own messages and any other bots to avoid endless loops.
        if !helper_obj.user_is_bot
          #config_str = helper_obj.user_mention + ', er det noe jeg kan hjelpe deg med?'
          config_str = BOT_CONFIG.bot_event_responses[:mention]
          config_str = helper_obj.substitute_event_vars config_str

          event_obj.respond config_str
        end

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #MentionEvent
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
  2017-11-21 16:27:45.159 websocket        ← {"t"=>"TYPING_START", "s"=>36, "op"=>0, "d"=>{"user_id"=>"123456789012345678", "timestamp"=>1511278064, "channel_id"=>"123456789012345678"}}
  2017-11-21 16:27:49.521 websocket        ← {"t"=>"MESSAGE_CREATE", "s"=>37, "op"=>0, "d"=>{
    "type"=>0,
    "tts"=>false,
    "timestamp"=>"2017-11-21T15:27:48.741000+00:00",
    "pinned"=>false,
    "nonce"=>"987654321098765432",
    "mentions"=>[{
      "username"=>"Testbot",
      "id"=>"987654321098765432",
      "discriminator"=>"1234",
      "bot"=>true,
      "avatar"=>"123456789abcdef123456789abcdef12"}],
    "mention_roles"=>[],
    "mention_everyone"=>false,
    "id"=>"123456789012345678",
    "embeds"=>[],
    "edited_timestamp"=>nil,
    "content"=>"<@123456789012345678> testetest",
    "channel_id"=>"123456789012345678",
    "author"=>{
      "username"=>"Testbot",
      "id"=>"123456789012345678",
      "discriminator"=>"1234",
      "avatar"=>nil},
    "attachments"=>[]}}

  #<Discordrb::Events::MentionEvent:0x000000000491ecf0
=end
