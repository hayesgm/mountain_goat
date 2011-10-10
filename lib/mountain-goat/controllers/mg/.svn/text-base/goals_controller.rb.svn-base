
class Mg::GoalsController < Mg

  # GET /mg/goal
  # GET /mg/goals.xml
  def index
    @goals = Mg::Goal.all(:conditions => { :is_hidden => false } )
    @hidden_goals = Mg::Goal.all(:conditions => { :is_hidden => true } )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @goals }
    end
  end

  # GET /mg/goals/1
  # GET /mg/goals/1.xml
  def show
    @goal = Mg::Goal.find(params[:id])

    @results_per_day = []
    created_at = @goal.created_at
    running_date = Time.utc( created_at.year, created_at.month, created_at.day )
    
    while running_date < Time.zone.now
      @results_per_day.push({ :date => running_date.to_i * 1000, :val => @goal.mg_records.find( :all, :conditions => { :created_at => running_date..(running_date + 60 * 60 * 24) } ).count })
      running_date += 60 * 60 * 24
    end
    
    @results_by_gmt = {}
    @results_by_gmt_titles = {}
    
    @goal.mg_goal_meta_types.each do |gmt|
      @results_by_gmt[gmt.id] = []
      @results_by_gmt_titles[gmt.id] = {}
      i = 0
      gmt.meta.all(:select => "data, count(*) as count", :group => "data").each do |meta|
        next if meta.data.nil?
        if gmt.meta_type == 'cs_meta' || gmt.meta_type == 'gs_meta' 
          @results_by_gmt[gmt.id].push( { :name => i, :val => meta.count } )
          @results_by_gmt_titles[gmt.id].merge!({ i => meta.data })
        else
          @results_by_gmt[gmt.id].push( { :name => meta.data, :val => meta.count } )
        end
        
        i += 1
      end
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @goal }
    end
  end

  # GET /mg/goals/new
  # GET /mg/goals/new.xml
  def new
    @goal = Mg::Goal.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @goal }
    end
  end

  # GET /mg/goals/1/edit
  def edit
    @goal = Mg::Goal.find(params[:id])
  end

  # POST /mg/goals
  # POST /mg/goals.xml
  def create
    @goal = Mg::Goal.new(params[:goal])

    if @goal.save
      flash[:notice] = 'Goal was successfully created.'
      redirect_to mg_goal_url :id => @goal.id
    else
      render :action => "new"
    end
  end

  # PUT /goals/1
  # PUT /goals/1.xml
  def update
    @goal = Mg::Goal.find(params[:id])

    if @goal.update_attributes(params[:goal])
      flash[:notice] = 'Goal was successfully updated.'
      redirect_to mg_goal_url :id => @goal.id
    else
      render :action => "edit"
    end
  end

  
  # GET /mg/goals/1/hide
  # GET /mg/goals/1/hide.xml
  def hide
    @goal = Mg::Goal.find(params[:id])
    @goal.update_attribute(:is_hidden, true)
    flash[:notice] = "Goal #{@goal.name} has been hidden."
    
    respond_to do |format|
      format.html { redirect_to mg_goals_url }
      format.xml  { head :ok }
    end
  end
  
  # GET /mg/goals/1/unhide
  # GET /mg/goals/1/unhide.xml
  def unhide
    @goal = Mg::Goal.find(params[:id])
    @goal.update_attribute(:is_hidden, false)
    flash[:notice] = "Goal #{@goal.name} has been restored."
    
    respond_to do |format|
      format.html { redirect_to mg_goals_url }
      format.xml  { head :ok }
    end
  end
  
  # DELETE /mg/goals/1
  # DELETE /mg/goals/1.xml
  def destroy
    @goal = Mg::Goal.find(params[:id])
    @goal.destroy

    respond_to do |format|
      format.html { redirect_to mg_goals_url }
      format.xml  { head :ok }
    end
  end
end
