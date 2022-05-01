module Events
  # @param [Discordrb::Bot] bot
  def Events::register_events(bot)
    bot.ready { |event| on_ready event }
    bot.reaction_add { |event| on_react event }
    bot.application_command(:addrole) { |event| Commands::add_role event }
    bot.application_command(:newselector) { |event| Commands::create_selector event }
    bot.application_command(:dropselector) { |event| Commands::drop_selector event }
    bot.application_command(:render) { |event| Commands::render event }
    bot.application_command(:testcmd) { |event| Commands::test_cmd event }
  end

  # @param [Discordrb::Events::ReactionAddEvent] event
  def Events::on_react(event)
    puts "react event"
    server = event.server
    user = event.user
    if server == nil and !(user.kind_of? Discordrb::Member)
      puts "giving up"
      return
    end
    choices = Store::get_choices(server, event.message_id)
    # Bot::sync(event.bot, server, event)
    puts "looking for emoji"
    choices.each { |emoji, role_id|
      if event.emoji == emoji
        puts "found emoji"
        role = server.role role_id
        user.add_role role
      end
    }
  end

  # @param [Discordrb::Events::ReadyEvent] event
  def Events::on_ready(event)
    printf("Ready as %s\n", event.bot.profile.username)
    selectors = Store::get_all_selectors event.bot
    selectors.each { |selector|
      choices = Store::get_choices(selector.server, selector.id)
      selector.reactions { |reaction|
        role = choices[reaction.emoji]
      }
    }
  end
end
