
class Mg::ChoicesController < Mg
  
  # GET /mg/choices
  # GET /mg/choices.xml
  def index
    @choices = Mg::Choice.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @choices }
    end
  end

  # GET /mg/choices/1
  # GET /mg/coihces/1.xml
  def show
    @choice = Mg::Choice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @choice }
    end
  end

  # GET /mg/tests/:test_id/choices/new
  # GET /mg/tests/:test_id/choices/new.xml
  def new
    @test = Mg::Test.find( params[:test_id] )
    @choice = Mg::Choice.new( :mg_test_id => @test.id )
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @choice }
    end
  end

  # GET /mg/choices/1/edit
  def edit
    @choice = Mg::Choice.find(params[:id])
  end

  # POST /mg/tests/:test_id/choices
  # POST /mg/tests/:test_id/choices.xml
  def create
    @test = Mg::Test.find( params[:choice][:mg_test_id] )
    @choice = Mg::Choice.new(params[:choice])

    if @choice.save
      flash[:notice] = 'Choice was successfully created.'
      redirect_to mg_test_url :id => @choice.mg_test.id 
    else
      render :action => "new"
    end
  end

  # PUT /mg/choices/1
  # PUT /mg/choices/1.xml
  def update
    @choice = Mg::Choice.find(params[:id])

    if @choice.update_attributes(params[:choice])
      flash[:notice] = 'Choice was successfully updated.'
      redirect_to mg_test_url :id => @choice.mg_test.id
    else
      render :action => "edit"
    end
  end

  # DELETE /mg/choices/1
  # DELETE /mg/choices/1.xml
  def destroy
    @choice = Mg::Choice.find(params[:id])
    @choice.destroy

    respond_to do |format|
      format.html { redirect_to mg_choices_url }
      format.xml  { head :ok }
    end
  end
end
