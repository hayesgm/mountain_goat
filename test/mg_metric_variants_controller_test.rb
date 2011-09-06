require File.join(File.dirname(__FILE__), 'test_helper')

class Mg::MetricVariantsControllerTest < ActionController::TestCase
  
  test "should get index" do
    get :index, {}, logged_in
    assert_response :success
    assert_not_nil assigns(:metric_variants)
  end

  test "should get new" do
    get :new, { :metric_id => mg_metrics(:two).id }, logged_in
    assert_response :success
  end

  test "should create metric_variant" do
    assert_difference('Mg::MetricVariant.count') do
      post :create, { :metric_variant => { :metric_id => mg_metrics(:two).id, :name => 'var', :value => 'cool' } }, logged_in
    end

    assert_redirected_to mg_metric_url mg_metrics(:two)
  end

  test "should show metric_variant" do
    get :show, { :id => mg_metric_variants(:one).to_param }, logged_in
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => mg_metric_variants(:one).to_param }, logged_in
    assert_response :success
  end

  test "should update metric_variant" do
    put :update, { :id => mg_metric_variants(:one).to_param, :metric_variant => { } }, logged_in
    assert_redirected_to mg_metric_url assigns(:metric_variant).metric
  end

  test "should destroy metric_variant" do
    assert_difference('Mg::MetricVariant.count', -1) do
      delete :destroy, { :id => mg_metric_variants(:one).to_param }, logged_in
    end

    assert_redirected_to mg_metric_variants_url
  end
end
