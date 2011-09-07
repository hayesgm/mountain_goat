$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
gem 'actionpack', '=2.3.11'
gem 'actionmailer', '=2.3.11'
gem 'activesupport', '=2.3.11'
gem 'activerecord', '=2.3.11'
require 'active_support'
require 'action_controller'
require 'action_controller/routing'
require 'action_mailer'
require 'active_record'
require 'active_record/fixtures'
#require 'test_help'
require 'active_support/core_ext/kernel/requires'
require 'active_support/test_case'
require 'action_controller/test_case'
#require 'action_dispatch/testing/integration'
require 'active_record/test_case'
require 'active_support/values/time_zone'
require 'test/unit'

require 'mountain-goat'

MOUNTAIN_GOAT_TEST = true
RAILS_ROOT = File.join(File.dirname(__FILE__), '..', '..', '..', '..')
RAILS_ENV = 'test'

#Fake a lot of RAILS junk
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.configurations = { 'me' => { 'adapter' => 'sqlite3', 'database' => ":memory:" } }
LOGGER = Logger.new('log/mountain-goat-test.log')
ActiveRecord::Base.logger = LOGGER
ActionController::Base.logger = LOGGER
Time.zone_default = Time.__send__(:get_zone, 'Central Time (US & Canada)')
ActionMailer::Base.delivery_method = :test

ActiveRecord::Schema.define(:version => 1) do
  create_table "mg_ci_metas", :force => true do |t|
    t.integer  "rally_id"
    t.integer  "convert_meta_type_id"
    t.integer  "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mg_ci_metas", ["convert_meta_type_id", "data"], :name => "ci_metas_cmt_data_index"
  add_index "mg_ci_metas", ["convert_meta_type_id"], :name => "ci_metas_cmt_index"
  add_index "mg_ci_metas", ["rally_id"], :name => "ci_metas_rally_index"
  
  create_table "mg_convert_meta_types", :force => true do |t|
    t.integer  "convert_id"
    t.string   "name"
    t.string   "var"
    t.string   "meta_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mg_converts", :force => true do |t|
    t.string   "convert_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.float    "reward",       :default => 1.0
    t.datetime "deleted_at"
  end

  create_table "mg_cs_metas", :force => true do |t|
    t.integer  "rally_id"
    t.integer  "convert_meta_type_id"
    t.string   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mg_cs_metas", ["convert_meta_type_id", "data"], :name => "cs_metas_cmt_data_index"
  add_index "mg_cs_metas", ["convert_meta_type_id"], :name => "cs_metas_cmt_index"
  add_index "mg_cs_metas", ["rally_id"], :name => "cs_metas_rally_index"
  
  create_table "mg_metric_variants", :force => true do |t|
    t.integer  "metric_id"
    t.text     "value"
    t.text     "opt1"
    t.text     "opt2"
    t.integer  "served",      :default => 0
    t.integer  "conversions", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "switch_type"
    t.float    "reward"
    t.datetime "deleted_at"
  end

  create_table "mg_metrics", :force => true do |t|
    t.string   "metric_type"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "tally_each_serve", :default => true
    t.boolean  "is_switch",        :default => false
    t.datetime "deleted_at"
  end
  
  create_table "mg_rallies", :force => true do |t|
    t.integer  "convert_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "mg_report_items", :force => true do |t|
      t.integer  "report_id"
      t.integer  "reportable_id"
      t.string   "reportable_type"
      t.integer  "order"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "pivot_type"
      t.integer  "pivot_id"
      t.string   "filter"
      t.string   "meta_type"
      t.integer  "meta_id"
    end
  
    create_table "mg_reports", :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "delivery_set"
      t.string   "recipients"
      t.datetime "deleted_at"
    end
end

#ActiveSupport::TestCase.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
#tables = Dir["#{fixture_dir}/*.yml"]
#tables.collect! {|t| File.basename(t, '.yml')}
#Fixtures.create_fixtures(fixture_dir, tables)

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  #self.use_instantiated_fixtures = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  self.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
  fixtures :mg_ci_metas, :mg_convert_meta_types, :mg_converts, :mg_cs_metas, :mg_metric_variants, :mg_metrics, :mg_rallies, :mg_report_items, :mg_reports
  set_fixture_class( { :mg_ci_metas => Mg::CiMeta, :mg_convert_meta_types => Mg::ConvertMetaType, :mg_converts => Mg::Convert, :mg_cs_metas => Mg::CsMeta, :mg_metric_variants => Mg::MetricVariant, :mg_metrics => Mg::Metric, :mg_rallies => Mg::Rally, :mg_report_items => Mg::ReportItem, :mg_reports => Mg::Report } )
  
  def logger
    LOGGER
  end
  
  # Add more helper methods to be used by all tests here...
  def logged_in
    { :mg_access => true }
  end
  
  def get_file_as_string(filename)
    data = ''
    f = File.open(filename, "r") 
    f.each_line do |line|
      data += line
    end
    return data
  end
  
end