class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:,id:nil)
    @name = name
    @album = album
    @id = id
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS songs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          album TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album) VALUES (?,?)
    SQL
    #insert the song
    DB[:conn].execute(sql, self.name, self.album)
        # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  def self.new_from_db(row)
    self.new(name: row[1], album:row[2], id:row[0])
  end

  def self.all
    sql = <<-SQL 
      SELECT *
      FROM songs
    SQL
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
    
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM songs
      WHERE name = ?
      LIMIT 1
    SQL
    #Don't be freaked out by that #first method chained to the end of the DB[:conn].execute(sql, name).map block. 
    #The return value of the #map method is an array, and we're simply grabbing the #first element from the returned array. 
    #Chaining is cool!


    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end    
end
