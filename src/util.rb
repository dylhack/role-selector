require 'discordrb'
require_relative 'store'

module Util
  # @param [Discordrb::Events::InteractionCreateEvent] event
  # @return [Boolean]
  def Util::has_perms(event)
    result = false
    member = event.user
    if member.kind_of? Discordrb::Member
      result = member.permission? :administrator
    end
    unless result
      event.respond(content: "You don't have permissions.", ephemeral: true)
    end

    result
  end

  # @param [Discordrb::Message] message
  # @param [Hash] choices [String, Role]
  def Util::add_reacts(message, choices = {})
    # because Interactions::Message doesn't have react we have to convert it
    # to a Discordrb::Message
    target = message.message
    choices.each { |emoji, _|
      target.react emoji
    }
  end

  # @param [Discordrb::Channel] channel
  # @param [Discordrb::String] chooser_id
  # @param [Discordrb::Webhooks::Embed] embed
  def Util::edit_selector(channel, chooser_id, choices)
    message = channel.message chooser_id
    embed = Util::render choices
    if message != nil
      message.edit("", embed)
      Util::add_reacts(message, choices)
    end
  end

  # @param [Discordrb::Webhooks::Embed]
  # @param [Hash[String, Discordrb::Role]]
  # @return [Discordrb::Webhooks::Embed]
  def Util::selector_embed(embed, choices = {})
    embed.title = "Role Selection"
    embed.color = 0x031CD7
    embed.description = ""
    choices.each { |emoji, role|
      field = Discordrb::Webhooks::EmbedField.new
      field.name = emoji
      field.value = role.mention
      field.inline = true
      embed.fields.push field
    }
    embed
  end

  # @param [Discordrb::Server] server
  # @param [String] chooser_id
  # @param [Hash[String, Role]] choices [emoji, role]
  def Util::render(choices = {})
    embed = Discordrb::Webhooks::Embed.new
    Util::selector_embed(embed, choices)
  end
end
