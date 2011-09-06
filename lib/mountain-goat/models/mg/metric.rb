class Mg::Metric < ActiveRecord::Base
  set_table_name :mg_metrics
  
  has_many :metric_variants, :class_name => "Mg::MetricVariant", :foreign_key => "metric_id"
  
  validates_format_of :metric_type, :with => /[a-z0-9_]{3,50}/i, :message => "must be between 3 and 30 characters, alphanumeric with underscores"
  validates_uniqueness_of :metric_type
end
