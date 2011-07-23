class CreateMountainGoatTables < ActiveRecord::Migration

  def self.up
    create_table "ci_metas", :force => true do |t|
      t.integer  "rally_id"
      t.integer  "convert_meta_type_id"
      t.integer  "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    add_index "ci_metas", ["convert_meta_type_id", "data"], :name => "ci_metas_cmt_data_index"
    add_index "ci_metas", ["convert_meta_type_id"], :name => "ci_metas_cmt_index"
    add_index "ci_metas", ["rally_id"], :name => "ci_metas_rally_index"
    
    create_table "convert_meta_types", :force => true do |t|
      t.integer  "convert_id"
      t.string   "name"
      t.string   "var"
      t.string   "meta_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "converts", :force => true do |t|
      t.string   "convert_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
    end
  
    create_table "cs_metas", :force => true do |t|
      t.integer  "rally_id"
      t.integer  "convert_meta_type_id"
      t.string   "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    add_index "cs_metas", ["convert_meta_type_id", "data"], :name => "cs_metas_cmt_data_index"
    add_index "cs_metas", ["convert_meta_type_id"], :name => "cs_metas_cmt_index"
    add_index "cs_metas", ["rally_id"], :name => "cs_metas_rally_index"
    
    create_table "metric_variants", :force => true do |t|
      t.integer  "metric_id"
      t.text     "value"
      t.text     "opt1"
      t.text     "opt2"
      t.integer  "served",      :default => 0
      t.integer  "conversions", :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.float    "priority",    :default => 1.0, :null => false
      t.string   "switch_type"
    end
  
    create_table "metrics", :force => true do |t|
      t.string   "metric_type"
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "convert_id"
      t.boolean  "tally_each_serve", :default => true
      t.boolean  "is_switch",        :default => false
    end
    
    create_table "rallies", :force => true do |t|
      t.integer  "convert_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :ci_metas
    drop_table :convert_meta_types
    drop_table :converts
    drop_table :cs_metas
    drop_table :metric_variants
    drop_table :metrics
    drop_table :rallies
  end

end
