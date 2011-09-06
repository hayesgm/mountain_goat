require File.join(File.dirname(__FILE__), 'test_helper')

class Mg::ReportTest < ActiveSupport::TestCase
  
  test "delivery" do
    assert_difference 'ActionMailer::Base.deliveries.size', 2 do
      MG.deliver(nil)
    end
    
    assert_difference 'ActionMailer::Base.deliveries.size' do
      MG.deliver("daily")
    end
    
    assert_difference 'ActionMailer::Base.deliveries.size' do
      MG.deliver("weekly")
    end
  end
end
