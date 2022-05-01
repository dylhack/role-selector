require 'discordrb'
require_relative 'store'
require_relative 'util'

module Commands
  # @param [Discordrb::Events::ApplicationCommandEvent] event
  def Commands::test_cmd(event)
    event.respond(content: "test response") do |_, view|
      view.row do |r|
        r.select_menu(custom_id: 'test_select', placeholder: 'Select me!', max_values: 3) do |s|
          s.option(label: 'Foo', value: 'foo')
          s.option(label: 'Bar', value: 'bar')
          s.option(label: 'Baz', value: 'baz')
          s.option(label: 'Bazinga', value: 'bazinga')
        end
      end
    end
  end

  # @param [Discordrb::Events::ApplicationCommandEvent] event
  def Commands::add_role(event)
    unless Util::has_perms(event)
      return
    end
    chooser_id = Store::get_selector_id event.channel_id
    if chooser_id == nil
      event.respond(content: "There isn't a selector for this channel. Run `/newselector`", ephemeral: true)
      return
    end
    role_id = event.options["role"]
    emoji = event.options["emoji"]
    Store::store_role_choice(chooser_id, role_id.to_s, emoji)
    choices = Store::get_choices(event.server, chooser_id)
    Util::edit_selector(event.channel, chooser_id, choices)
    event.respond(content: "Done.", ephemeral: true)
  end

  # @param [Discordrb::Events::ApplicationCommandEvent] event
  def Commands::drop_selector(event)
    unless Util::has_perms(event)
      return
    end
    channel = event.options[:channel]
    channel = event.channel if channel == nil
    channel_id = channel.id
    Store::drop_selectors channel_id
    event.respond(content: "Selector dropped", ephemeral: true)
  end

  # @param [Discordrb::Events::ApplicationCommandEvent] event
  def Commands::render(event)
    unless Util::has_perms(event)
      return
    end
    server = event.server
    if server == nil
      event.respond(content: "This command belongs in a server.", ephemeral: true)
      return
    end
    channel = event.channel
    chooser_id = Store::get_selector_id channel.id
    if chooser_id == nil
      event.respond(content: "There is not a selector for this channel.", ephemeral: true)
      return
    end
    choices = Store::get_choices(server, chooser_id)
    embed = Util::render(choices)
    message = event.respond(embeds: [embed], wait: true)
    Util::add_reacts(message, choices)
    Store::update_chooser_id(event.channel_id, message.id)
  end

  # @param [Discordrb::Events::ApplicationCommandEvent] event
  def Commands::create_selector(event)
    unless Util::has_perms(event)
      return
    end
    selector_id = Store::get_selector_id event.channel_id
    if selector_id != nil
      event.respond(content: "A selector already exists, run `/dropselectors`", ephemeral: true)
      return
    end

    channel = event.channel
    channel_id = channel.id
    message = event.respond(wait: true) do |builder|
      builder.add_embed do |embed|
        Util::selector_embed embed
      end
    end
    Store::store_selector(
      event.server_id.to_s,
      channel_id,
      message.id.to_s,
    )
  end
end
