class Mg::ReportItemsController < Mg
  
  def new
    @report = Mg::Report.find(params[:report_id])
    raise ArgumentError, "Invalid report" if @report.nil?
    
    @report_item = Mg::ReportItem.new
    
    render :json => { :success => true,
                        :result => render_to_string(:action => :new, :layout => 'xhr') }
  end
  
  def create
    @report = Mg::Report.find(params[:report_id])
    raise ArgumentError, "Invalid report" if @report.nil?
    
    @report_item = @report.report_items.new(params[:report_item].clone.delete_if { |k, v| k.intern == :reportable } )
    @report_item.order = @report.report_items.to_a.map { |ri| ri.order }.push(0).max + 1#@report.report_items.maximum(:order) + 1 -- weird sqlite3 bugs
    
    if !params[:report_item][:reportable].blank?
      id, model = params[:report_item][:reportable].split('-')
      @report_item.reportable = model.constantize.find(id)
    end
    
    if @report_item.save
      render :json => { :success => true,
                        :close_dialog => true,
                        :result => "<span>Successfully added report item</span>",
                        :also => [ { :item => ".report-report-items", :result => render_to_string( :partial => "mg/reports/report_report_items", :locals => { :report => @report } ) } ] }
    else
      render :json => { :success => true,
                        :result => render_to_string(:action => :new, :layout => 'xhr') }
    end
  end
  
  def edit
    @report_item = Mg::ReportItem.find(params[:id])
    @report = @report_item.report
    
    render :json => { :success => true,
                        :result => render_to_string(:action => :edit, :layout => 'xhr') }
  end
  
  def update
    @report_item = Mg::ReportItem.find(params[:id])
    @report_item.update_attributes(params[:report_item].clone.delete_if { |k, v| k.intern == :reportable } )
    
    if !params[:report_item][:reportable].blank?
      id, model = params[:report_item][:reportable].split('-')
      @report_item.reportable = model.constantize.find(id)
    end
    
    if @report_item.save
      render :json => { :success => true,
                        :close_dialog => true,
                        :result => "<span>Successfully updated report item</span>",
                        :also => [ { :item => ".report-report-items", :result => render_to_string( :partial => "mg/reports/report_report_items", :locals => { :report => @report_item.report }) } ] }
    else
      render :json => { :success => true,
                        :result => render_to_string(:action => :edit, :layout => 'xhr') }
    end
  end
  
  #TODO: Destroy
end
