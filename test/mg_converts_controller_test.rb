require File.join(File.dirname(__FILE__), 'test_helper')

class Mg::ConvertsControllerTest < ActionController::TestCase
  #index, show, new, edit, create, update, destroy
  
  test "should get index" do
    get :index, {}, logged_in
    assert_response :success
    assert_not_nil assigns(:converts)
  end

  test "should get new" do
    get :new, {}, logged_in
    assert_response :success
  end

  test "should create convert" do
    assert_difference('Mg::Convert.count') do
      post :create, { :convert => { :name => 'my next convert', :convert_type => 'convert_type_3' } }, logged_in
    end

    assert_redirected_to mg_convert_url assigns(:convert)
  end

  test "should show convert" do
    get :show, { :id => mg_converts(:one).to_param }, logged_in
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => mg_converts(:one).to_param }, logged_in
    assert_response :success
  end

  test "should update convert" do
    put :update, { :id => mg_converts(:one).to_param, :convert => { } }, logged_in
    assert_redirected_to mg_convert_url assigns(:convert)
  end

  test "should destroy convert" do
    assert_difference('Mg::Convert.count', -1) do
      delete :destroy, { :id => mg_converts(:one).to_param }, logged_in
    end

    assert_redirected_to mg_converts_url
  end
end
