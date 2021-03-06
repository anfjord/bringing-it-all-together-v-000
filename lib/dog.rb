require_relative '../config/environment.rb'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
      SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs where id = ?
    SQL

    results = DB[:conn].execute(sql, id)
    dog = Dog.new(id: results[0][0], name: results[0][1], breed: results[0][2])
    dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
     self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL

    row = DB[:conn].execute(sql, name)
    dog = Dog.new_from_db(row[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET id = ?, name = ?, breed = ?
    SQL
    DB[:conn].execute(sql, self.id, self.name, self.breed)
  end

end
