class MgGenerator < Rails::Generator::Base
  def add_options!(opt)
    opt.on('-p', '--password=password', String, "Your password to access Mountain Goat") { |v| options[:password] = v}
    opt.on('-w', '--wkhtmltopdf=/path/to/dir', String, "Path to installation of wkhtmltopdf (optional)") { |v| options[:wkhtmltopdf] = v}
    opt.on('-u', '--update=yes', String, "If you have previously installed Mountain Goat, use to generate *update* tables.") { |v| options[:update] = v}
    puts <<-HELPFUL_INSTRUCTIONS

      Mountain Goat is your home for in-house bandit testing.
      
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
      4) Play around, read the docs, bandit, enjoy. 
      
      HELPFUL_INSTRUCTIONS
  end

  def manifest
    password = options[:password] || ""
    wkhtmltopdf = options[:wkhtmltopdf] || ""
    update = !options[:update].blank? && options[:update].downcase != "no" && options[:update].downcase != "n" && options[:update] != "0"
    
    record do |m|
      m.template 'mountain_goat_reports.rake', 'lib/tasks/mountain_goat_reports.rake'
      m.template 'mountain-goat.yml', 'config/mountain-goat.yml', :assigns => { :password => password, :wkhtmltopdf => wkhtmltopdf }
      
      if !update
        m.migration_template 'create_mountain_goat_tables.rb', 'db/migrate', { :migration_file_name => "create_mountain_goat_tables" }
      else
        m.migration_template 'update_mountain_goat_tables.rb', 'db/migrate', { :migration_file_name => "update_mountain_goat_tables" }
      end
      
    end
  end
  
  private
  
end