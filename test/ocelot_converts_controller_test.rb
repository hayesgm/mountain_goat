require 'test_helper'

class Ocelot::OcelotConvertsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, admin_user
    assert_response :success
    assert_not_nil assigns(:converts)
  end

  test "should get new" do
    get :new, {}, admin_user
    assert_response :success
  end

  test "should create convert" do
    assert_difference('Convert.count') do
      post :create, { :convert => { :name => 'my next convert', :convert_type => 'convert_type_3' } }, admin_user
    end

    assert_redirected_to ocelot_ocelot_convert_url assigns(:convert)
  end

  test "should show convert" do
    get :show, { :id => converts(:one).to_param }, admin_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => converts(:one).to_param }, admin_user
    assert_response :success
  end

  test "should update convert" do
    put :update, { :id => converts(:one).to_param, :convert => { } }, admin_user
    assert_redirected_to ocelot_ocelot_convert_url assigns(:convert)
  end

  test "should destroy convert" do
    assert_difference('Convert.count', -1) do
      delete :destroy, { :id => converts(:one).to_param }, admin_user
    end

    assert_redirected_to ocelot_ocelot_converts_url
  end
end
