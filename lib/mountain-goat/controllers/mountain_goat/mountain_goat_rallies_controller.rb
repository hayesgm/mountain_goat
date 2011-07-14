class MountainGoatRalliesController < MountainGoatController
 
  def index
     
    @page = !params[:page].nil? ? params[:page].to_i : 1
    @convert = Convert.find(params[:mountain_goat_convert_id]) if !params[:mountain_goat_convert_id].nil?
 
    if @convert
      @rallies = @convert.rallies.find(:all, :conditions => { }, :order => "created_at DESC", :limit => 100, :offset => ( @page - 1 ) * 100 )
    else
      @rallies = Rally.find(:all, :conditions => { }, :order => "created_at DESC", :limit => 100, :offset => ( @page - 1 ) * 100 )
    end
    
    respond_to do |format|
      format.html { }
    end
  end
  
  def new_rallies
    recent_rally = params[:recent_rally].to_i
    convert = Convert.find(params[:convert_id].to_i) unless params[:convert_id].blank?
    
    if convert
      @rallies = convert.rallies.find(:all, :conditions => [ 'id > ?', recent_rally ], :order => "created_at DESC" )
    else
      @rallies = Rally.find(:all, :conditions => [ 'id > ?', recent_rally ], :order => "created_at DESC" )
    end
    
    if @rallies.count > 0
      render :json => { :success => true,
                      :result => render_to_string(:partial => 'mountain_goat_rallies/rallies', :locals => { :rallies => @rallies } ),
                      :recent_rally_id => @rallies.first.id }
    else
      render :json => { :success => false }
    end
    
  end
end
