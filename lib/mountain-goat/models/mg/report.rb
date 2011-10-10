class Mg::Report < ActiveRecord::Base
  set_table_name :mg_reports
  
  has_many :mg_report_items, :class_name => "Mg::ReportItem", :foreign_key => "mg_report_id"
  has_many :reportables, :through => :mg_report_items
  
  validates_presence_of :title
  validates_presence_of :delivery_set #can be nil
  #validates_presence_of :recipients
  
end
