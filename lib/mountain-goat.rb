
require 'rubygems'
require 'active_support'
require 'action_controller'
require 'action_controller/routing'

require File.join([File.dirname(__FILE__), 'mgflotilla'])

require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mg/mg'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mg/mountain_goat_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mg/metrics_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mg/metric_variants_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mg/converts_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mg/rallies_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mg/reports_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mg/report_items_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mg/playground_controller'])

require File.join([File.dirname(__FILE__), 'mountain-goat/m_g'])
require File.join([File.dirname(__FILE__), 'mountain-goat/analytics'])
require File.join([File.dirname(__FILE__), 'mountain-goat/metric_tracking'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/mg/metric'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/mg/metric_variant'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/mg/convert'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/mg/convert_meta_type'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/mg/cs_meta'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/mg/ci_meta'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/mg/rally'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/mg/report'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/mg/report_mailer'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/mg/report_item'])

#$VERBOSE = nil
#Dir["#{Gem.searcher.find('mountain-goat').full_gem_path}/lib/tasks/*.rake"].each { |ext| load ext }

class MountainGoat
  def self.add_meta_option(option, &block)
    @@meta_options = {} if !defined?(@@meta_options)
    @@meta_options ||= {}
    @@meta_options.merge!({ option => block })
  end
  
  def self.get_meta_options
    return {} if !defined?(@@meta_options)
    @@meta_options || {}
  end 
end
