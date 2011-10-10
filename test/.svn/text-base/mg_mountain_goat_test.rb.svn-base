require File.join(File.dirname(__FILE__), 'test_helper')

class Mg::MountainGoatTest < ActiveRecord::TestCase
  include MetricTracking::Controller
  
  class FakeSession
    
    def []=(key, value)
      @data = {}.with_indifferent_access if @data.nil?
      @data[key] = value.is_a?(Hash) ? value[:value] : value
    end
    
    def [](key)
      return @data[key] if !@data.nil? && @data.has_key?(key)
      return nil
    end
  end
  
  test "mountain goat tests" do
    @mg_strategy = 'e-greedy'
    @mg_storage = FakeSession.new
    
    #Let's start by adding a few tests, checking to see if storage is correct
    assert_equal 'a', bd(:test, 'a')
    assert_equal 'a', bd(:test, 'a')
    metric = Mg::Metric.find_by_metric_type(:test.to_s)
    a = metric.metric_variants.find_by_name('a')
    assert_equal 1, metric.metric_variants.count
    assert_equal 2, a.served
    assert_equal a.id, @mg_storage[:metric_test_variant]
    assert_equal 0, a.reward
    
    rw(:jimbo, 10) #score a reward
    a.reload
    assert_equal 10, a.reward
    assert_equal 1, a.conversions
    rw(:jimbo, 20) #score a reward
    a.reload
    assert_equal 30, a.reward
    assert_equal 2, a.conversions
    
    metric.metric_variants.create!( :value => 'b', :name => 'b' )
    b = metric.metric_variants.find_by_name('b')
    
    assert_equal 2, metric.metric_variants.count
    assert_nil b.reward
    
    #This is coming from session - let's test "tally each serve"
    metric.update_attribute(:tally_each_serve, false)
    metric.reload
    
    assert_equal 'a', bd(:test, 'a')
    a.reload
    assert_equal 2, a.served #this comes from "tally each serve"
    assert_equal 30, a.reward
    
    metric.update_attribute(:tally_each_serve, true)
    metric.reload
    assert_equal 'a', bd(:test, 'a')
    a.reload
    
    assert_equal 3, a.served
    assert_equal 30, a.reward
    @mg_storage = FakeSession.new #clear "session"
    
    b.reload
    assert_equal 0, b.served #Let's see if b gets served since it has zero
    #when random comes into play, it's going to be hard to test, so let's stray away
    
    assert_equal 'b', bd(:test, 'a') #this should serve b since it has a reward of 0 and a has a reward of 30
    b.reload
    assert_equal 1, b.served
    assert_equal 0, b.reward
    assert_equal 0, b.conversions
    
    #Let's just check repeats
    assert_equal 'b', bd(:test, 'a')
    b.reload
    assert_equal 2, b.served
    assert_equal 0, b.reward
    assert_equal 0, b.conversions
    
    @mg_storage = FakeSession.new #clear "session"
    
    #We should still get a since it's the winner
    assert_equal 'a', bd(:test, 'a')
    a.reload
    assert_equal 4, a.served
    assert_equal 30, a.reward
    assert_equal 2, a.conversions
    
    #Since we can't get b served without fudging (later), let's make a new variant
    metric.metric_variants.create!( :value => 'c', :name => 'c' )
    c = metric.metric_variants.find_by_name('c')
    
    #Let's just check repeats
    assert_equal 'a', bd(:test, 'a')
    a.reload
    assert_equal 5, a.served
    assert_equal 30, a.reward
    assert_equal 2, a.conversions
    
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')
    c.reload
    assert_equal 1, c.served
    assert_equal 0, c.reward
    assert_equal 0, c.conversions
    
    #Make c the new winner
    rw(:jimbo, 40) #score a reward
    c.reload
    assert_equal 40, c.reward
    assert_equal 1, c.conversions
    
    #Now, let's see if he peaks his head out
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')
    c.reload
    assert_equal 2, c.served
    assert_equal 40, c.reward
    assert_equal 1, c.conversions
    
    #Okay, we now can be fairly confident we are serving the best usually
    #We need to test serving "random"-- this is going to be hard even with fake random
    #The end-all-be-all should be 'id'.. maybe
    @mg_i = 0
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'a', bd(:test, 'a')
    a.reload
    assert_equal 6, a.served
    
    #Now, back to the winner
    @mg_i = 1
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')
    c.reload
    assert_equal 3, c.served
    
    #Deeper reward tests
    @mg_storage = FakeSession.new #clear "session"
    rw(:jimbo, 15) #should go to nothing
    a.reload; b.reload; c.reload;
    assert_equal 30, a.reward
    assert_equal 0, b.reward
    assert_equal 40, c.reward
    
    #Let's regrab c (winner) and new metric test2 with 'j'
    assert_equal 'c', bd(:test, 'a')
    assert_equal 'j', bd(:test2, 'j')
    metric2 = Mg::Metric.find_by_metric_type(:test2.to_s)
    j = metric2.metric_variants.find_by_name('j')
    
    rw(:jimbo, 15) #should go to both c and j
    j.reload; a.reload; b.reload; c.reload;
    assert_equal 55, c.reward
    assert_equal 15, j.reward
    
    #Create a new variant 'k' for test2 metric
    metric2.metric_variants.create!( :value => 'k', :name => 'k' )
    k = metric2.metric_variants.find_by_name('k')
    
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')
    assert_equal 'k', bd(:test2, 'j') #this should be 'unexplored'
    
    rw(:jimbo, 15) #should go to c and k (not j)
    j.reload; k.reload; a.reload; b.reload; c.reload;
    assert_equal 30, a.reward
    assert_equal 0, b.reward
    assert_equal 70, c.reward
    assert_equal 15, j.reward
    assert_equal 15, k.reward
    
    #c = 70 / 6 = ~12, a = 30 / 6 = 5.. 70 / 14 = 5
    #let's make sure winners aren't winners if they are over-served
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a') # / 6
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')# / 7
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')# / 8
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')# / 9
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')# / 10
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')# / 11
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')# / 12
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')# / 13
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')# / 14
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'a', bd(:test, 'a')# / 15 !!
    @mg_storage = FakeSession.new #clear "session"
    assert_equal 'c', bd(:test, 'a')# 70 / 15 ~ 30 / 7
  end

  test "mountain goat tests - bandit switch" do
    @mg_strategy = 'e-greedy'
    @mg_storage = FakeSession.new
    
    #Let's start by adding a few tests, checking to see if storage is correct
    @var = 0
    assert_difference('Mg::MetricVariant.count', 2) do
      bds(:test) do |variant|
        variant.a do
          logger.warn "TRTTTu - In a"
          @var = 1
        end
        
        variant.b do
          logger.warn "TRTTTu - In b"
          @var = 2
        end
      end
    end
    
    metric = Mg::Metric.find_by_metric_type(:test.to_s)
    a = metric.metric_variants.find_by_name('a')
    b = metric.metric_variants.find_by_name('b')
    
    assert_equal a.id, @mg_storage[:metric_test_variant]
    
    assert_equal 1, @var
    assert_equal 1, a.served
    assert_equal 0, a.reward
    rw(:jimbo, 15) #should go to a
    a.reload
    assert_equal 15, a.reward
    
    rw(:jimbo, 10) #should go to a
    a.reload
    assert_equal 25, a.reward
    
    #should serve a since we haven't reset cookies
    assert_no_difference('Mg::MetricVariant.count') do 
      bds(:test) do |variant|
        variant.a do
          @var = 1
        end
        
        variant.b do
          @var = 2
        end
      end
    end
    
    a.reload; b.reload
    
    assert_equal 1, @var
    assert_equal 2, a.served
    
    #should serve b since it has no serves
    @mg_storage = FakeSession.new
    assert_no_difference('Mg::MetricVariant.count') do 
      bds(:test) do |variant|
        variant.a do
          @var = 1
        end
        
        variant.b do
          @var = 2
        end
      end
    end
    
    a.reload; b.reload
    
    assert_equal 2, @var
    assert_equal 2, a.served
    assert_equal 1, b.served
    assert_equal 0, b.reward
    rw(:jimbo, 15) #should go to b
    b.reload
    assert_equal 15, b.reward
    
    #should serve c since it has no serves
    @mg_storage = FakeSession.new
    assert_difference('Mg::MetricVariant.count') do 
      bds(:test) do |variant|
        variant.a do
          @var = 1
        end
        
        variant.b do
          @var = 2
        end
        
        variant.c do
          @var = 3
        end
      end
    end
    
    assert_equal 3, @var
  end
  
  test "mountain goat tests - e-greedy-decreasing" do
    @mg_strategy = 'e-greedy-decreasing'
    @mg_storage = FakeSession.new
    
    #Let's start by adding a few tests, checking to see if storage is correct
    assert_equal 'a', bd(:test, 'a')
    assert_equal 'a', bd(:test, 'a')
    metric = Mg::Metric.find_by_metric_type(:test.to_s)
    a = metric.metric_variants.find_by_name('a')
    assert_equal 1, metric.metric_variants.count
    assert_equal 2, a.served
    assert_equal a.id, @mg_storage[:metric_test_variant]
    assert_equal 0, a.reward
    
    rw(:jimbo, 10) #score a reward
    a.reload
    assert_equal 10, a.reward
    assert_equal 1, a.conversions
    rw(:jimbo, 20) #score a reward
    a.reload
    assert_equal 30, a.reward
    assert_equal 2, a.conversions
    
    metric.metric_variants.create!( :value => 'b', :name => 'b' )
    b = metric.metric_variants.find_by_name('b')
    
    assert_equal 2, metric.metric_variants.count
    assert_nil b.reward
    
    #Should serve 'b' for exploration of 0-serves
    @mg_storage = FakeSession.new
    assert_equal 'b', bd(:test, 'a')
    rw(:jimbo, 100) #a is still the winner
    
    @mg_storage = FakeSession.new
    #So far 3 serves, should serve random "a" when random < 0.1 / 3, "b" the winner otherwise
    @mg_storage = FakeSession.new
    @mg_i = 0.032
    assert_equal 'a', bd(:test, 'a')
    
    #So far 4 serves, should serve random "a" when random < 0.1 / 4, "b" the winner otherwise
    @mg_storage = FakeSession.new
    @mg_i = 0.025
    assert_equal 'b', bd(:test, 'a') #strictly less than
    
    #So far 5 serves, should serve random "a" when random < 0.1 / 5, "b" the winner otherwise
    @mg_storage = FakeSession.new
    @mg_i = 0.019
    assert_equal 'a', bd(:test, 'a')
    
    #So far 6 serves, should serve random "a" when random < 0.1 / 6, "b" the winner otherwise
    @mg_storage = FakeSession.new
    @mg_i = 0.017
    assert_equal 'b', bd(:test, 'a')
  end

  test "mountain goat tests - a/b" do
    @mg_strategy = 'a/b'
    @mg_storage = FakeSession.new
    
    #Let's start by adding a few tests, checking to see if storage is correct
    assert_equal 'a', bd(:test, 'a')
    assert_equal 'a', bd(:test, 'a')
    metric = Mg::Metric.find_by_metric_type(:test.to_s)
    a = metric.metric_variants.find_by_name('a')
    assert_equal 1, metric.metric_variants.count
    assert_equal 2, a.served
    assert_equal a.id, @mg_storage[:metric_test_variant]
    assert_equal 0, a.reward
    
    rw(:jimbo, 10) #score a reward
    a.reload
    assert_equal 10, a.reward
    assert_equal 1, a.conversions
    rw(:jimbo, 20) #score a reward
    a.reload
    assert_equal 30, a.reward
    assert_equal 2, a.conversions
    
    metric.metric_variants.create!( :value => 'b', :name => 'b' )
    b = metric.metric_variants.find_by_name('b')
    
    assert_equal 2, metric.metric_variants.count
    assert_nil b.reward
    
    #Since we aren't using rand.. we'll not likely be able to bypass 'a' in our 'randomness'
    assert_equal 'a', bd(:test, 'a')
    
    @mg_storage = FakeSession.new
    assert_equal 'a', bd(:test, 'a')
  end
end
