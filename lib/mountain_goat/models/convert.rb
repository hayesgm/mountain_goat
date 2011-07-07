class Convert < ActiveRecord::Base
  
  has_many :metrics
  has_many :rallies
  has_many :convert_meta_types
  has_many :ci_metas, :through => :convert_meta_types
  has_many :cs_metas, :through => :convert_meta_types
  
  validates_presence_of :name
  validates_format_of :convert_type, :with => /[a-z0-9_]{3,50}/i, :message => "must be between 3 and 30 characters, alphanumeric with underscores"
  validates_uniqueness_of :convert_type  
  
  accepts_nested_attributes_for :convert_meta_types, :reject_if => lambda { |a| a[:name].blank? || a[:var].blank? || a[:meta_type].blank? }, :allow_destroy => true
  
  def self.by_type(s)
    Convert.find( :first, :conditions => { :convert_type => s.to_s } )
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
end
