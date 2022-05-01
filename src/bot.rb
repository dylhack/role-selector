require 'discordrb'
require_relative './store'
require_relative './commands'
require_relative './events'

module Bot
  # @param [Discordrb::Member] member
  # @return [bool]
  def Bot::has_perms(member)
    return member.permission? :administrator
  end

  # @param [Discordrb::Bot] bot
  def Bot::register_cmds(bot)
    dev_server = ENV["VR_DEV_SERVER"]
    bot.register_application_command(:testcmd, "Test command.", server_id: dev_server)
    bot.register_application_command(:render, "Render selector.", server_id: dev_server)
    bot.register_application_command(:newselector, "Create a selector for this channel.", server_id: dev_server)
    bot.register_application_command(:dropselector, "Drop selector for a channel", server_id: dev_server) do |opts|
      opts.channel(:channel, "select a channel.", required: false)
    end
    bot.register_application_command(:addrole, "Add a role selection", server_id: dev_server) do |opts|
      opts.string(:emoji, "the emoji", required: true)
      opts.role(:role, "the role", required: true)
    end
  end

  def Bot::start_bot(token)
    bot = Discordrb::Bot.new(
      intents: [Discordrb::INTENTS[:servers], Discordrb::INTENTS[:server_messages]],
      token: token,
    )
    Events::register_events bot
    Bot::register_cmds bot
    bot.run
  end
end
