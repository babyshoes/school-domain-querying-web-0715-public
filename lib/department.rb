require 'pry'
class Department

	attr_accessor :id, :name, :courses

	 def self.create_table
	 		sql = <<-SQL
				CREATE TABLE IF NOT EXISTS departments(
					id INTEGER PRIMARY KEY,
					name TEXT
				)
			SQL
			DB[:conn].execute(sql)
	 end

	 def self.drop_table
		 sql = "DROP TABLE IF EXISTS departments"
		 DB[:conn].execute(sql)
	 end

	 def insert
		 sql = <<-SQL
		 		INSERT INTO departments(name)
				VALUES(?)
		 SQL
		 DB[:conn].execute(sql, name)
		 @id = DB[:conn].execute("SELECT last_insert_rowid() FROM departments").flatten[0]
	 end

	 def self.new_from_db(row)
			d = new
			d.id = row[0]
			d.name = row[1]
			d
	 end

	 def self.find_by_name(name)
		 sql = <<-SQL
		 		SELECT *
				FROM departments
				WHERE name = ?
		 SQL
		 DB[:conn].execute(sql, name).map do |row|
			 new_from_db(row)
		 end.first
	 end

	 def self.find_by_id(id)
	 		sql = <<-SQL
				SELECT *
				FROM departments
				WHERE id = ?
			SQL

			DB[:conn].execute(sql, id).map do |row|
				new_from_db(row)
			end.first
	 end

	#  def attributes
	# 	 [name, courses]
	#  end

	 def update
		 sql = <<-SQL
		 		UPDATE departments
				SET name = ?
				WHERE id = ?
		 SQL
		 DB[:conn].execute(sql, name, id)
	 end

	 def persisted?
		 !!id
	 end

	 def save
		 persisted? ? update : insert
	 end

	 def courses
		 Course.find_all_by_department_id(id)
	 end

	 def add_course(course)
		 course.department = self
		 course.save
		 save
		#  binding.pry
	 end
	 

end
