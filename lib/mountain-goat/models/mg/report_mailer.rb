class Mg::ReportMailer < ActionMailer::Base
  
  self.template_root = File.join([File.dirname(__FILE__), '../../views/mountain_goat/'])
  
  def report(report, pdf)
    @recipients  = report.recipients
    @subject = "[Mountain Goat] - #{report.title}"
    @body[:report] = report
    
    part :content_type => "text/html",
         :body => render_message('report', @body)
        
    attachment :content_type => "application/pdf",
      :filename => "report.pdf",
      :body => pdf
  end
  
end
