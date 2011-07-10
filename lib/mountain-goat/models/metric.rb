class Metric < ActiveRecord::Base
  
  has_many :metric_variants
  belongs_to :convert
  
  validates_presence_of :convert_id
  
  validates_format_of :metric_type, :with => /[a-z0-9_]{3,50}/i, :message => "must be between 3 and 30 characters, alphanumeric with underscores"
  validates_uniqueness_of :metric_type
end
