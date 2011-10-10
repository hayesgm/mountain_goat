class Mg::Record < ActiveRecord::Base
  set_table_name :mg_records
  
  belongs_to :mg_goal, :class_name => "Mg::Goal"
  has_many :mg_goal_meta_types, :through => :mg_goal, :class_name => "Mg::GoalMetaType"
  #has_many :mg_gi_metas, :through => :mg_goal_meta_types
  #has_many :mg_gs_metas, :through => :mg_goal_meta_types

  #Set meta data for applicable options-- don't store nil data (waste of space)
  def set_meta_data(options)
    options.each do |option|
      gmt = self.mg_goal_meta_types.find_by_var(option[0].to_s)

      #Create cmt if it doesn't current exist (unless nil)
      if gmt.nil? && !option[1].nil? && ( option[1].is_a?(Integer) || option[1].is_a?(String) )
        #infer type
        meta_type = "gi_meta" if option[1].is_a?(Integer)
        meta_type = "gs_meta" if option[1].is_a?(String)
        gmt = mg_goal.mg_goal_meta_types.create!(:name => option[0].to_s, :var => option[0].to_s, :meta_type => meta_type)
      end
      
      if !gmt.nil? #only if we can do it
        gmt.meta.create!(:mg_record_id => self.id, :data => option[1]) if !option[1].nil?
      end
    end
  end
  
  def meta_for( var )
    gmt = self.mg_goal_meta_types.find_by_var( var.to_s )
    return nil if gmt.nil?
    m = gmt.meta.find_by_mg_record_id( self.id )
    return nil if m.nil?
    return m.data
  end
  
  def all_metas
    res = {}
    self.mg_goal_meta_types.each do |gmt|
      r = res.count
      begin
        if gmt.var =~ /(\w+)[_]id/i
          if Kernel.const_get($1.classify)
            item = Kernel.const_get($1.classify).find( self.meta_for( gmt.var ) )
            if item.respond_to?(:name)
              res.merge!({ $1 => item.name })
            elsif item.respond_to?(:title)
              res.merge!({ $1 => item.title })
            end
          end
        end
      rescue
    end
    
      res.merge!({ gmt.var => self.meta_for( gmt.var ) }) if res.count == r
    end
    
    res
  end
end
