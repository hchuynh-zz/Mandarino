class CreateTimetable < ActiveRecord::Migration
  def up
  	create_table :timetables do |t|
  		t.string :name
  	end
  end
 
  def down
  	drop_table :timetables
  end
end

