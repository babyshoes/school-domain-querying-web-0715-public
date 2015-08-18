require 'pry'
class Course


  attr_accessor :id, :name, :department_id, :students

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS courses(
        id INTEGER PRIMARY KEY,
        name TEXT,
        department_id INTEGER REFERENCES departments,
        department TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS courses"
    DB[:conn].execute(sql)
  end

  def attributes
    [name, department_id]
  end

  def department=(department)
    if department
      @department = department
      self.department_id = department.id
    end
    # binding.pry
  end

  def department
    @department = Department.find_by_id(@department_id)
  end


  def insert
    sql = <<-SQL
      INSERT INTO courses (name, department_id)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, attributes)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM courses").flatten[0]
  end

  def self.new_from_db(row)
    # attributes = ["id", "name", "department_id", "department", "students"]
    # subject = Course.new
    # i = 0
    # while i < row.length
    #   subject.send("#{attributes[i]}=", row[i])
    #   i += 1
    # end
    # subject

    course=Course.new
    course.id = row[0]
    course.name = row[1]
    course.department_id = row[2]
    course
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM courses
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
    # row = DB[:conn].execute(sql, name).flatten
    # new_from_db(row) unless row.empty?
  end

  def self.find_all_by_department_id(department_id)
    sql = <<-SQL
      SELECT *
      FROM courses
      WHERE department_id = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, department_id).map do |row|
      new_from_db(row)
    end
  end

  def add_student(student)
    student.add_course(self)
    # student.courses
    # student.save
    # binding.pry
  end

  def students
    sql = <<-SQL
      SELECT students.*
      FROM students
      JOIN registrations
      ON students.id = registrations.id
      JOIN courses
      ON courses.id = registrations.course_id
      WHERE students.id = ?
    SQL
      result = DB[:conn].execute(sql, self.id)
      result.map do |row|
        Course.new_from_db(row)
      end
  end

  def update
    sql = <<-SQL
      UPDATE courses
      SET name = ?, department_id = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, attributes, id)
  end

  def persisted?
    !!id
  end

  def save
    persisted? ? update : insert
  end

end
