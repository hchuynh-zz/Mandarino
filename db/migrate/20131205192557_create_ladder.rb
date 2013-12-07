class CreateLadder < ActiveRecord::Migration
  def up
    create_table :ladders do |t|
      t.integer :user_id
      t.integer :year
      t.integer :total
      t.integer :goal
      t.timestamps
    end
  end
 
  def down
    drop_table :ladders
  end
end


