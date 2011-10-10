
#################################################################
# Mountain Goat                                                 #
#                                                               #
#  This file has been installed to add the 'mg:deliver'         #
#   rake task to your project.  If you are not using            #
#   Mountain Goat Reporting, you can safely remove this file.   #
#                                                               #
#################################################################

namespace :mg do
  
  desc "deliver mountain goat reports"
  task :deliver, :delivery_set, :needs => :environment do |t, args|
    MG.deliver(args[:delivery_set])
  end
end
