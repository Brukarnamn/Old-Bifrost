# frozen_string_literal: true
# Set string literals to be frozen by default. Magic ruby line.

# Bifrost / Askeladden v2
module BifrostBot
  # Module for BifrostBot events.
  module Events
    require 'debug'

    # This event is raised when a role is created.
    #
    #server_role_create(attributes = {}) {|event| ... } ⇒ ServerRoleCreateEventHandler
    #
    module ServerRoleCreateEvent
      extend Discordrb::EventContainer

      # https://www.rubydoc.info/github/meew0/discordrb/Discordrb/Events/ServerRoleCreateEvent
      server_role_create do |event_obj|
        #puts Debug.msg('----------ServerRoleCreateEvent----------')
        #helper_obj = DiscordEventHelper.new event_obj
        #Debug.pp helper_obj

        #ap event_obj.role

        #Debug.pp BOT_CACHE.role_ids
        #Debug.pp BOT_CACHE.role_names

        BOT_CACHE.update_role(event_obj.role)

        #Debug.pp BOT_CACHE.role_ids
        #Debug.pp BOT_CACHE.role_names

        #return nil # Exception: #<LocalJumpError: unexpected return>
        nil
      end

    end
    #ServerRoleCreateEvent
  end
  #module Events
end
#module BifrostBot



=begin
  Instance Attribute Summary
  ==========================

  #name ⇒ String readonly
    This role's name.

  #role ⇒ Role readonly
    The role that got created.

  #server ⇒ Server readonly
    The server on which a role got created.

  Attributes inherited from Event
    #bot

  Instance Method Summary
  =======================

  #initialize(data, bot) ⇒ ServerRoleCreateEvent constructor
    A new instance of ServerRoleCreateEvent.
=end
=begin
  2018-10-27 18:10:44.678 websocket        ← {"t"=>"GUILD_ROLE_CREATE", "s"=>10, "op"=>0, "d"=>{
    "role"=>{
      "position"=>1,
      "permissions"=>68608,
      "name"=>"new role",
      "mentionable"=>false,
      "managed"=>false,
      "id"=>"123456789012345699",
      "hoist"=>false,
      "color"=>0
    },
    "guild_id"=>"123456789012345678"
  }}
  2018-10-27 18:10:48.884 websocket        ← {"t"=>"GUILD_ROLE_UPDATE", "s"=>11, "op"=>0, "d"=>{"role"=>{"position"=>0, "permissions"=>68608, "name"=>"@everyone", "mentionable"=>false, "managed"=>false, "id"=>"123456789012345678", "hoist"=>false, "color"=>0}, "guild_id"=>"123456789012345678"}}
  2018-10-27 18:10:48.899 websocket        ← {"t"=>"GUILD_ROLE_UPDATE", "s"=>13, "op"=>0, "d"=>{"role"=>{"position"=>3, "permissions"=>0, "name"=>"TE", "mentionable"=>false, "managed"=>false, "id"=>"123456789012345680", "hoist"=>false, "color"=>5716482}, "guild_id"=>"123456789012345678"}}
  2018-10-27 18:10:48.905 websocket        ← {"t"=>"GUILD_ROLE_UPDATE", "s"=>14, "op"=>0, "d"=>{"role"=>{"position"=>4, "permissions"=>0, "name"=>"KAFFE", "mentionable"=>false, "managed"=>false, "id"=>"123456789012345681", "hoist"=>false, "color"=>5716482}, "guild_id"=>"123456789012345678"}}
  2018-10-27 18:10:49.031 websocket        ← {"t"=>"GUILD_ROLE_UPDATE", "s"=>27, "op"=>0, "d"=>{"role"=>{"position"=>17, "permissions"=>2146958591, "name"=>"Owner", "mentionable"=>false, "managed"=>false, "id"=>"123456789012345679", "hoist"=>true, "color"=>14970623}, "guild_id"=>"123456789012345678"}}
  2018-10-27 18:10:49.504 websocket        ← {"t"=>"GUILD_ROLE_UPDATE", "s"=>28, "op"=>0, "d"=>{"role"=>{"position"=>1, "permissions"=>68608, "name"=>"new role", "mentionable"=>false, "managed"=>false, "id"=>"123456789012345699", "hoist"=>false, "color"=>9936031}, "guild_id"=>"123456789012345678"}}
=end
