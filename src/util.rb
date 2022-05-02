require 'discordrb'
require_relative 'store'

module Util
  # @param [Discordrb::Webhooks::View] view
  # @param [Array<Discordrb::Role>] choices
  def Util::select_menu(view, choices)
    view.row do |row|
      row.select_menu(custom_id: 'role_select', placeholder: 'Select Roles!', max_values: choices.length) do |select|
        choices.each { |role|
          select.option(label: role.name, value: role.id.to_s)
        }
      end
    end
  end
end
