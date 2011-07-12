require 'test_helper'

class Ocelot::OcelotMetricsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, admin_user
    assert_response :success
    assert_not_nil assigns(:metrics)
  end

  test "should get new" do
    get :new, { :ocelot_convert_id => converts(:one).id }, admin_user
    assert_response :success
  end

  test "should create metric" do
    assert_difference('Metric.count') do
      post :create, { :metric => { :metric_type => 'geoff', :title => 'hayes', :convert_id => converts(:two).id } }, admin_user
    end

    assert_redirected_to ocelot_ocelot_metric_url :id => assigns(:metric).id
  end

  test "should show metric" do
    get :show, { :id => metrics(:one).to_param }, admin_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => metrics(:one).to_param }, admin_user
    assert_response :success
  end

  test "should update metric" do
    put :update, { :id => metrics(:one).to_param, :metric => { } }, admin_user
    assert_redirected_to ocelot_ocelot_metric_url :id => assigns(:metric).id
  end

  test "should destroy metric" do
    assert_difference('Metric.count', -1) do
      delete :destroy, { :id => metrics(:one).to_param }, admin_user
    end

    assert_redirected_to ocelot_ocelot_metrics_url
  end
end
