require 'discordrb'
require_relative 'store'
require_relative 'util'

module Commands
  # @param [Discordrb::Events::ApplicationCommandEvent] event
  def Commands::role_me(event)
    server = event.server
    if server == nil
      event.respond(content: "This belongs in a server.")
      return
    end
    event.respond(content: "", ephemeral: true) do |_, view|
      choices = Store::get_choices(server)
      Util::select_menu(view, choices)
    end
  end

  # @param [Discordrb::Events::ApplicationCommandEvent] event
  def Commands::add_role(event)
    server = event.server
    if server == nil
      return
    end
    role_id = event.options["role"]
    Store::store_choice(server.id.to_s, role_id)
    event.respond(content: "Added.", ephemeral: true)
  end
end
