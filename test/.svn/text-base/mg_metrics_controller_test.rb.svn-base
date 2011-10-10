require File.join(File.dirname(__FILE__), 'test_helper')

class Mg::MetricsControllerTest < ActionController::TestCase
  
  test "should test fresh metrics" do
    @request.env["HTTP_REFERER"] = "http://test.host/hi"
    put :fresh_metrics, { }, logged_in #this clears cookies.. meh
    assert_redirected_to "http://test.host/hi"
  end
  
  test "should get index" do
    get :index, {}, logged_in
    assert_response :success
    assert_not_nil assigns(:metrics)
  end

  test "should get new" do
    get :new, { }, logged_in
    assert_response :success
  end

  test "should create metric" do
    assert_difference('Mg::Metric.count') do
      post :create, { :metric => { :metric_type => 'geoff', :title => 'hayes' } }, logged_in
    end

    assert_redirected_to mg_metric_url :id => assigns(:metric).id
  end

  test "should show metric" do
    get :show, { :id => mg_metrics(:one).to_param }, logged_in
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => mg_metrics(:one).to_param }, logged_in
    assert_response :success
  end

  test "should update metric" do
    put :update, { :id => mg_metrics(:one).to_param, :metric => { } }, logged_in
    assert_redirected_to mg_metric_url :id => assigns(:metric).id
  end

  test "should destroy metric" do
    assert_difference('Mg::Metric.count', -1) do
      delete :destroy, { :id => mg_metrics(:one).to_param }, logged_in
    end

    assert_redirected_to mg_metrics_url
  end
end
