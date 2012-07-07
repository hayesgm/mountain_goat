# Mg::Goal represents a target for user interaction (E.g. Sign-up)
#
# Attributes
# goal_type:: A symbol uniquely identifying this goal type (for code interactions)
# name:: A name for this goal
# deleted_at:: Is this goal deleted? (MG Console)
# is_hidden:: Is this goal hidden? (MG Console)
class Mg::Goal < ActiveRecord::Base
  self.table_name = 'mg_goals'
  
  # ActiveRecord Associations
  has_many :mg_records, :class_name => "Mg::Record", :foreign_key => "mg_goal_id"
  has_many :mg_goal_meta_types, :class_name => "Mg::GoalMetaType", :foreign_key => "mg_goal_id"
  has_many :gi_metas, :through => :mg_goal_meta_types, :class_name => "Mg::GiMeta", :foreign_key => "mg_goal_id"
  has_many :gs_metas, :through => :mg_goal_meta_types, :class_name => "Mg::GsMeta", :foreign_key => "mg_goal_id"
  has_many :report_items, :as => :reportable, :class_name => "Mg::ReportItem"
  
  # Secondary Associations
  accepts_nested_attributes_for :mg_goal_meta_types, :reject_if => lambda { |a| a[:name].blank? || a[:var].blank? || a[:meta_type].blank? }, :allow_destroy => true
  
  # Validations
  validates_presence_of :name
  validates_format_of :goal_type, :with => /[a-z0-9_]{3,50}/i, :message => "must be between 3 and 30 characters, alphanumeric with underscores"
  validates_uniqueness_of :goal_type  
  
  # Member Functions
  
  # Helper function to retrieve a goal by symbol
  def self.by_type(s)
    Mg::Goal.find( :first, :conditions => { :goal_type => s.to_s } )
  end
  
  # Get all records for given meta (e.g. for "Referer": { "Youtube" => Record1, } ...)
  def records_for_meta(var)
    gmt = self.mg_goal_meta_types.find_by_var( var.to_s )
    return {} if gmt.nil?
    gmt.meta.map { |m| { m.data => m.record } }
  end
  
  # Get all records for a given meta value (e.g. for "Referer", "Facebook": [ Record1, Record2, Record3 ] ) 
  def records_for_meta_val(var, data)
    gmt = self.mg_goal_meta_types.find_by_var( var.to_s )
    return [] if gmt.nil?
    gmt.meta.find(:all, :conditions => { :data => data } ).map { |m| m.record }
  end
  
  # Get all records pivoted by given meta (e.g. "Youtube" => [ Date, Date, Date ], "Facebook" => [ Date, Date, Date ])
  def records_pivot(pivot)
    res = {}
    gmt_pivot = self.mg_goal_meta_types.find_by_var( pivot.to_s )
    return {} if gmt_pivot.nil?
    gmt_pivot.meta.map { |c| { :created_at => c.created_at, :pivot => c.data } }.each do |c|
      if !res.include?(c[:pivot])
        res[c[:pivot]] = []
      end
      
      res[c[:pivot]].push c[:created_at]
    end
    
    res.each { |k,v| v.sort! }
    res
  end
  
  def records_for_meta_val_pivot(var, data, pivot)
    res = {}
    gmt = self.mg_goal_meta_types.find_by_var( var.to_s )
    gmt_pivot = self.mg_goal_meta_types.find_by_var( pivot.to_s )
    return {} if gmt.nil? || gmt_pivot.nil?
    gmt.meta.find(:all, :select => "`#{gmt.meta.table_name}`.created_at, gm.data AS pivot", :conditions => { :data => data }, :joins => "LEFT JOIN `#{gmt_pivot.meta.table_name}` gm ON gm.mg_goal_meta_type_id = #{gmt_pivot.id} AND gm.mg_record_id = `#{gmt.meta.table_name}`.mg_record_id").each do |c|
      if !res.include?(c.pivot)
        res[c.pivot] = []
      end
      
      res[c.pivot].push c.created_at
    end
    
    res.each { |k,v| v.sort! }
    res
  end
  
  # Pivot by given meta data by value (TODO: Document better)
  def records_for_meta_val_pivot_item(var, data, pivot, item)
    res = {}
    gmt = self.mg_goal_meta_types.find_by_var( var.to_s )
    gmt_pivot = self.mg_goal_meta_types.find_by_var( pivot.to_s )
    gmt_item = self.mg_goal_meta_types.find_by_var( item.to_s )
    return {} if gmt.nil? || gmt_pivot.nil? || gmt_item.nil?
    gmt.meta.find(:all, :select => "`#{gmt.meta.table_name}`.created_at, gm.data AS pivot, gi.data as item", :conditions => { :data => data }, :joins => "LEFT JOIN `#{gmt_pivot.meta.table_name}` gm ON gm.mg_goal_meta_type_id = #{gmt_pivot.id} AND gm.mg_record_id = `#{gmt.meta.table_name}`.mg_record_id LEFT JOIN `#{gmt_item.meta.table_name}` gi ON gi.mg_goal_meta_type_id = #{gmt_item.id} AND gi.mg_record_id = `#{gmt.meta.table_name}`.mg_record_id").each do |c|
      if !res.include?(c.pivot)
        res[c.pivot] = []
      end
      
      if gmt_item.meta_type == 'gi_meta'
        c.item.to_i.times { res[c.pivot].push c.created_at }
      else
        res[c.pivot].push c.created_at if c.item == 'yes' #what else?
      end
    end
    
    res.each { |k,v| v.sort! }
    res.delete_if { |k,v| v.count == 0 }
    res
  end
  
  # Get recent records based on start date
  def recent_records(time_frame)
    self.mg_records.find( :all, :conditions => [ "CREATED_AT > ?", time_frame.ago ] )  
  end
  
  # Tally we have given a reward
  def tally_reward_given( reward )
    self.transaction do
      self.update_attribute(:rewards_total, 0) if self.rewards_total.nil? #we should merge this with the next line, but whatever
      Mg::Goal.update_counters(self.id, :rewards_given => 1)
      Mg::Goal.update_counters(self.id, :rewards_total => reward)
    end
    
    return self.reload
  end
  
  #For Reportable
  
  # Title in report charts
  def reportable_title(pivot)
    if pivot.nil?
      return self.name
    elsif pivot.instance_of?(Mg::GoalMetaType)
      return "#{self.name} by #{pivot.name}"
    end
  end
  
  # 
  def reportable_chart_items(pivot)
    #let's look for pageviews by day by source
    #rallies_for_meta_val( :clique_id, @clique.id )
    #logger.debug "sources: #{sources.inspect}"
    #We now have a map of { source => [ date1, date2, ... ], ... }
    
    #Now, we just need to insert missing data (and group)
    #Let's transpose that into { source => [ :x => day0, y => count ] }
    if pivot.nil?
      return Analytics.pivot_by_date( { :"Records" => self.mg_records.map { |r| r.created_at } }, self.created_at )
    elsif pivot.instance_of?(Mg::GoalMetaType)
      sources = self.records_pivot( pivot.var )
      logger.warn "sources: #{sources}"
      return Analytics.pivot_by_date(sources, self.created_at)
    end
  end
  
  # 
  def reportable_gerbil_chart(pivot)
    #chart = GerbilCharts::Charts::LineChart.new( :width => 350, :height => 200, :style => 'brushmetal.css', :circle_data_points => true )
    
    if pivot.nil?
      data = Analytics.pivot_by_date( { :"Records" => self.mg_records.map { |r| r.created_at } }, self.created_at )
    elsif pivot.instance_of?(Mg::GoalMetaType)
      sources = self.records_pivot( pivot.var )
      data = Analytics.pivot_by_date(sources, self.created_at)
    end
    #logger.warn "data: #{data.inspect}"
    #logger.warn "ts: #{data.map { |line| line[1].map { |d| d[:x] }.to_a }[0].inspect}"
    #logger.warn "val: #{data.map { |line| [ line[0] ] + line[1].map { |d| d[:y] }.to_a }[0].inspect}"
    #chart.modelgroup = GerbilCharts::Models::SimpleTimeSeriesModelGroup.new(
    #    :title => "Rallies",
    #    :timeseries  =>  data.map { |line| line[1].map { |d| d[:x].to_time }.to_a }[0],
    #    :models => data.map { |line| [ line[0].to_s ] + line[1].map { |d| d[:y] }.to_a }
    #)
    #fields = { }
    #fields_simple = []
    #fields.merge!({ d[:x].to_time.to_i => d[:x].to_s } ); fields_simple.push(d[:x])
    graph = SVG::Graph::TimeSeries.new( :height => 350, :width => 700, :show_data_labels => false, :x_label_format => "%m/%d/%y", :graph_title => self.reportable_title(pivot), :show_graph_title => true, :show_data_values => false, :show_data_points => false, :area_fill => true )
    data.each do |line|
      res = []
      line[1].each { |d| res.push(d[:x].strftime('%m/%d/%y')).push(d[:y]) }
      graph.add_data :data => res, :title => line[0].to_s
    end
    
    #logger.warn "Fields: #{fields.inspect}"
    #logger.warn "Fields Simple: #{fields_simple.inspect}"
        
    graph
  end
end
