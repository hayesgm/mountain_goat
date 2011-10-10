
class Mg::RecordsController < Mg
 
  # GET /mg/records
  # GET /mg/goals/:goal_id/records
  def index
    @page = !params[:page].nil? ? params[:page].to_i : 1
    @goal = Mg::Goal.find(params[:goal_id]) if !params[:goal_id].nil?
 
    if @goal
      @records = @goal.mg_records.find(:all, :conditions => { }, :order => "created_at DESC", :limit => 100, :offset => ( @page - 1 ) * 100 )
    else
      @records = Mg::Record.find(:all, :conditions => { }, :order => "created_at DESC", :limit => 100, :offset => ( @page - 1 ) * 100 )
    end
    
    respond_to do |format|
      format.html { }
    end
  end
  
  def new_records
    recent_record = params[:recent_record].to_i
    goal = Mg::Goal.find(params[:goal_id].to_i) unless params[:goal_id].blank?
    
    if goal
      @records = goal.mg_records.find(:all, :conditions => [ 'id > ?', recent_record ], :order => "id DESC" )
    else
      @records = Mg::Record.find(:all, :conditions => [ 'id > ?', recent_record ], :order => "id DESC" )
    end
    
    if @records.count > 0
      render :json => { :success => true,
                      :result => render_to_string(:partial => 'mg/records/records', :locals => { :records => @records } ),
                      :recent_record_id => @records.first.id }
    else
      render :json => { :success => false }
    end
    
  end
  
  # GET /mg/records/:id
  def show
    @record = Mg::Record.find(params[:id])
  end
  
end
