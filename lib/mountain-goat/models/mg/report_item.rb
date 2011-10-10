class Mg::ReportItem < ActiveRecord::Base
  set_table_name :mg_report_items
  
  belongs_to :mg_report, :class_name => "Mg::Report", :foreign_key => "mg_report_id"
  belongs_to :reportable, :polymorphic => true
  belongs_to :pivot, :polymorphic => true
  
  validates_presence_of :mg_report_id
  validates_presence_of :reportable_id
  validates_presence_of :reportable_type
  validates_presence_of :order
  
  def chart_title
    return self.reportable.reportable_title(pivot)
  end
  
  def chart_items
    return self.reportable.reportable_chart_items(self.pivot)
  end
  
  def gerbil_chart
    return self.reportable.reportable_gerbil_chart(self.pivot)
  end
end
