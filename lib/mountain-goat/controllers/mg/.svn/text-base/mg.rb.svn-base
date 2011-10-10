
class Mg < ActionController::Base
  
  layout 'mountain_goat'
  
  before_filter :verify_access
  
  self.prepend_view_path File.join([File.dirname(__FILE__), '../../views/mountain_goat/'])
  
  private
  
  def store_location(url = nil)
    if url.nil?
      if request.method == :post && request.params.count > 0
        session[:mg_return_to] = "#{request.request_uri}?" + encode_parameters(request.params)
      else
        session[:mg_return_to] = request.request_uri
      end
    else
      session[:mg_return_to] = url
    end
    
    logger.warn "Storing location: #{session[:mg_return_to]}"
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:mg_return_to] || default)
    session[:mg_return_to] = nil
  end
  
  def verify_access
    return if session[:mg_access] == true
    store_location
    redirect_to mg_login_url and return
  end
  
  def self.password_digest(password, salt)
    site_key = '1e9532ea39233e1e2786d80fde90d708c0918d2d'
    stretches = 10
    digest = site_key
    stretches.times do
      digest = secure_digest(digest, salt, password, site_key)
    end
    digest
  end
  
end