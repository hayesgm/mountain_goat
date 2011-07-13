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
end
