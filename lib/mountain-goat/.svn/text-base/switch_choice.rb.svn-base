
class SwitchChoice
    def initialize(logger, test, chosen_choice)
      @chosen_choice = chosen_choice
      @test = test
      @logger = logger
      raise ArgumentError, "Test type must be switch-type" if !@test.is_switch
    end
    
    def method_missing(sym, *args, &block)
      #priority = ( args.first || 1.0 ).to_f
      
      if @chosen_choice.nil?
        #If we have not chosen a choice, we are going to look through
        # each option and make sure we have a back-end entry in choices
        # for the type
        @logger.warn "Looking at option #{sym.to_s}"
        if @test.choices.find( :first, :conditions => { :switch_type => sym.to_s } ).nil?
          @logger.warn "Creating switch-type choice #{sym.to_s}"
          @test.choices.create!( :name => sym.to_s, :switch_type => sym.to_s, :value => nil )
        end
      else
        if @chosen_choice.switch_type.to_s == sym.to_s
          @logger.warn "Executing option #{sym.to_s}"
          yield
        else
          @logger.warn "Bypassing option #{sym.to_s}"
        end
      end
    end
  
  end