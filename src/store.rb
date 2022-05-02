require 'sqlite3'

module Store
  # @param [String] role_id
  def Store::drop_choice(role_id)
    $database.execute("DELETE FROM main.role_choices WHERE role_id = ?", [role_id])
  end

  # @param [Discordrb::Server] server
  # @return [Array<Discordrb::Role>]
  def Store::get_choices(server)
    role_ids = []
    $database.execute("SELECT role_id FROM main.role_choices WHERE guild_id = ?",
                      [server.id]) do |row|
      role_ids.push row[0]
    end
    roles = []
    role_ids.each do | role_id |
      role = server.role role_id
      if role != nil
        roles.push role
      else
          Store::drop_choice role_id
      end
    end
    roles
  end

  # @param [String] guild_id
  # @param [String] role_id
  def Store::store_choice(guild_id, role_id)
    $database.execute("INSERT INTO main.role_choices (guild_id, role_id) VALUES (?, ?)",
                      [guild_id, role_id])
  end

  def Store::start_database(location)
    $database = SQLite3::Database.new location
    $database.execute <<-SQL
      create table if not exists role_choices
      (
          guild_id   text not null,
          role_id    text not null
      );
    SQL
  end
end
