
################
# Setup PDFKit #
################

begin
  require 'pdfkit'
rescue LoadError
  raise "Mountain Goat Reports will not work without the 'pdfkit' gem (please run `gem install pdfkit`)"
end

######################
# Setup svg-graph    #
######################

begin
  require 'SVG/Graph/TimeSeries'
rescue LoadError
  raise "Mountain Goat Reports will not work without the 'svg-graph' gem (please run `gem install svg-graph`)"
end

############################
# TODO: Verify Email Setup #
############################

class MG
  def self.deliver(delivery_set = nil)
    mg_yml = YAML::load(File.open("#{RAILS_ROOT}/config/mountain-goat.yml"))
    
    if mg_yml.blank? || mg_yml[RAILS_ENV].blank? || mg_yml[RAILS_ENV]['wkhtmltopdf'].blank?
      raise "Please configure wkhtmltopdf settings in #{RAILS_ROOT}/config/mountain-goat.yml"
    end
    
    PDFKit.configure do |cz|
      cz.wkhtmltopdf = mg_yml[RAILS_ENV]['wkhtmltopdf']
      cz.default_options = { :'custom-header' => "'Content-Type' 'application/xhtml+xml'" }
    end
    
    if delivery_set.nil?
      reports = Mg::Report.all
    else
      reports = Mg::Report.find(:all, :conditions => { :delivery_set => delivery_set.to_s } )
    end
    
    #We need to render the report report_show
    reports.each do |report|
      puts "Delivering report: #{report.title}"
      av = ActionView::Base.new
      av.view_paths = File.join([File.dirname(__FILE__), 'views/mountain_goat/'])
      data = av.render(:partial => 'mg/reports/report', :layout => 'layouts/pdf', :locals => { :report => report } )
      
      #Oddly, the file extension matters most here
      tmp = Tempfile.new(['chart', '.xhtml'])
      tmp << data
      tmp.flush
      
      kit = PDFKit.new(File.new(tmp.path), :page_size => 'Letter')
      pdf = kit.to_pdf
      tmp.close
      
      Mg::ReportMailer.deliver_report(report, pdf)
    end
  end
end