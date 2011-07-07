
class MountainGoatController < ActionController::Base
  
  self.prepend_view_path File.join([File.dirname(__FILE__), '../../views/mountain_goat/'])
  
  def fetch
    Dir.open(File.join([File.dirname(__FILE__), '../../public/'])).each do |file|
      render :file => File.join([File.dirname(__FILE__), '../../public/', file]) and return if file == params[:file].gsub('_','.')
    end
    
    render :file => "#{Rails.root}/public/404.html", :status => :not_found
  end
  
  layout 'mountain_goat'
end