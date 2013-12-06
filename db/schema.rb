ActiveRecord::Schema.define(:version => 20131205192556) do

  create_table "timetables", :force => true do |t|
    t.text     "user_id",    :null => false
    t.integer  "day",    :null => false
    t.integer  "year",    :null => false
    t.integer  "today",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ladders", :force => true do |t|
    t.integer  "user_id", :null => false
    t.integer  "year",    :null => false
    t.integer  "total",    :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end