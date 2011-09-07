require File.join([File.dirname(__FILE__), 'switch_variant'])

module MetricTracking
  
  #Metric Tracking routes
  class << ActionController::Routing::Routes;self;end.class_eval do
    define_method :clear!, lambda {}
  end
  
  Mime::Type.register "application/xhtml+xml", :xhtml
  
  ActionController::Routing::Routes.draw do |map|
    map.namespace :mg do |mg|
      mg.mg '/mg', :controller => :converts, :action => :index, :path_prefix => ""
      mg.login '/login', :controller => :mountain_goat, :action => :login
      mg.login_create '/login/create', :controller => :mountain_goat, :action => :login_create
      mg.resources :metric_variants
      mg.resources :converts, :has_many => [ :rallies ]
      mg.resources :metrics, :has_many => :metric_variants
      mg.resources :rallies, :collection => { :new_rallies => :get }
      mg.resources :reports, :has_many => :report_items, :member => { :show_svg => :get }
      mg.resources :report_items, :member => { :destroy => :get, :update => :post }, :collection => { :get_extra => :get }
      mg.resources :playground, :collection => { :test => :get }
      mg.new_rallies '/rallies/new', :controller => :rallies, :action => :new_rallies 
      mg.fresh_metrics '/fresh-metrics', :controller => :metrics, :action => :fresh_metrics
      mg.connect '/public/:file', :controller => :mountain_goat, :action => :fetch
    end
  end
  
  module Controller
  
    #This is just for testing
    def mg_rand
      return "(SELECT #{@mg_i.nil? ? 1 : @mg_i.to_f})" if defined?(MOUNTAIN_GOAT_TEST) && MOUNTAIN_GOAT_TEST
      "RAND()"
    end
    
    def mg_epsilon
      if @mg_epsilon.nil?
        @mg_epsilon = 0.1 #default
        mg_yml = nil
        begin
          mg_yml = YAML::load(File.open("#{RAILS_ROOT}/config/mountain-goat.yml"))
        rescue
        end
        if mg_yml
          if mg_yml.has_key?(RAILS_ENV) && mg_yml[RAILS_ENV].has_key?('epsilon')
            @mg_epsilon = mg_yml[RAILS_ENV]['epsilon'].to_f
          elsif mg_yml.has_key?('settings') && mg_yml['settings'].has_key?('epsilon')
            @mg_epsilon = mg_yml['settings']['epsilon'].to_f
          end
        end
      end
      return @mg_epsilon
    end
    
    def mg_strategy 
      if @mg_strategy.nil?
        @mg_strategy = 'e-greedy' #default
        mg_yml = nil
        begin
          mg_yml = YAML::load(File.open("#{RAILS_ROOT}/config/mountain-goat.yml"))
        rescue
        end
        if mg_yml
          if mg_yml.has_key?(RAILS_ENV) && mg_yml[RAILS_ENV].has_key?('strategy')
            @mg_strategy = mg_yml[RAILS_ENV]['strategy']
          elsif mg_yml.has_key?('settings') && mg_yml['settings'].has_key?('strategy')
            @mg_strategy = mg_yml['settings']['strategy']
          end
        end
      end
      return @mg_strategy
    end
    
    def mg_apply_strategy(metric)
      case mg_strategy.downcase
        when 'e-greedy'
          logger.warn Mg::MetricVariant.all(:order => "CASE WHEN served = 0 THEN 1 ELSE 0 END DESC, CASE WHEN #{mg_rand} < #{mg_epsilon.to_f} THEN #{mg_rand} ELSE CASE WHEN served = 0 THEN -1 ELSE reward / served END END DESC, #{mg_rand} DESC", :conditions => { :metric_id => metric.id } )
          return Mg::MetricVariant.first(:order => "CASE WHEN served = 0 THEN 1 ELSE 0 END DESC, CASE WHEN #{mg_rand} < #{mg_epsilon.to_f} THEN #{mg_rand} ELSE CASE WHEN served = 0 THEN -1 ELSE reward / served END END DESC, #{mg_rand} DESC", :conditions => { :metric_id => metric.id } )
        when 'e-greedy-decreasing'
          return Mg::MetricVariant.first(:order => "CASE WHEN served = 0 THEN 1 ELSE 0 END DESC,
                                                    CASE WHEN #{mg_rand} < #{mg_epsilon.to_f} / ( select sum(served) from mg_metric_variants where metric_id = #{ metric.id.to_i } ) THEN #{mg_rand} ELSE CASE WHEN served = 0 THEN -1 ELSE reward / served END END DESC,
                                                    #{mg_rand} DESC", :conditions => { :metric_id => metric.id } ) # * log( ( select sum(served) from mg_metric_variants where metric_id = #{ metric.id.to_i } ) )
        when 'a/b'
          return Mg::MetricVariant.first(:order => "#{mg_rand} DESC", :conditions => { :metric_id => metric.id } )
        else
          raise "Invalid strategy #{mg_strategy}"
      end
    end
    
    def mg_storage
      return @fake_session if defined?(MOUNTAIN_GOAT_TEST) && MOUNTAIN_GOAT_TEST 
      
      if @use_cookies.nil?
        @use_cookies = true #default
        mg_yml = nil
        begin
          mg_yml = YAML::load(File.open("#{RAILS_ROOT}/config/mountain-goat.yml"))
        rescue
        end
        if mg_yml
          if mg_yml.has_key?(RAILS_ENV) && mg_yml[RAILS_ENV].has_key?('use_cookies')
            uc = mg_yml[RAILS_ENV]['use_cookies']
            @use_cookies = uc == true || uc == "true"
          elsif mg_yml.has_key?('settings') && mg_yml['settings'].has_key?('use_cookies')
            uc = mg_yml['settings']['use_cookies']
            @use_cookies = uc == true || uc == "true"
          end
        end
      end

      return defined?(cookies) ? cookies : nil if @use_cookies
      return defined?(session) ? session : nil
    end
    
    ######################
    #   Metric Tracking  #
    ######################
  
    def bds(metric_type, &block)
      raise ArgumentError, "Switch variant needs block" if !block_given?
      metric = get_metric( metric_type, true )
      block.call(SwitchVariant.new( logger, metric, nil ) )
      
      var = get_switch_metric_variant( metric_type )
      block.call(SwitchVariant.new( logger, metric, var ) )
    end
    
    def bd(metric_type, default, opts = {}, opt = nil)
      return get_metric_variant(metric_type, default, opts, opt)[:value]
    end
    
    def bdd(metric_type, default, opts = {}, opt = nil)
      return get_metric_variant(metric_type, default, opts, opt)
    end
    
    #Legacy
    def sv(metric_type, convert_type, &block)
      bds(metric_type, &block)
    end
    
    def mv(metric_type, convert_type, default, opts = {}, opt = nil)
      bd(metric_type, default, opts, opt)
    end
    
    def mv_detailed(metric_type, convert_type, default, opts = {}, opt = nil)
      bdd(metric_type, default, opts, opt)  
    end
    
    #shorthand
    def rw(convert_type, reward, options = {})
      self.bandit_reward(convert_type, reward, options)
    end
    
    def rc(convert_type, options = {})
      self.bandit_reward(convert_type, 1, options)
    end
    
    def record_conversion(convert_type, options = {})
      self.bandit_reward(convert_type, 1, options)
    end
    
    #allows bandit_reward(convert, options)
    def bandit_reward(convert_type, reward, options = {})
      
      if reward.is_a?(Hash) #allow arguments bandit_reward(convert, options)
        options = reward
        reward = 0
      end
      
      metrics = {} #for user-defined metrics
      options = options.with_indifferent_access
      
      MountainGoat.get_meta_options.each do |k, v|
        if options.include?(k) && options[k]
          options.delete(k)
          res = v.call(self)
          options.merge!( res ) if !res.nil? && res.instance_of?(Hash)
        end
      end
      
      options.each do |k, v|
        if k.to_s =~ /^metric_(\w+)$/i
          options.delete k
          metrics.merge!({ $1, v })
        end
      end
      
      logger.warn "Recording conversion #{convert_type.to_s} with options #{options.inspect}"
      
      convert = Mg::Convert.first( :conditions => { :convert_type => convert_type.to_s } )
      
      #now, we just create the convert if we don't have one
      convert = Mg::Convert.create!( :convert_type => convert_type.to_s, :name => convert_type.to_s, :reward => reward ) if convert.nil?
        
      #first, let's tally for the conversion itself
      #we need to see what meta information we should fill based on the conversion type
      Mg::Rally.create!( { :convert_id => convert.id } ).set_meta_data(options)
      
      #User-defined metric tallies
      metrics.each do |metric_type, variant_id|
        m = Mg::Metric.find_by_metric_type(metric_type)
        if m.nil?
          logger.warn "Missing user-defined metric #{metric_type}"
          next
        end
        
        v = m.metric_variants.first( :conditions => { :id => variant_id } ) #make sure everything matches up
        
        if v.nil?
          logger.warn "Variant #{variant_id} not in metric variants for #{m.title}"
          next
        end
        
        logger.warn "Tallying conversion #{convert.name} for #{m.title} - #{v.name} (#{v.value} - #{v.id})"
        v.tally_convert(convert, reward)
      end
      
      if !mg_storage.nil?
        #we just converted, let's tally each of our metrics (from cookies or session)
        Mg::Metric.all.each do |metric|
          metric_sym = "metric_#{metric.metric_type}".to_sym
          metric_variant_sym = "metric_#{metric.metric_type}_variant".to_sym
          
          value = mg_storage[metric_sym]
          variant_id = mg_storage[metric_variant_sym]
          
          #logger.warn "Value: #{metric_sym} - #{value}"
          #logger.warn "Value: #{metric_variant_sym} - #{variant_id}"
          
          if variant_id.blank? #the user just doesn't have this set
            #This is now common-case
            next
          end
          
          variant = Mg::MetricVariant.first(:conditions => { :id => variant_id.to_i } )
          
          if variant.nil?
            logger.error "Variant #{variant_id} not in metric variants for #{metric.title}"
            next
          end
          
          if variant.value != value
            logger.warn "Variant #{variant.name} values differ for metric #{metric.title}.  '#{variant.value}' != '#{value}'!"
          end
          
          logger.warn "Tallying conversion #{convert.name} for #{metric.title} - #{variant.name} (#{variant.value} - #{variant.id})"
          variant.tally_convert(convert, reward)
        end
      end
    end
    
    private
    
    #returns a map { :value => value, :variant_id => id }
    def get_metric_variant(metric_type, default, opts = {}, opt = nil)
      metric_sym = "metric_#{metric_type}#{ opt.nil? ? "" : '_' + opt.to_s }".to_sym
      metric_variant_sym = "metric_#{metric_type}_variant".to_sym
      
      #first, we'll check for a cookie value
      if !mg_storage.nil? && mg_storage[metric_sym] && !mg_storage[metric_sym].blank?
        #we have the cookie  
        variant_id = mg_storage[metric_variant_sym]
        variant = Mg::MetricVariant.first(:conditions => { :id => variant_id.to_i } )
        if !variant.nil?
          if variant.metric.tally_each_serve
            variant.tally_serve
          end
        else
          logger.warn "Serving metric #{metric_type} #{ opt.nil? ? "" : opt.to_s } without finding / tallying variant."
        end
        
        return { :value => mg_storage[metric_sym], :variant_id => mg_storage[metric_variant_sym] } #it's the best we can do
      else
        #we don't have the cookie, let's find a value to set
        metric = get_metric( metric_type, false )
        
        metric_variant = mg_apply_strategy(metric)
        
        if metric_variant.nil?
          logger.warn "Missing metric variants for #{metric_type}"
          metric_variant = Mg::MetricVariant.create!( { :metric_id => metric.id, :value => default, :name => default }.merge(opts) )
        end
        
        if metric_variant.metric.tally_each_serve
          metric_variant.tally_serve #donate we served this to a user
        end
        
        value = metric_variant.read_attribute( opt.nil? ? :value : opt )
        logger.debug "Serving #{metric_variant.name} (#{value}) for #{metric_sym}"
        #good, we have a variant, let's store it in session
        
        if !mg_storage.nil?
          mg_storage[metric_sym] = value #, :domain => WILD_DOMAIN
          mg_storage[metric_variant_sym] = metric_variant.id #, :domain => WILD_DOMAIN
        end
        
        return { :value => value, :variant_id => metric_variant.id }
      end
    end
    
    def get_switch_metric_variant(metric_type)
      metric_variant_sym = "metric_#{metric_type}_variant".to_sym
      
      #first, we'll check for a cookie selection
      if !mg_storage.nil? && mg_storage[metric_variant_sym] && !mg_storage[metric_variant_sym].blank?
        #we have the cookie
        
        variant_id = mg_storage[metric_variant_sym]
        variant = Mg::MetricVariant.first(:conditions => { :id => variant_id.to_i } )
        if !variant.nil?
        
          if variant.metric.tally_each_serve
            variant.tally_serve
          end
          
          return variant
          
        end
        
        #otherwise, it's a big wtf? let's just move on
        logger.warn "Missing metric variant for #{metric_type} (switch-type), reassigning..."
      end
        
      #we don't have the cookie, let's find a value to set
      metric = get_metric( metric_type, true )
      
      metric_variant = mg_apply_strategy(metric)
      
      if metric_variant.nil?
        logger.warn "Missing metric variants for #{metric_type}"
        raise ArgumentError, "Missing variants for switch-type #{metric_type}"
      end
      
      if metric_variant.metric.tally_each_serve
        metric_variant.tally_serve #donate we served this to a user
      end
      
      logger.debug "Serving #{metric_variant.name} (#{metric_variant.switch_type}) for #{metric.title} (switch-type)"
      #good, we have a variant, let's store it in session (not the value, just the selection)
      if !mg_storage.nil?
        mg_storage[metric_variant_sym] = metric_variant.id #, :domain => WILD_DOMAIN
      end
      
      return metric_variant
    end
    
    def get_metric(metric_type, is_switch = false)
      
      metric = Mg::Metric.first(:conditions => { :metric_type => metric_type.to_s } )
      
      if metric.nil? #we don't have a metric of this type
        logger.warn "Missing metric type #{metric_type.to_s} -- creating"
        metric = Mg::Metric.create( :metric_type => metric_type.to_s, :title => metric_type.to_s, :is_switch => is_switch )
      end
      
      return metric
    end
  end
  
  module View
    def mv(*args, &block)
      @controller.send(:mv, *args, &block)
    end
    
    def mv_detailed(*args, &block)
      @controller.send(:mv_detailed, *args, &block)
    end
    
    def sv(*args, &block)
      @controller.send(:sv, *args, &block)
    end
    
    def bd(*args, &block)
      @controller.send(:bd, *args, &block)
    end
    
    def bdd(*args, &block)
      @controller.send(:bdd, *args, &block)
    end
    
    def bds(*args, &block)
      @controller.send(:bds, *args, &block)
    end
  end
end

class ActionController::Base
  include MetricTracking::Controller
end

class ActionView::Base
  include MetricTracking::View
end

class ActionMailer::Base
  include MetricTracking::Controller  
end

class ActiveRecord::Base
  include MetricTracking::Controller  
end
