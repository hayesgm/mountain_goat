class Mg::CiMeta < ActiveRecord::Base
  set_table_name :mg_ci_metas
  
  belongs_to :convert_meta_type, :class_name => "Mg::ConvertMetaType"
  belongs_to :rally, :class_name => "Mg::Rally"
  
  validates_presence_of :convert_meta_type_id
  validates_presence_of :rally_id
  
end
