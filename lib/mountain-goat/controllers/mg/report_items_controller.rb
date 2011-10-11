class Mg::ReportItemsController < Mg
  
  def get_extra
    ( render :json => { :success => true, :result => "<span></span>" } and return ) if params[:value].blank?
    id, model = params[:value].split('-')
    reportable = model.constantize.find(id)
    render :json => { :success => true, :result => render_to_string( :partial => 'mg/report_items/report_item_pivot_form', :locals => { :reportable => reportable } ) }
  end
  
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
    
    @report_item = @report.mg_report_items.new(params[:report_item].clone.delete_if { |k, v| k.intern == :reportable || k.intern == :pivot } )
    @report_item.order = @report.mg_report_items.maximum(:order) + 1 # @report.mg_report_items.to_a.map { |ri| ri.order }.push(0).max + 1# -- weird sqlite3 bugs
    
    if !params[:report_item][:reportable].blank?
      id, model = params[:report_item][:reportable].split('-')
      @report_item.reportable = model.constantize.find(id)
    end
    
    if !params[:report_item][:pivot].blank?
      id, model = params[:report_item][:pivot].split('-')
      @report_item.pivot = model.constantize.find(id)
    end
    
    if @report_item.save
      render :json => { :success => true,
                        :close_dialog => true,
                        :result => "<span>Successfully added report item</span>",
                        :also => [ { :item => ".report-report-items", :result => render_to_string( :partial => "mg/reports/report_report_items", :locals => { :report => @report_item.mg_report } ) } ] }
    else
      render :json => { :success => true,
                        :result => render_to_string(:action => :new, :layout => 'xhr') }
    end
  end
  
  def edit
    @report_item = Mg::ReportItem.find(params[:id])
    @report = @report_item.mg_report
    
    render :json => { :success => true,
                        :result => render_to_string(:action => :edit, :layout => 'xhr') }
  end
  
  def update
    @report_item = Mg::ReportItem.find(params[:id])
    @report_item.update_attributes(params[:report_item].clone.delete_if { |k, v| k.intern == :reportable || k.intern == :pivot } )
    
    if !params[:report_item][:reportable].blank?
      id, model = params[:report_item][:reportable].split('-')
      @report_item.reportable = model.constantize.find(id)
    end
    
    if !params[:report_item][:pivot].blank?
      id, model = params[:report_item][:pivot].split('-')
      @report_item.pivot = model.constantize.find(id)
    end
    
    if @report_item.save
      render :json => { :success => true,
                        :close_dialog => true,
                        :result => "<span>Successfully updated report item</span>",
                        :also => [ { :item => ".report-report-items", :result => render_to_string( :partial => "mg/reports/report_report_items", :locals => { :report => @report_item.mg_report }) } ] }
    else
      render :json => { :success => true,
                        :result => render_to_string(:action => :edit, :layout => 'xhr') }
    end
  end
  
  def up
    @report_item = Mg::ReportItem.find(params[:id])
    
    old_order = @report_item.order
    @report_item2 = Mg::ReportItem.last( :conditions => ["mg_report_items.order < ?", old_order], :order => "mg_report_items.order")
    
    ( render :json => { :success => true } and return ) if @report_item2.nil?
    
    @report_item.update_attribute(:order, @report_item2.order)
    @report_item2.update_attribute(:order, old_order)
    
    render :json => { :success => true, :result => render_to_string( :partial => "mg/reports/report_report_items", :locals => { :report => @report_item.mg_report } ) }
  end
  
  def down
    @report_item = Mg::ReportItem.find(params[:id])
    
    old_order = @report_item.order
    @report_item2 = Mg::ReportItem.first( :conditions => ["mg_report_items.order > ?", old_order], :order => "mg_report_items.order")
    
    ( render :json => { :success => true } and return ) if @report_item2.nil?
    
    @report_item.update_attribute(:order, @report_item2.order)
    @report_item2.update_attribute(:order, old_order)
    
    render :json => { :success => true, :result => render_to_string( :partial => "mg/reports/report_report_items", :locals => { :report => @report_item.mg_report } ) }
  end
  
  def destroy
    @report_item = Mg::ReportItem.find(params[:id])
    @report_item.destroy
    
    render :json => { :success => true, :result => render_to_string( :partial => "mg/reports/report_report_items", :locals => { :report => @report_item.mg_report } ) }
  end
end
