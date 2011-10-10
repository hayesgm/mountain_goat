# Install hook code here

require 'ftools'

# keep everything inside fo this scope
class InstallMetricTrackingTables

  def initialize
    show_banner
    check_system_cosistency
    copy_migration_files
  end

  def here
    File.dirname(__FILE__)
  end

  def sources
    Dir.glob(File.join([here, 'migrations', '*.*']))
  end

  def target
    File.join([here, '..', '..', '..', 'db', 'migrate'])
  end

  def validate_file_existance(file)
    abort "File not found: #{target}" unless File.exist? file
  end

  def show_banner
    puts '
      ** Copying migrations to your application
    '
  end

  def check_system_cosistency
    validate_file_existance(target)
    sources.each { |file| validate_file_existance(file) }
  end

  def copy_migration_files
    sources.each do |file|
      File.copy(file, target)
      puts "
      Source : #{file}
      Target : #{target}
      "
    end
  end

end

#InstallMetricTrackingTables.new
