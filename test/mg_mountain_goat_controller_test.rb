require File.join(File.dirname(__FILE__), 'test_helper')

class Mg::MountainGoatControllerTest < ActionController::TestCase
  
  #fetch, login, login_create

  test "fetch file" do
    #Double __ could theoretically become a .., let's just stem this off
    assert_raise ArgumentError do
      get :fetch, { :file => 'hi__png' }
    end
    
    assert_raise ArgumentError do
      get :fetch, { :file => '__/analytics_rb' }
    end
    
    get :fetch, { :file => 'mgnew_css' }
    assert_response :not_found
    
    get :fetch, { :file => 'mg_css' }
    assert_response :success
  end
  
  test "login" do
    get :login
    assert_response :success
    assert flash[:error].blank?
  end
  
  test "login - create" do
    post :login_create, { :password => '123' }
    assert_response :success #invalid
    
    post :login_create, { :password => 'husky' }
    assert_redirected_to '/mg' #valid
  end
end
