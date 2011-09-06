require File.join(File.dirname(__FILE__), 'test_helper')

class Mg::ReportItemsControllerTest < ActionController::TestCase
  
  test "new" do
    get :new, { :report_id => mg_reports(:one).id }, logged_in
    assert_response :success
    assert_not_nil assigns(:report_item)
  end
  
  test "create" do
    get :create, { :report_id => mg_reports(:one).id , :report_item => { :reportable => "#{mg_converts(:one).id}-#{mg_converts(:one).class}" } }, logged_in
    assert_response :success
    assert_not_nil assigns(:report_item)
    assert_equal mg_converts(:one), assigns(:report_item).reportable
  end
  
  test "edit" do
    get :edit, { :id => mg_report_items(:one).id }, logged_in
    assert_response :success
    assert_not_nil assigns(:report_item)
  end
  
  test "update" do
    get :update, { :id => mg_report_items(:one).id, :report_item => { :reportable => "#{mg_converts(:two).id}-#{mg_converts(:two).class}" } }, logged_in
    assert_response :success
    assert_not_nil assigns(:report_item)
    assert_equal mg_converts(:two), assigns(:report_item).reportable
  end
  
end
