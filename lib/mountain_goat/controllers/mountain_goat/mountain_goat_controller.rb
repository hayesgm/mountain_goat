class MountainGoatController < ActionController::Base
  
  self.view_paths.push File.join([File.dirname(__FILE__), '../../views/mountain_goat/'])
  
  layout 'mountain_goat'
end