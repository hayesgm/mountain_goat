class MgGenerator < Rails::Generator::Base
  def add_options!(opt)
    opt.on('-p', '--password=password', String, "Your password to access Mountain Goat") { |v| options[:password] = v}
    puts <<-HELPFUL_INSTRUCTIONS

      Mountain Goat is your home for A/B testing in-house.
      
      We have installed your configuration file to config/mountain-goat.yml
      Please choose a password for each environment in this file.  Make
      sure this password is secure.
      
      This will copy necessary migrations to your db/migrate folder.  Please migrate
      your database before running mountain-goat.
      
      To access mountain-goat, navigate to /mg in your project.  Everything else
      should be handled by the gem.  Enjoy!
      
      1) Choose an admin-password in config/mountain-goat.yml
      2) Run `rake db:migrate`
      3) Start your server and navigate to 'http://mydomain.com/mg'
      4) Play around, read the docs, A/B test, enjoy. 
      
      HELPFUL_INSTRUCTIONS
  end

  def manifest
    if options[:password].blank?
      password = ""
    else
      password = options[:password]
    end
    record do |m|
      #m.template 'mountain-goat.yml', 'config/mountain-goat.yml', :assigns => {:password => password}
      m.migration_template 'create_mountain_goat_tables.rb', 'db/migrate', { :migration_file_name => "create_mountain_goat_tables" }
    end
  end
  
  private
  
end