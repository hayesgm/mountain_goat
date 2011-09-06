
class Mg::MetricsController < Mg
  
  # GET /metrics
  # GET /metrics.xml
  def index
    @metrics = Metric.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @metrics }
    end
  end

  # GET /metrics/1
  # GET /metrics/1.xml
  def show
    @metric = Metric.find(params[:id])

    @rates = {}
    @rates[:served] = []
    @rates[:conversions] = []
    @rates[:conversion_rates] = []
    @rates[:titles] = {}
    i = 0
    @metric.metric_variants.each do |mv|
      @rates[:served].push( { :variant_type => i, :value => mv.served } )
      @rates[:conversions].push( { :variant_type => i, :value => mv.conversions } )
      @rates[:conversion_rates].push( { :variant_type => i, :value => mv.conversion_rate } )
      @rates[:titles].merge!({i => mv.name})
      i += 1
    end
    
    logger.warn @rates[:titles].inspect
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @metric }
    end
  end

  # GET /metrics/new
  # GET /metrics/new.xml
  def new
    @metric = Metric.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @metric }
    end
  end

  # GET /metrics/1/edit
  def edit
    @metric = Metric.find(params[:id])
  end

  # POST /metrics
  # POST /metrics.xml
  def create
    @metric = Metric.new(params[:metric])

    if @metric.save
      flash[:notice] = 'Metric was successfully created.'
      redirect_to mg_metric_url :id => @metric.id
    else
      render :action => "new"
    end
  end

  # PUT /metrics/1
  # PUT /metrics/1.xml
  def update
    @metric = Metric.find(params[:id])

    if @metric.update_attributes(params[:metric])
      flash[:notice] = 'Metric was successfully updated.'
      redirect_to mg_metric_url :id => @metric.id
    else
      render :action => "edit"
    end
  end

  # DELETE /metrics/1
  # DELETE /metrics/1.xml
  def destroy
    @metric = Metric.find(params[:id])
    @metric.destroy

    respond_to do |format|
      format.html { redirect_to(mg_metrics_url) }
      format.xml  { head :ok }
    end
  end
  
  #TODO: This only works if we are using cookie storage? Clear session as well
  def fresh_metrics
    #clear metrics
    #logger.warn "Headerish #{response.headers['cookie']}"
    cookies.each do |cookie|
      if cookie[0] =~ /metric_([a-z0-9_]+)/
        logger.warn "Deleting cookie #{cookie[0]}"
        cookies.delete cookie[0], :domain => WILD_DOMAIN
      end
    end
    
    flash[:notice] = "Your metrics have been cleared from cookies."
    redirect_to :back
  end
end
