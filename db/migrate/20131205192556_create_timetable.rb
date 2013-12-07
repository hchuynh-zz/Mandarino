class CreateTimetable < ActiveRecord::Migration
  def up
    create_table :timetables do |t|
      t.string :user_id
      t.integer :day
      t.integer :year
      t.integer :today
      t.timestamps
    end
  end
 
  def down
    drop_table :timetables
  end
end

class CreateLadder < ActiveRecord::Migration
  def up
    create_table :ladders do |t|
      t.string :user_id
      t.integer :day
      t.integer :year
      t.integer :total
      t.timestamps
    end
  end
 
  def down
    drop_table :ladders
  end
end


