
class Mg::TestsController < Mg
  
  # GET /mg/tests
  # GET /mg/tests.xml
  def index
    @tests = Mg::Test.all(:conditions => { :is_hidden => false } )
    @hidden_tests = Mg::Test.all(:conditions => { :is_hidden => true } )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tests }
    end
  end

  # TODO: Whhhhha?
  # GET /mg/tests/1
  # GET /mg/tests/1.xml
  def show
    @test = Mg::Test.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @test }
    end
  end

  # GET /mg/tests/new
  # GET /mg/tests/new.xml
  def new
    @test = Mg::Test.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @test }
    end
  end

  # GET /mg/tests/1/edit
  def edit
    @test = Mg::Test.find(params[:id])
  end

  # POST /mg/tests
  # POST /mg/tests.xml
  def create
    @test = Mg::Test.new(params[:test])

    if @test.save
      flash[:notice] = 'Test was successfully created.'
      redirect_to mg_test_url :id => @test.id
    else
      render :action => "new"
    end
  end

  # PUT /mg/tests/1
  # PUT /mg/tests/1.xml
  def update
    @test = Mg::Test.find(params[:id])

    if @test.update_attributes(params[:test])
      flash[:notice] = 'Test was successfully updated.'
      redirect_to mg_test_url :id => @test.id
    else
      render :action => "edit"
    end
  end

  # GET /mg/tests/1/hide
  # GET /mg/tests/1/hide.xml
  def hide
    @test = Mg::Test.find(params[:id])
    @test.update_attribute(:is_hidden, true)
    flash[:notice] = "Test #{@test.title} has been hidden."
    
    respond_to do |format|
      format.html { redirect_to mg_tests_url }
      format.xml  { head :ok }
    end
  end
  
  # GET /mg/tests/1/unhide
  # GET /mg/tests/1/unhide.xml
  def unhide
    @test = Mg::Test.find(params[:id])
    @test.update_attribute(:is_hidden, false)
    flash[:notice] = "Test #{@test.title} has been restored."
    
    respond_to do |format|
      format.html { redirect_to mg_tests_url }
      format.xml  { head :ok }
    end
  end
  
  # DELETE /mg/tests/1
  # DELETE /mg/tests/1.xml
  def destroy
    @test = Mg::Test.find(params[:id])
    @test.destroy

    respond_to do |format|
      format.html { redirect_to(mg_tests_url) }
      format.xml  { head :ok }
    end
  end
  
  #TODO: This only works if we are using cookie storage? Clear session as well
  def fresh_choices
    #clear choices
    #logger.warn "Headerish #{response.headers['cookie']}"
    
    cookies.each do |cookie|
      if cookie[0] =~ /test_([a-z0-9_]+)/
        logger.warn "Deleting cookie #{cookie[0]}"
        cookies.delete cookie[0]
      end
    end
    
    flash[:notice] = "Your tests have been cleared from cookies."
    redirect_to :back
  end
end
