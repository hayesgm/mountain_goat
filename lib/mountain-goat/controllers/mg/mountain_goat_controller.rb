
class Mg::MountainGoatController < Mg
  
  before_filter :verify_access, :except => [ :login, :login_create, :fetch ] 
    
  def fetch
    ct = { :png => 'image/png', :css => 'text/css', :html => 'text/html', :js => 'text/javascript' }
    
    raise ArgumentError, "Invalid fetch file" if params[:file].match(/[_][_]/ix) #extra security
    
    #We will only serve files located in the public directory for security reasons
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
    
    render :file => "#{RAILS_ROOT}/public/404.html", :status => :not_found
  end
  
  def login
    mg_yml = nil
    begin
      mg_yml = YAML::load(File.open("#{RAILS_ROOT}/config/mountain-goat.yml"))
    rescue
    end
  
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
  
end