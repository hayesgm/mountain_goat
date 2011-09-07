class Mg::ReportsController < Mg
  # GET /mg_reports
  # GET /mg_reports.xml
  def index
    @reports = Mg::Report.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reports }
    end
  end

  # GET /mg_reports/1
  # GET /mg_reports/1.xml
  def show
    @report = Mg::Report.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @report }
    end
  end
  
  def show_svg
    @report = Mg::Report.find(params[:id])

    render :text => render_to_string(:partial => "mg/reports/report", :layout => '_pdf', :locals => { :report => @report } )
    response.content_type = 'application/xhtml+xml'
  end

  # GET /mg_reports/new
  # GET /mg_reports/new.xml
  def new
    @report = Mg::Report.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @report }
    end
  end

  # GET /mg_reports/1/edit
  def edit
    @report = Mg::Report.find(params[:id])
  end

  # POST /mg_reports
  # POST /mg_reports.xml
  def create
    @report = Mg::Report.new(params[:report])

    respond_to do |format|
      if @report.save
        format.html { flash[:notice] = 'Your report was successfully created, now add some report items.'; redirect_to(edit_mg_report_url @report) }
        format.xml  { render :xml => @report, :status => :created, :location => @report }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mg_reports/1
  # PUT /mg_reports/1.xml
  def update
    @report = Mg::Report.find(params[:id])

    respond_to do |format|
      if @report.update_attributes(params[:report])
        format.html { redirect_to(@report, :notice => 'Mg::Report was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mg_reports/1
  # DELETE /mg_reports/1.xml
  def destroy
    @report = Mg::Report.find(params[:id])
    @report.destroy

    respond_to do |format|
      format.html { redirect_to(mg_reports_url) }
      format.xml  { head :ok }
    end
  end
end
