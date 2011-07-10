
class MountainGoatController < ActionController::Base
  
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
  
  layout 'mountain_goat'
end