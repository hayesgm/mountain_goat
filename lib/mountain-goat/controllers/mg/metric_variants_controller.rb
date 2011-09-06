
class Mg::MetricVariantsController < Mg
  
  # GET /metric_variants
  # GET /metric_variants.xml
  def index
    @metric_variants = MetricVariant.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @metric_variants }
    end
  end

  # GET /metric_variants/1
  # GET /metric_variants/1.xml
  def show
    @metric_variant = MetricVariant.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @metric_variant }
    end
  end

  # GET /metric_variants/new
  # GET /metric_variants/new.xml
  def new
    @metric = Metric.find( params[:metric_id] )
    @metric_variant = MetricVariant.new( :metric_id => @metric.id )
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @metric_variant }
    end
  end

  # GET /metric_variants/1/edit
  def edit
    @metric_variant = MetricVariant.find(params[:id])
  end

  # POST /metric_variants
  # POST /metric_variants.xml
  def create
    @metric = Metric.find( params[:metric_variant][:metric_id] )
    @metric_variant = MetricVariant.new(params[:metric_variant])

    if @metric_variant.save
      flash[:notice] = 'Metric variant was successfully created.'
      redirect_to mg_metric_url :id => @metric_variant.metric.id 
    else
      render :action => "new"
    end
  end

  # PUT /metric_variants/1
  # PUT /metric_variants/1.xml
  def update
    @metric_variant = MetricVariant.find(params[:id])

    if @metric_variant.update_attributes(params[:metric_variant])
      flash[:notice] = 'Metric variant was successfully updated.'
      redirect_to mg_metric_url :id => @metric_variant.metric.id
    else
      render :action => "edit"
    end
  end

  # DELETE /metric_variants/1
  # DELETE /metric_variants/1.xml
  def destroy
    @metric_variant = MetricVariant.find(params[:id])
    @metric_variant.destroy

    respond_to do |format|
      format.html { redirect_to mg_metric_variants_url }
      format.xml  { head :ok }
    end
  end
end
