class Mg::Report < ActiveRecord::Base
  set_table_name :mg_reports
  
  has_many :report_items, :class_name => "Mg::ReportItem", :foreign_key => "report_id"
  has_many :reportables, :through => :report_items
  
  validates_presence_of :title
  validates_presence_of :delivery_set
  validates_presence_of :recipients
  
end
