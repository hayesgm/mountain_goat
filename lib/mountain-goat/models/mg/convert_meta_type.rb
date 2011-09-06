class Mg::ConvertMetaType < ActiveRecord::Base
  set_table_name :mg_convert_meta_types
  
  belongs_to :convert, :class_name => "Mg::Convert"
  has_many :ci_metas, :class_name => 'CiMeta', :dependent => :destroy, :class_name => "Mg::CiMeta", :foreign_key => "convert_meta_type_id" 
  has_many :cs_metas, :class_name => 'CsMeta', :dependent => :destroy, :class_name => "Mg::CiMeta", :foreign_key => "convert_meta_type_id"
  
  validates_presence_of :name
  validates_presence_of :var
  validates_presence_of :meta_type
  
  def meta
    case self.meta_type
    when 'ci_meta'
      return self.ci_metas
    when 'cs_meta'
      return self.cs_metas
    end
  end
end
