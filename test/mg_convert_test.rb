require File.join(File.dirname(__FILE__), 'test_helper')

class Mg::ConvertTest < ActiveSupport::TestCase
  include MetricTracking::Controller
  
  test "should tests" do
    @mg_strategy = 'e-greedy'
    
    assert_difference 'Mg::Convert.count' do
      assert_difference 'Mg::Rally.count' do
        assert_difference 'Mg::CsMeta.count' do
          assert_difference 'Mg::ConvertMetaType.count' do
            rw(:hiz, 0, :geoff => "hayes")
          end
        end
      end
    end
    
    conv = Mg::Convert.by_type(:hiz)
    assert_not_nil conv
    
    assert_equal "hayes", conv.rallies_for_meta(:geoff).first.first[0]

    #short-hand method
    assert_difference 'Mg::Rally.count' do
      assert_difference 'Mg::CsMeta.count' do
        rw(:hiz, :geoff => "hayes")
      end
    end

  end
end
