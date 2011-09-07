class Mg::Convert < ActiveRecord::Base
  set_table_name :mg_converts
  
  has_many :rallies, :class_name => "Mg::Rally", :foreign_key => "convert_id"
  has_many :convert_meta_types, :class_name => "Mg::ConvertMetaType", :foreign_key => "convert_id"
  has_many :ci_metas, :through => :convert_meta_types, :class_name => "Mg::CiMeta", :foreign_key => "convert_id"
  has_many :cs_metas, :through => :convert_meta_types, :class_name => "Mg::CsMeta", :foreign_key => "convert_id"
  has_many :report_items, :as => :reportable, :class_name => "Mg::ReportItem"
  
  validates_presence_of :name
  validates_format_of :convert_type, :with => /[a-z0-9_]{3,50}/i, :message => "must be between 3 and 30 characters, alphanumeric with underscores"
  validates_uniqueness_of :convert_type  
  
  accepts_nested_attributes_for :convert_meta_types, :reject_if => lambda { |a| a[:name].blank? || a[:var].blank? || a[:meta_type].blank? }, :allow_destroy => true
  
  def self.by_type(s)
    Mg::Convert.find( :first, :conditions => { :convert_type => s.to_s } )
  end
  
  def rallies_for_meta(var)
    cmt = self.convert_meta_types.find_by_var( var.to_s )
    return {} if cmt.nil?
    cmt.meta.map { |m| { m.data => m.rally } }
  end
  
  def rallies_for_meta_val(var, data)
    cmt = self.convert_meta_types.find_by_var( var.to_s )
    return [] if cmt.nil?
    cmt.meta.find(:all, :conditions => { :data => data } ).map { |m| m.rally }
  end
  
  def rallies_pivot(pivot)
    res = {}
    cmt_pivot = self.convert_meta_types.find_by_var( pivot.to_s )
    return {} if cmt_pivot.nil?
    cmt_pivot.meta.map { |c| { :created_at => c.created_at, :pivot => c.data } }.each do |c|
      if !res.include?(c[:pivot])
        res[c[:pivot]] = []
      end
      
      res[c[:pivot]].push c[:created_at]
    end
    
    res.each { |k,v| v.sort! }
    res
  end
  
  def rallies_for_meta_val_pivot(var, data, pivot)
    res = {}
    cmt = self.convert_meta_types.find_by_var( var.to_s )
    cmt_pivot = self.convert_meta_types.find_by_var( pivot.to_s )
    return {} if cmt.nil? || cmt_pivot.nil?
    cmt.meta.find(:all, :select => "`#{cmt.meta.table_name}`.created_at, cm.data AS pivot", :conditions => { :data => data }, :joins => "LEFT JOIN `#{cmt_pivot.meta.table_name}` cm ON cm.convert_meta_type_id = #{cmt_pivot.id} AND cm.rally_id = `#{cmt.meta.table_name}`.rally_id").each do |c|
      if !res.include?(c.pivot)
        res[c.pivot] = []
      end
      
      res[c.pivot].push c.created_at
    end
    
    res.each { |k,v| v.sort! }
    res
  end
  
  def rallies_for_meta_val_pivot_item(var, data, pivot, item)
    res = {}
    cmt = self.convert_meta_types.find_by_var( var.to_s )
    cmt_pivot = self.convert_meta_types.find_by_var( pivot.to_s )
    cmt_item = self.convert_meta_types.find_by_var( item.to_s )
    return {} if cmt.nil? || cmt_pivot.nil? || cmt_item.nil?
    cmt.meta.find(:all, :select => "`#{cmt.meta.table_name}`.created_at, cm.data AS pivot, ci.data as item", :conditions => { :data => data }, :joins => "LEFT JOIN `#{cmt_pivot.meta.table_name}` cm ON cm.convert_meta_type_id = #{cmt_pivot.id} AND cm.rally_id = `#{cmt.meta.table_name}`.rally_id LEFT JOIN `#{cmt_item.meta.table_name}` ci ON ci.convert_meta_type_id = #{cmt_item.id} AND ci.rally_id = `#{cmt.meta.table_name}`.rally_id").each do |c|
      if !res.include?(c.pivot)
        res[c.pivot] = []
      end
      
      if cmt_item.meta_type == 'ci_meta'
        c.item.to_i.times { res[c.pivot].push c.created_at }
      else
        res[c.pivot].push c.created_at if c.item == 'yes' #what else?
      end  
    end
    
    res.each { |k,v| v.sort! }
    res.delete_if { |k,v| v.count == 0 }
    res
  end
  
  #For Reportable
  
  def reportable_title(pivot)
    if pivot.nil?
      return self.name
    elsif pivot.instance_of?(Mg::ConvertMetaType)
      return "#{self.name} by #{pivot.name}"
    end
  end
  
  def reportable_chart_items(pivot)
    #let's look for pageviews by day by source
    #rallies_for_meta_val( :clique_id, @clique.id )
    #logger.debug "sources: #{sources.inspect}"
    #We now have a map of { source => [ date1, date2, ... ], ... }
    
    #Now, we just need to insert missing data (and group)
    #Let's transpose that into { source => [ :x => day0, y => count ] }
    if pivot.nil?
      return Analytics.pivot_by_date( { :"Rallies" => self.rallies.map { |r| r.created_at } }, self.created_at )
    elsif pivot.instance_of?(Mg::ConvertMetaType)
      sources = self.rallies_pivot( pivot.var )
      logger.warn "sources: #{sources}"
      return Analytics.pivot_by_date(sources, self.created_at)
    end
  end
  
  def reportable_gerbil_chart(pivot)
    #chart = GerbilCharts::Charts::LineChart.new( :width => 350, :height => 200, :style => 'brushmetal.css', :circle_data_points => true )
    
    if pivot.nil?
      data = Analytics.pivot_by_date( { :"Rallies" => self.rallies.map { |r| r.created_at } }, self.created_at )
    elsif pivot.instance_of?(Mg::ConvertMetaType)
      sources = self.rallies_pivot( pivot.var )
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
