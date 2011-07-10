class CsMeta < ActiveRecord::Base
  
  belongs_to :convert_meta_type
  belongs_to :rally
  
  validates_presence_of :convert_meta_type_id
  validates_presence_of :rally_id
  
end
