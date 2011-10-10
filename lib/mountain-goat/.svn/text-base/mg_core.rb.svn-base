require File.join([File.dirname(__FILE__), 'switch_choice'])

module MgCore
  
  #Metric Tracking routes
  class << ActionController::Routing::Routes;self;end.class_eval do
    define_method :clear!, lambda {}
  end
  
  Mime::Type.register "application/xhtml+xml", :xhtml
  
  ActionController::Routing::Routes.draw do |map|
    map.namespace :mg do |mg|
      mg.mg '/mg', :controller => :goals, :action => :index, :path_prefix => ""
      mg.login '/login', :controller => :mountain_goat, :action => :login
      mg.login_create '/login/create', :controller => :mountain_goat, :action => :login_create
      mg.resources :choices
      mg.resources :goals, :has_many => [ :record ], :member => { :hide => :get, :unhide => :get }
      mg.resources :tests, :has_many => :choices, :member => { :hide => :get, :unhide => :get }
      mg.resources :records, :collection => { :new_records => :get }
      mg.resources :reports, :has_many => :report_items, :member => { :show_svg => :get, :hide => :get, :unhide => :get }
      mg.resources :report_items, :member => { :destroy => :get, :update => :post }, :collection => { :get_extra => :get }
      mg.resources :playground, :collection => { :test => :get }
      mg.new_records '/records/new', :controller => :records, :action => :new_records 
      mg.fresh_choices '/fresh-choices', :controller => :tests, :action => :fresh_choices
      mg.connect '/public/:file', :controller => :mountain_goat, :action => :fetch
    end
  end
  
  module Controller
  
    #This is just for testing
    def mg_rand(evaluate = false)
      return "(SELECT #{@mg_i.nil? ? 1 : @mg_i.to_f})" if defined?(MOUNTAIN_GOAT_TEST) && MOUNTAIN_GOAT_TEST
      evaluate ? rand.to_f : "RAND()"
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
    
    def mg_apply_strategy(test)
      case mg_strategy.downcase
        when 'e-greedy'
          logger.warn Mg::Choice.all(:order => "CASE WHEN served = 0 THEN 1 ELSE 0 END DESC, CASE WHEN #{mg_rand(true).to_f} < #{mg_epsilon.to_f} THEN #{mg_rand} ELSE CASE WHEN served = 0 THEN -1 ELSE reward / served END END DESC, #{mg_rand} DESC", :conditions => { :mg_test_id => test.id } )
          return Mg::Choice.first(:order => "CASE WHEN served = 0 THEN 1 ELSE 0 END DESC, CASE WHEN #{mg_rand(true).to_f} < #{mg_epsilon.to_f} THEN #{mg_rand} ELSE CASE WHEN served = 0 THEN -1 ELSE reward / served END END DESC, #{mg_rand} DESC", :conditions => { :mg_test_id => test.id } )
        when 'e-greedy-decreasing'
          return Mg::Choice.first(:order => "CASE WHEN served = 0 THEN 1 ELSE 0 END DESC,
                                                    CASE WHEN #{mg_rand(true).to_f} < #{mg_epsilon.to_f} / ( select sum(served) from mg_metric_variants where metric_id = #{ metric.id.to_i } ) THEN #{mg_rand} ELSE CASE WHEN served = 0 THEN -1 ELSE reward / served END END DESC,
                                                    #{mg_rand} DESC", :conditions => { :mg_test_id => test.id } ) # * log( ( select sum(served) from mg_metric_variants where metric_id = #{ metric.id.to_i } ) )
        when 'a/b'
          return Mg::Choice.first(:order => "#{mg_rand} DESC", :conditions => { :mg_test_id => test.id } )
        else
          raise "Invalid strategy #{mg_strategy}"
      end
    end
    
    def mg_storage 
      if @mg_storage.nil?
        @mg_storage = defined?(cookies) ? cookies : nil
        
        mg_yml = nil
        begin
          mg_yml = YAML::load(File.open("#{RAILS_ROOT}/config/mountain-goat.yml"))
        rescue
        end
        if mg_yml
          if mg_yml.has_key?(RAILS_ENV) && mg_yml[RAILS_ENV].has_key?('storage')
            uc = mg_yml[RAILS_ENV]['storage'].strip
            @mg_storage = ( uc == "cookies" && defined?(cookies) ) ? cookies : ( uc == "session" && defined?(session) ) ? session : nil
          elsif mg_yml.has_key?('settings') && mg_yml['settings'].has_key?('storage')
            uc = mg_yml['settings']['storage'].strip
            @mg_storage = ( uc == "cookies" && defined?(cookies) ) ? cookies : ( uc == "session" && defined?(session) ) ? session : nil
          end
        end
      end
      @mg_storage = {} if @mg_storage.nil? #'none'
      return @mg_storage
    end
    
    ######################
    #   Bandit Tracking  #
    ######################
  
    def bds(test_type, &block)
      raise ArgumentError, "Switch choice needs block" if !block_given?
      test = get_test( test_type, true )
      block.call(SwitchChoice.new( logger, test, nil ) )
      
      var = get_switch_choice( test_type )
      block.call(SwitchChoice.new( logger, test, var ) )
    end
    
    def bd(test_type, default, opts = {}, opt = nil)
      return get_choice(test_type, default, opts, opt)[:value]
    end
    
    def bdd(test_type, default, opts = {}, opt = nil)
      return get_choice(test_type, default, opts, opt)
    end
    
    #Legacy
    def sv(test_type, goal_type, &block)
      bds(test_type, &block)
    end
    
    def mv(test_type, goal_type, default, opts = {}, opt = nil)
      bd(test_type, default, opts, opt)
    end
    
    def mv_detailed(test_type, goal_type, default, opts = {}, opt = nil)
      bdd(test_type, default, opts, opt)  
    end
    
    #shorthand
    def rw(goal_type, reward, options = {})
      self.bandit_reward(goal_type, reward, options)
    end
    
    def rc(goal_type, options = {})
      self.bandit_reward(goal_type, 1, options)
    end
    
    def record_conversion(goal_type, options = {})
      self.bandit_reward(goal_type, 1, options)
    end
    
    #allows bandit_reward(goal, options)
    def bandit_reward(goal_type, reward, options = {})
      
      if reward.is_a?(Hash) #allow arguments bandit_reward(test, options)
        options = reward
        reward = 0
      end
      
      tests = {} #for user-defined metrics
      options = options.with_indifferent_access
      
      MountainGoat.get_meta_options.each do |k, v|
        if options.include?(k) && options[k]
          options.delete(k)
          res = v.call(self)
          options.merge!( res ) if !res.nil? && res.instance_of?(Hash)
        end
      end
      
      options.each do |k, v|
        if k.to_s =~ /^test_(\w+)$/i
          options.delete k
          tests.merge!({ $1, v })
        end
      end
      
      logger.warn "Recording goal #{goal_type.to_s} with options #{options.inspect}"
      
      goal = Mg::Goal.first( :conditions => { :goal_type => goal_type.to_s } )
      
      # Now, we just create the goal if we don't have one
      goal = Mg::Goal.create!( :goal_type => goal_type.to_s, :name => goal_type.to_s, :rewards_total => reward, :rewards_given => 1 ) if goal.nil?
      
      # First, let's tally for the goal itself
      goal.tally_reward_given( reward )
      
      # We need to see what meta information we should fill based on the goal type
      Mg::Record.create!( { :mg_goal_id => goal.id, :reward => reward } ).set_meta_data(options)
      
      # User-defined test tallies
      tests.each do |test_type, choice_id|
        t = Mg::Test.find_by_test_type(test_type)
        if t.nil?
          logger.warn "Missing user-defined test #{test_type}"
          next
        end
        
        c = t.choices.first( :conditions => { :id => choice_id } ) #make sure everything matches up
        
        if c.nil?
          logger.warn "Choice #{choice_id} not in choices for #{t.title}"
          next
        end
        
        logger.warn "Tallying goal #{goal.name} for #{t.title} - #{c.name} (#{c.value} - #{c.id})"
        c.tally_goal(goal, reward)
      end
      
      if !mg_storage.nil?
        #we just converted, let's tally each of our metrics (from cookies or session)
        Mg::Test.all.each do |test|
          test_sym = "test_#{test.test_type}".to_sym
          choice_sym = "test_#{test.test_type}_choice".to_sym
          
          value = mg_storage[test_sym]
          choice_id = mg_storage[choice_sym]
          
          #logger.warn "Value: #{metric_sym} - #{value}"
          #logger.warn "Value: #{metric_variant_sym} - #{variant_id}"
          
          if choice_id.blank? #the user just doesn't have this set
            #This is now common-case
            next
          end
          
          choice = Mg::Choice.first(:conditions => { :id => choice_id.to_i } )
          
          if choice.nil?
            logger.error "Choice #{choice_id} not in choices for #{test.title}"
            next
          end
          
          if choice.value != value
            logger.warn "Choice #{choice.name} values differ for test #{test.title}.  '#{choice.value}' != '#{value}'!"
          end
          
          logger.warn "Tallying goal #{goal.name} for #{test.title} - #{choice.name} (#{choice.value} - #{choice.id})"
          choice.tally_goal(goal, reward)
        end
      end
    end
    
    private
    
    #returns a map { :value => value, :choice_id => id }
    def get_choice(test_type, default, opts = {}, opt = nil)
      test_sym = "test_#{test_type}#{ opt.nil? ? "" : '_' + opt.to_s }".to_sym
      choice_sym = "test_#{test_type}_choice".to_sym
      
      #first, we'll check for a cookie value
      if !mg_storage.nil? && mg_storage[test_sym] && !mg_storage[test_sym].blank?
        #we have the cookie  
        choice_id = mg_storage[choice_sym]
        choice = Mg::Choice.first(:conditions => { :id => choice_id.to_i } )
        if !choice.nil?
          if choice.mg_test.tally_each_serve
            choice.tally_serve
          end
        else
          logger.warn "Serving test #{test_type} #{ opt.nil? ? "" : opt.to_s } without finding / tallying choice."
        end
        
        return { :value => mg_storage[test_sym], :choice_id => mg_storage[choice_sym] } #it's the best we can do
      else
        #we don't have the cookie, let's find a value to set
        test = get_test( test_type, false )
        
        choice = mg_apply_strategy(test)
        
        if choice.nil?
          logger.warn "Missing choices for #{test_type}"
          choice = Mg::Choice.create!( { :mg_test_id => test.id, :value => default, :name => default }.merge(opts) )
        end
        
        if choice.mg_test.tally_each_serve
          choice.tally_serve # denote we served this to a user
        end
        
        value = choice.read_attribute( opt.nil? ? :value : opt )
        logger.debug "Serving #{choice.name} (#{value}) for #{test_sym}"
        #good, we have a variant, let's store it in session
        
        if !mg_storage.nil?
          mg_storage[test_sym] = value #, :domain => WILD_DOMAIN
          mg_storage[choice_sym] = choice.id #, :domain => WILD_DOMAIN
        end
        
        return { :value => value, :choice_id => choice.id }
      end
    end
    
    def get_switch_choice(test_type)
      choice_sym = "test_#{test_type}_choice".to_sym
      
      #first, we'll check for a cookie selection
      if !mg_storage.nil? && mg_storage[choice_sym] && !mg_storage[choice_sym].blank?
        #we have the cookie
        
        choice_id = mg_storage[choice_sym]
        choice = Mg::Choice.first(:conditions => { :id => choice_id.to_i } )
        
        if !choice.nil?
          if choice.mg_test.tally_each_serve
            choice.tally_serve
          end
          
          return choice
          
        end
        
        #otherwise, it's a big wtf? let's just move on
        logger.warn "Missing choice for #{test_type} (switch-type), reassigning..."
      end
        
      #we don't have the cookie, let's find a value to set
      test = get_test( test_type, true )
      
      choice = mg_apply_strategy(test)
      
      if choice.nil?
        logger.warn "Missing choices for #{test_type}"
        raise ArgumentError, "Missing choices for switch-type #{test_type}"
      end
      
      if choice.mg_test.tally_each_serve
        choice.tally_serve # denote we served this to a user
      end
      
      logger.debug "Serving #{choice.name} (#{choice.switch_type}) for #{test.title} (switch-type)"
      #good, we have a variant, let's store it in session (not the value, just the selection)
      if !mg_storage.nil?
        mg_storage[choice_sym] = choice.id #, :domain => WILD_DOMAIN
      end
      
      return choice
    end
    
    def get_test(test_type, is_switch = false)
      
      test = Mg::Test.first(:conditions => { :test_type => test_type.to_s } )
      
      if test.nil? #we don't have a metric of this type
        logger.warn "Missing test type #{test_type.to_s} -- creating"
        test = Mg::Test.create( :test_type => test_type.to_s, :title => test_type.to_s, :is_switch => is_switch )
      end
      
      return test
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
  include MgCore::Controller
end

class ActionView::Base
  include MgCore::View
end

class ActionMailer::Base
  include MgCore::Controller  
end

class ActiveRecord::Base
  include MgCore::Controller  
end
