class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id=nil, dog_hash)
    @id = id
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
  end

  def self.create_table
    sql = 'CREATE TABLE IF NOT EXISTS dogs (id Integer, name TEXT, breed TEXT);'
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = 'DROP TABLE dogs;'
    DB[:conn].execute(sql)
  end

  #saves dog object to database
  def save
    if self.id
      self.update
    else
      sql = 'INSERT INTO dogs (name, breed) VALUES (?, ?);'
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs;')[0][0]
    end
    self
  end
  
  #creates new dog object and saves to database
  def self.create(dog_hash)
    dog = Dog.new(dog_hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = 'SELECT * FROM dogs WHERE id = ?;'
    result = DB[:conn].execute(sql, id)[0]
    self.new_from_db(result)
  end

  def self.find_or_create_by(attributes)
    #note the use of AND rather than comma
    sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?;'
    result = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
    if !result.empty?
      dog = self.new_from_db(result[0])
    else
      dog = self.create(attributes)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(row[0], {name: row[1], breed: row[2]})
  end

  def self.find_by_name(name)
    sql = 'SELECT * FROM dogs WHERE name = ?;'
    result = DB[:conn].execute(sql, name)[0]
    self.new_from_db(result)
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?;'
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
