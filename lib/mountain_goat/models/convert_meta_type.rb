class ConvertMetaType < ActiveRecord::Base
  
  belongs_to :convert
  has_many :ci_metas, :class_name => 'CiMeta', :dependent => :destroy 
  has_many :cs_metas, :class_name => 'CsMeta', :dependent => :destroy
  
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
