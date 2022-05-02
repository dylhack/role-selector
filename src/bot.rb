require 'discordrb'
require_relative './store'
require_relative './commands'
require_relative './events'

module Bot
  # @param [Discordrb::Bot] bot
  # @param [Discordrb::Server?] dev_server
  def Bot::register_cmds(bot, dev_server = nil)
    dev_server = dev_server.id if dev_server != nil
    bot.register_application_command(:roleme, "Give yourself a role.", server_id: dev_server)
    bot.register_application_command(:addrole, "Add a role selection", server_id: dev_server) do |opts|
      opts.role(:role, "the role", required: true)
    end
  end

  def Bot::start_bot(token)
    bot = Discordrb::Bot.new(
      intents: [Discordrb::INTENTS[:servers], Discordrb::INTENTS[:server_messages]],
      token: token,
    )
    Events::register_events bot
    bot.run
  end
end
