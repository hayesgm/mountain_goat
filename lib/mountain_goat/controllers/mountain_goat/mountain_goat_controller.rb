
class MountainGoatController < ActionController::Base
  
  self.prepend_view_path File.join([File.dirname(__FILE__), '../../views/mountain_goat/'])
  
  layout 'mountain_goat'
end