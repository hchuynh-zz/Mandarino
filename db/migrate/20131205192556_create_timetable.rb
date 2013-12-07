class CreateTimetable < ActiveRecord::Migration
  def up
    create_table :timetables do |t|
      t.integer :user_id
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