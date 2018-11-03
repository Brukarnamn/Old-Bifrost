# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a role is updated.
    #
    # server_role_update(attributes = {}) {|event| ... } ⇒ ServerRoleUpdateEventHandler
    #
    module ServerRoleUpdateEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/ServerRoleUpdateEvent
      server_role_update do |event_obj|
        #puts Debug.msg('----------ServerRoleUpdateEvent----------')
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        #ap event_obj.role

        #return nil # Exception: #<LocalJumpError: unexpected return>
        next if event_obj.role.name == '@everyone' && event_obj.role.id == BOT_CONFIG.bot_runs_on_server_id

        #Debug.pp BOT_CACHE.role_ids
        #Debug.pp BOT_CACHE.role_names

        BOT_CACHE.update_role(event_obj.role)

        #Debug.pp BOT_CACHE.role_ids
        #Debug.pp BOT_CACHE.role_names

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #ServerRoleUpdateEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  Attributes inherited from ServerRoleCreateEvent
    #name, #role, #server

  Attributes inherited from Event
    #bot

  Method Summary
  ==============

  Methods inherited from ServerRoleCreateEvent
    #initialize
=end
=begin
  2018-10-27 15:10:38.169 websocket        ← {"t"=>"GUILD_ROLE_UPDATE", "s"=>34, "op"=>0, "d"=>{
    "role"=>{
      "position"=>0,
      "permissions"=>68608,
      "name"=>"@everyone",
      "mentionable"=>false,
      "managed"=>false,
      "id"=>"123456789012345678",
      "hoist"=>false,
      "color"=>0
    },
    "guild_id"=>"123456789012345678"
  }}
  2018-10-27 15:10:38.317 websocket        ← {"t"=>"GUILD_ROLE_UPDATE", "s"=>35, "op"=>0, "d"=>{
    "role"=>{
      "position"=>2,
      "permissions"=>0,
      "name"=>"KAFFE",
      "mentionable"=>false,
      "managed"=>false,
      "id"=>"123456789012345679",
      "hoist"=>false,
      "color"=>5716482
    },
    "guild_id"=>"123456789012345678"
  }}
=end
