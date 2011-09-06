class CreateMountainGoatTables < ActiveRecord::Migration

  def self.up
    create_table "mg_ci_metas", :force => true do |t|
      t.integer  "rally_id"
      t.integer  "convert_meta_type_id"
      t.integer  "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    add_index "mg_ci_metas", ["convert_meta_type_id", "data"], :name => "ci_metas_cmt_data_index"
    add_index "mg_ci_metas", ["convert_meta_type_id"], :name => "ci_metas_cmt_index"
    add_index "mg_ci_metas", ["rally_id"], :name => "ci_metas_rally_index"
  
    create_table "mg_convert_meta_types", :force => true do |t|
      t.integer  "convert_id"
      t.string   "name"
      t.string   "var"
      t.string   "meta_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "mg_converts", :force => true do |t|
      t.string   "convert_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.float    "reward",       :default => 1.0
    end
  
    create_table "mg_cs_metas", :force => true do |t|
      t.integer  "rally_id"
      t.integer  "convert_meta_type_id"
      t.string   "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    add_index "mg_cs_metas", ["convert_meta_type_id", "data"], :name => "cs_metas_cmt_data_index"
    add_index "mg_cs_metas", ["convert_meta_type_id"], :name => "cs_metas_cmt_index"
    add_index "mg_cs_metas", ["rally_id"], :name => "cs_metas_rally_index"
  
    create_table "mg_metric_variants", :force => true do |t|
      t.integer  "metric_id"
      t.text     "value"
      t.text     "opt1"
      t.text     "opt2"
      t.integer  "served",      :default => 0
      t.integer  "conversions", :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.string   "switch_type"
      t.float    "reward"
    end
  
    create_table "mg_metrics", :force => true do |t|
      t.string   "metric_type"
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "tally_each_serve", :default => true
      t.boolean  "is_switch",        :default => false
    end
  
    create_table "mg_rallies", :force => true do |t|
      t.integer  "convert_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "mg_report_items", :force => true do |t|
      t.integer  "report_id"
      t.integer  "reportable_id"
      t.string   "reportable_type"
      t.integer  "order"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "mg_reports", :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "delivery_set"
      t.string   "recipients"
    end
  end

  def self.down
    drop_table :mg_ci_metas
    drop_table :mg_convert_meta_types
    drop_table :mg_converts
    drop_table :mg_cs_metas
    drop_table :mg_metric_variants
    drop_table :mg_metrics
    drop_table :mg_rallies
    drop_table :mg_report_items
    drop_table :mg_reports
  end

end
