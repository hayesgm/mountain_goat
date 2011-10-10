
class SwitchVariant    
    def initialize(logger, metric, chosen_variant)
      @chosen_variant = chosen_variant  
      @metric = metric
      @logger = logger
      raise ArgumentError, "Metric type must be switch-type" if !@metric.is_switch
    end
    
    def method_missing(sym, *args, &block)
      #priority = ( args.first || 1.0 ).to_f
      
      if @chosen_variant.nil?
        #If we have not chosen a variant, we are going to look through
        # each option and make sure we have a back-end entry in metric_variants
        # for the type
        @logger.warn "Looking at option #{sym.to_s}"
        if @metric.metric_variants.find( :first, :conditions => { :switch_type => sym.to_s } ).nil?
          @logger.warn "Creating switch-type metric-variant #{sym.to_s}"
          @metric.metric_variants.create!( :name => sym.to_s, :switch_type => sym.to_s, :value => nil )
        end
      else
        if @chosen_variant.switch_type.to_s == sym.to_s
          @logger.warn "Executing option #{sym.to_s}"
          yield
        else
          @logger.warn "Bypassing option #{sym.to_s}"
        end
      end
    end
  
  end