# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a role is deleted.
    #
    # server_role_delete(attributes = {}) {|event| ... } ⇒ ServerRoleDeleteEventHandler
    #
    module ServerRoleDeleteEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/ServerRoleDeleteEvent
      server_role_delete do |event_obj|
        #puts Debug.msg('----------ServerRoleDeleteEvent----------')
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        #ap event_obj

        #Debug.pp BOT_CACHE.role_ids
        #Debug.pp BOT_CACHE.role_names

        BOT_CACHE.remove_role(event_obj.id)

        #Debug.pp BOT_CACHE.role_ids
        #Debug.pp BOT_CACHE.role_names

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #ServerRoleDeleteEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  #id ⇒ Integer readonly
    The ID of the role that got deleted.

  #server ⇒ Server readonly
    The server on which a role got deleted.

  Attributes inherited from Event
    #bot

  Instance Method Summary
  =======================

  #initialize(data, bot) ⇒ ServerRoleDeleteEvent constructor
    A new instance of ServerRoleDeleteEvent.
=end
=begin
  2018-10-27 18:40:22.294 websocket        ← {"t"=>"GUILD_ROLE_DELETE", "s"=>24, "op"=>0, "d"=>{
    "role_id"=>"987654321098765432",
    "guild_id"=>"348172070947127306"
  }}
=end
