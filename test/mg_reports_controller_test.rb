require File.join(File.dirname(__FILE__), 'test_helper')

class Mg::ReportsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, logged_in
    assert_response :success
    assert_not_nil assigns(:reports)
  end

  test "should get new" do
    get :new, {}, logged_in
    assert_response :success
  end

  test "should create report" do
    assert_difference('Mg::Report.count') do
      post :create, { :report => { :title => 'abc', :delivery_set => "hi", :recipients => "aaa@bbb.com" } }, logged_in
    end

    assert_redirected_to mg_report_path(assigns(:report))
  end

  test "should show report" do
    get :show, { :id => mg_reports(:one).to_param }, logged_in
    assert_response :success
  end
  
  test "should show svg report" do
    get :show_svg, { :id => mg_reports(:one).to_param }, logged_in
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => mg_reports(:one).to_param }, logged_in
    assert_response :success
  end

  test "should update report" do
    put :update, { :id => mg_reports(:one).to_param, :report => { :title => 'abc', :delivery_set => "hi", :recipients => "aaa@bbb.com" } }, logged_in
    assert_redirected_to mg_report_path(assigns(:report))
  end

  test "should destroy report" do
    assert_difference('Mg::Report.count', -1) do
      delete :destroy, { :id => mg_reports(:one).to_param }, logged_in
    end

    assert_redirected_to mg_reports_path
  end
end
