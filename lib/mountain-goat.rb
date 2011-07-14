
require 'rubygems'
require 'active_support'
require 'action_controller'
require 'action_controller/routing'

require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mountain_goat/mountain_goat_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mountain_goat/mountain_goat_metrics_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mountain_goat/mountain_goat_metric_variants_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mountain_goat/mountain_goat_converts_controller'])
require File.join([File.dirname(__FILE__), 'mountain-goat/controllers/mountain_goat/mountain_goat_rallies_controller'])

require File.join([File.dirname(__FILE__), 'mountain-goat/metric_tracking'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/metric'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/metric_variant'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/convert'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/convert_meta_type'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/cs_meta'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/ci_meta'])
require File.join([File.dirname(__FILE__), 'mountain-goat/models/rally'])

$VERBOSE = nil
Dir["#{Gem.searcher.find('mountain-goat').full_gem_path}/lib/tasks/*.rake"].each { |ext| load ext }

module MountainGoat
  
end
