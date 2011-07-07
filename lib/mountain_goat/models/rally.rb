class Rally < ActiveRecord::Base
  
  belongs_to :convert
  has_many :convert_meta_types, :through => :convert
  #has_many :ci_metas, :through => :convert_meta_types
  #has_many :cs_metas, :through => :convert_meta_types

  #Set meta data for applicable options-- don't store nil data (waste of space)
  def set_meta_data(options)
    options.each do |option|
      cmt = convert_meta_types.find_by_var(option[0].to_s)

      #Create cmt if it doesn't current exist (unless nil)
      if cmt.nil? && !option[1].nil?
        #infer type
        meta_type = "ci_meta" if option[1].is_a?(Integer)
        meta_type = "cs_meta" if option[1].is_a?(String)
        cmt = convert.convert_meta_types.create!(:name => option[0].to_s, :var => option[0].to_s, :meta_type => meta_type)
      end
      
      cmt.meta.create!(:rally_id => self.id, :data => option[1]) if !option[1].nil?
    end
  end
  
  def meta_for( var )
    cmt = convert_meta_types.find_by_var( var.to_s )
    return nil if cmt.nil?
    m = cmt.meta.find_by_rally_id( self.id )
    return nil if m.nil?
    return m.data
  end
end
