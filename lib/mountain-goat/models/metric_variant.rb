class MetricVariant < ActiveRecord::Base
  
  belongs_to :metric
  
  validates_presence_of :name
  validates_presence_of :metric_id
  
  def tally_serve(count = 1)
    MetricVariant.update_counters(self.id, :served => count)
    self.reload
  end
  
  def tally_convert(count = 1)
    MetricVariant.update_counters(self.id, :conversions => count)
    self.reload
  end
  
  def conversion_rate
    return nil if self.served == 0
    return self.conversions / self.served.to_f * 100
  end
end
