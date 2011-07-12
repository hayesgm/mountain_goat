require 'test_helper'

class Ocelot::OcelotMetricVariantsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, admin_user
    assert_response :success
    assert_not_nil assigns(:metric_variants)
  end

  test "should get new" do
    get :new, { :ocelot_metric_id => metrics(:two).id }, admin_user
    assert_response :success
  end

  test "should create metric_variant" do
    assert_difference('MetricVariant.count') do
      post :create, { :metric_variant => { :metric_id => metrics(:two).id, :name => 'var', :value => 'cool' } }, admin_user
    end

    assert_redirected_to ocelot_ocelot_metric_url metrics(:two)
  end

  test "should show metric_variant" do
    get :show, { :id => metric_variants(:one).to_param }, admin_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => metric_variants(:one).to_param }, admin_user
    assert_response :success
  end

  test "should update metric_variant" do
    put :update, { :id => metric_variants(:one).to_param, :metric_variant => { } }, admin_user
    assert_redirected_to ocelot_ocelot_metric_url assigns(:metric_variant).metric
  end

  test "should destroy metric_variant" do
    assert_difference('MetricVariant.count', -1) do
      delete :destroy, { :id => metric_variants(:one).to_param }, admin_user
    end

    assert_redirected_to ocelot_ocelot_metric_variants_url
  end
end
