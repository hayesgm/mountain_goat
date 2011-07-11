
class MountainGoatController < ActionController::Base
  
  layout 'mountain_goat'
  
  before_filter :verify_access, :except => [ :login, :login_create, :fetch ] 
  
  self.prepend_view_path File.join([File.dirname(__FILE__), '../../views/mountain_goat/'])
    
  def fetch
    ct = { :png => 'image/png', :css => 'text/css', :html => 'text/html', :js => 'text/javascript' }
    
    Dir.open(File.join([File.dirname(__FILE__), '../../public/'])).each do |file|
      if file == params[:file].gsub('_','.')
        if file =~ /[.]([a-z0-9]+)$/
          response.headers['Content-Type'] = ct[$1.to_sym]
        end
        response.headers['Content-Disposition'] = 'inline'
        render :text => open(File.join([File.dirname(__FILE__), '../../public/', file]), "rb").read
        return
      end
    end
    
    render :file => "#{Rails.root}/public/404.html", :status => :not_found
  end
  
  def verify_access
    return if session.has_key?(:mg_access) && session[:mg_access] == true
    redirect_to '/mg/login' and return
  end
  
  def login
    mg_yml = YAML::load(File.open("#{RAILS_ROOT}/config/mountain-goat.yml"))
    if mg_yml
      mg_yml_env = mg_yml.with_indifferent_access[RAILS_ENV]
      if mg_yml_env
        flash[:error] = "<em>config/mountain-goat.yml</em> missing password (blank / missing) for current environment.  You cannot access mountain goat until you set the password for this environment." if mg_yml_env.with_indifferent_access[:password].blank?
      else
        flash[:error] = "<em>config/mountain-goat.yml</em> missing password for current environment '#{RAILS_ENV}'.  You cannot access mountain goat until you configure this file for this environment."
      end
    else
      flash[:error] = "<em>config/mountain-goat.yml</em> missing.  You cannot access mountain goat until you configure this file."
    end
  end
  
  def login_create
    raise ArgumentError, "Missing password" if !params.has_key?(:password)
    
    valid_password = nil
    begin
      valid_password = YAML::load(File.open("#{RAILS_ROOT}/config/mountain-goat.yml")).with_indifferent_access[RAILS_ENV].with_indifferent_access[:password]
    rescue
      raise ArgumentError, "config/mountain-goat.yml not properly configured"
    end
    raise ArgumentError, "config/mountain-goat.yml not properly configured" if valid_password.nil?
    
    if params[:password] == valid_password
      flash[:notice] = "You have successfully logged in."
      session[:mg_access] = true
      redirect_back_or_default '/mg'
    else
      flash[:notice] = "Incorrect password."
      render :login
    end
  end
  
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
  
  private
  
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