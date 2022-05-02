module Events
  # @param [Discordrb::Events::ReadyEvent] event
  def Events::on_ready(event)
    printf("Ready as %s\n", event.bot.profile.username)
    dev_server = ENV["VR_DEV_SERVER"]
    server = event.bot.server dev_server
    Bot::register_cmds(event.bot, server)
  end

  # @param [Discordrb::Events::SelectMenuEvent] event
  def Events::on_role_select(event)
    server = event.server
    member = event.user
    if server == nil or not member.kind_of? Discordrb::Member
      event.respond(content: "this belongs in a server", ephemeral: true)
      return
    end
    event.values.each do |role_id_str |
      role = server.role role_id_str.to_i
      if role != nil
        if member.role? role
          printf("Removing %s to %s\n", role.name, member.username)
          member.remove_role role
        else
          printf("Adding %s to %s\n", role.name, member.username)
          member.add_role role
        end
      end
    end
    event.respond(content: "👍", ephemeral: true)
  end

  # @param [Discordrb::Bot] bot
  def Events::register_events(bot)
    bot.ready { |event| on_ready event }
    bot.application_command(:addrole) { |event| Commands::add_role event }
    bot.application_command(:roleme) { |event| Commands::role_me event }
    bot.select_menu({:custom_id=>"role_select"}) { |event| Events::on_role_select event }
  end
end
