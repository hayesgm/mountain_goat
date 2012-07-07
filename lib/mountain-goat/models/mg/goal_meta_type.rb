class Mg::GoalMetaType < ActiveRecord::Base
  self.table_name = 'mg_goal_meta_types'
  
  belongs_to :mg_goal, :class_name => "Mg::Goal"
  has_many :gi_metas, :dependent => :destroy, :class_name => "Mg::GiMeta", :foreign_key => "mg_goal_meta_type_id" 
  has_many :gs_metas, :dependent => :destroy, :class_name => "Mg::GsMeta", :foreign_key => "mg_goal_meta_type_id"
  
  validates_presence_of :name
  validates_presence_of :var
  validates_presence_of :meta_type
  
  def meta
    case self.meta_type
    when 'gi_meta', 'ci_meta'
      return self.gi_metas
    when 'gs_meta', 'cs_meta'
      return self.gs_metas
    end
  end
end
