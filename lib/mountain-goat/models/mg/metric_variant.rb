class Mg::MetricVariant < ActiveRecord::Base
  set_table_name :mg_metric_variants
  
  belongs_to :metric, :class_name => "Mg::Metric"
  
  validates_presence_of :name
  validates_presence_of :metric_id
  
  def tally_serve
    self.update_attribute(:reward, 0) if self.reward.nil? #we should merge this with the next line, but whatever
    Mg::MetricVariant.update_counters(self.id, :served => 1)
    self.reload
  end
  
  #reward has a "default" or adjustable setting
  def tally_convert(convert, reward = nil)
    Mg::MetricVariant.update_counters(self.id, :conversions => 1, :reward => reward.nil? ? convert.reward : reward)
    self.reload
  end
  
  def conversion_rate
    return nil if self.served == 0
    return self.conversions / self.served.to_f * 100
  end
end
