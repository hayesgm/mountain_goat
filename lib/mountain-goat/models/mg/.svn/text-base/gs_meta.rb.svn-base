class Mg::GsMeta < ActiveRecord::Base
  set_table_name :mg_gs_metas
  
  belongs_to :mg_goal_meta_type, :class_name => "Mg::GoalMetaType"
  belongs_to :mg_record, :class_name => "Mg::Record"
  
  validates_presence_of :mg_goal_meta_type_id
  validates_presence_of :mg_record_id
  
end
