require 'sqlite3'

module Store
  def Store::drop_selectors(channel_id)
    $database.execute("DELETE FROM main.role_selectors WHERE channel_id = ?",
                      [channel_id])
  end

  # @return [String?]
  def Store::get_selector_id(channel_id)
    $database.execute("SELECT (message_id) FROM main.role_selectors WHERE channel_id = ?",
                      [channel_id]) do |row|
      return row[0]
    end
    return nil
  end

  # @param [Discordrb::Bot] bot
  # @return [Array[Message]]
  def Store::get_all_selectors(bot)
    result = []
    selectors = []
    $database.execute("SELECT guild_id, channel_id, message_id FROM main.role_selectors;") do |row|
      selectors.push [row[0], row[1], row[2]]
    end

    def drop(guild_id, message_id)
      $database.execute("DELETE FROM main.role_selectors WHERE main.role_selectors.guild_id = ?", [guild_id])
      $database.execute("DELETE FROM main.role_choices WHERE chooser_id = ?", [message_id])
    end

    selectors.each { |pair|
      guild_id = pair[0]
      channel_id = pair[1]
      message_id = pair[2]

      server = bot.server guild_id
      if server == nil
        drop(guild_id, message_id)
        break
      end
      channel = bot.channel channel_id
      if channel == nil
        drop(guild_id, message_id)
        break
      end
      message = channel.message message_id
      if message != nil
        result.push message
      end
    }
    result
  end

  # @param [String] channel_id
  # @param [String] new_id
  def Store::update_chooser_id(old_id, new_id)
    $database.execute("UPDATE main.role_choices SET chooser_id=? WHERE chooser_id=?",
                      [new_id, old_id])
    $database.execute("UPDATE main.role_selectors SET message_id=? WHERE message_id=?",
                      [new_id, old_id])
  end

  # @param [String] role_id
  def Store::drop_choice(role_id)
    $database.execute("DELETE FROM main.role_choices WHERE role_id = ?", [role_id])
  end

  # @param [Discordrb::Server] server
  # @param [String] chooser_id
  # @return [Hash[String, Role]]
  def Store::get_choices(server, chooser_id)
    raw_choices = {}
    $database.execute("SELECT emoji_id, role_id FROM main.role_choices WHERE chooser_id = ?",
                      [chooser_id]) do |row|
      raw_choices[row[0]] = row[1]
    end
    result = {}
    raw_choices.each do | emoji, role_id |
      role = server.role role_id
      if role == nil
        Store::drop_choice role_id
      end
      result[emoji] = role
    end
    result
  end

  # @param [String] chooser_id
  # @param [String] role_id
  # @param [String] emoji_id
  def Store::store_role_choice(chooser_id, role_id, emoji_id)
    $database.execute("INSERT INTO main.role_choices (chooser_id, role_id, emoji_id) VALUES (?, ?, ?)",
                      [chooser_id, role_id, emoji_id])
  end

  # @param [String] guild_id
  # @param [String] channel_id
  # @param [String] message_id
  def Store::store_selector(guild_id, channel_id, message_id)
    $database.execute("INSERT INTO main.role_selectors (guild_id, channel_id, message_id) VALUES (?, ?, ?)",
                      [guild_id, channel_id, message_id])
  end

  def Store::start_database(location)
    $database = SQLite3::Database.new location
    $database.execute <<-SQL
      create table if not exists role_selectors
      (
          guild_id   text not null,
          channel_id text not null,
          message_id text not null
              constraint role_selectors_pk
                  primary key
      );

      create unique index if not exists role_selectors_channel_id_uindex
          on role_selectors (channel_id);
    SQL
    $database.execute <<-SQL
      create table if not exists role_selectors 
      (
          guild_id   text not null,
          channel_id text not null,
          message_id text not null
              constraint role_selectors_pk
                  primary key
      );
    SQL
  end
end
