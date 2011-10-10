
class Mg::ConvertsController < Mg

  # GET /converts
  # GET /converts.xml
  def index
    @converts = Mg::Convert.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @converts }
    end
  end

  # GET /converts/1
  # GET /converts/1.xml
  def show
    @convert = Mg::Convert.find(params[:id])

    @results_per_day = []
    created_at = @convert.created_at
    running_date = Time.utc( created_at.year, created_at.month, created_at.day )
    
    while running_date < Time.zone.now
      @results_per_day.push({ :date => running_date.to_i * 1000, :val => @convert.rallies.find( :all, :conditions => { :created_at => running_date..(running_date + 60 * 60 * 24) } ).count })
      running_date += 60 * 60 * 24
    end
    
    @results_by_cmt = {}
    @results_by_cmt_titles = {}
    
    @convert.convert_meta_types.each do |cmt|
      @results_by_cmt[cmt.id] = []
      @results_by_cmt_titles[cmt.id] = {}
      i = 0
      cmt.meta.all(:select => "data, count(*) as count", :group => "data").each do |meta|
        next if meta.data.nil?
        if cmt.meta_type == 'cs_meta'
          @results_by_cmt[cmt.id].push( { :name => i, :val => meta.count } )
          @results_by_cmt_titles[cmt.id].merge!({ i => meta.data })
        else
          @results_by_cmt[cmt.id].push( { :name => meta.data, :val => meta.count } )
        end
        
        i += 1
      end
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @convert }
    end
  end

  # GET /converts/new
  # GET /converts/new.xml
  def new
    @convert = Mg::Convert.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @convert }
    end
  end

  # GET /converts/1/edit
  def edit
    @convert = Convert.find(params[:id])
  end

  # POST /converts
  # POST /converts.xml
  def create
    @convert = Mg::Convert.new(params[:convert])

    if @convert.save
      flash[:notice] = 'Convert was successfully created.'
      redirect_to mg_convert_url :id => @convert.id
    else
      render :action => "new"
    end
  end

  # PUT /converts/1
  # PUT /converts/1.xml
  def update
    @convert = Mg::Convert.find(params[:id])

    if @convert.update_attributes(params[:convert])
      flash[:notice] = 'Convert was successfully updated.'
      redirect_to mg_convert_url :id => @convert.id
    else
      render :action => "edit"
    end
  end

  # DELETE /converts/1
  # DELETE /converts/1.xml
  def destroy
    @convert = Mg::Convert.find(params[:id])
    @convert.destroy

    respond_to do |format|
      format.html { redirect_to mg_converts_url }
      format.xml  { head :ok }
    end
  end
end
