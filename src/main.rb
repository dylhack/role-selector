require 'active_record'
require_relative 'bot'

module Main
  class EnvNotFound < StandardError
  end

  # @raise [EnvNotFound]
  # @return [String]
  def Main::get_token
    ENV['VR_TOKEN'] or raise EnvNotFound
  end

  # @return [String]
  def Main::get_database
    location = ENV["VR_DATABASE"]
    location = "./vrbot.db" if location == nil
    location
  end

  def Main::main
    token = Main::get_token
    location = Main::get_database
    Store::start_database location
    Bot::start_bot token
  end

  main
end
