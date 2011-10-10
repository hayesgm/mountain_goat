require File.join(File.dirname(__FILE__), 'test_helper')

class Mg::RalliesControllerTest < ActionController::TestCase
  
  #index, new_rallies, show
  
  test "get index" do
    get :index, {}, logged_in
    assert_response :success
    assert_not_nil assigns(:rallies)
    
    get :index, { :convert_id => mg_converts(:two).id }, logged_in
    assert_response :success
    assert_not_nil assigns(:rallies)
    assert_equal mg_converts(:two).id, assigns(:rallies).first.convert_id
  end
  
  test "get new rallies" do
    get :new_rallies, {}, logged_in #should get everything
    assert_response :success
    assert_not_nil assigns(:rallies)
    assert_equal Mg::Rally.count, assigns(:rallies).count
    
    #should get nothing (we are up to date)
    get :new_rallies, { :recent_rally => Mg::Rally.last.id }, logged_in
    assert_response :success
    assert_not_nil assigns(:rallies)
    assert_equal 0, assigns(:rallies).count
  end
  
  test "get show" do
    get :show, { :id => mg_rallies(:one).id }, logged_in
    assert_response :success
    assert_not_nil assigns(:rally)
  end
end
