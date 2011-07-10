# Mountain-Goat

Embed a high-quality analytics platform in your application in minutes.  Gain important A/B test business insights, and view the results and analytics in real time.

## Install

### Mountain Goat gem

    gem install mountain-goat
	
	#Note, you'll need to install the proper migrations (currently in the migrations folder, task coming shortly)

## Usage

	Mountain Goat hinges around three core concepts:
	
	  *) Conversions are what you want  E.g. "user purchases coffee"
	  *) Metrics are how you draw people to convert  E.g. "a banner on the store-front"
	  *) Metric variants are A/B tests for metrics  E.g. "free coffee" "chuck norris is inside"
	
	After you set up your database with some mountain-goat tables, the code will handle populating these tables for you.  In your code, you can start A/B testing immediately.
	
	<h2><%= metric_variant(:banner_on_store_front, :user_purchases_coffee, "Now arsenic and gluten-free") %></h2>
	
	The metric_variant function (or mv for short) takes three parameters:
	
	mv(metric_name, convert_name, default)
	
	This will automatically create a metric and conversion and populate a metric variant with the default value.  Easy, eh?
	
	From here, you can go into the mountain-goat admin center and add new metric variants to fit your need.
	
	The other important code you'll need to implement is when a goal is achieved.
	
	def purchase #coffees_controller.rb
	  record_conversion(:user_purchases_coffee)
	  ...
	end
	
	This will go in and record a conversion ("rally") for a user purchasing coffee.  Further, it will track a hit for any metric-variants served to that user that relate to this goal.  For example "Chuck Norris works here" might get a point.
	
## Mountain Goat admin suite

    Navigate to /mg in your application to reach the mountain-goat admin center.  Here, you can analyze / adjust your A/B tests.
    
    The front page gives you a breakdown of each of your Goals, and the efficacy of each metric and metric-variant.  Select a given metric to drill into its variants.  Once you are in a specific metric, you'll be able to add new metric-variants and see what works best for your clients.
    
## Advanced Features

    ### Meta data
    
    You can track meta-data with any conversion.  E.g.
    
    rc(:user_visit, :referring_domain => request.env['HTTP_REFERER'], :user_id => session[:user_id])
    
    These will be stored with the rally for the conversion and can get used for complex analytics down the line.  (see Converts.meta)
    
    ### Switch variants
    
    Instead of just serving text, you can also serve flow control in Mountain Goat, like so:
    
    sv(:user_discount, :purchase_coffee) do |variant|
      variant.ten_percent do
        discount = 0.10
      end
      
      variant.big_winner do
        discount = 0.90
      end
      
      variant.whomp_whomp do
        discount = 0.0
      end
    end

    Mountain goat will automatically break those down into three cases (:ten_percent, :big_winner, :whomp_whomp) and serve them out at random to the user.
    
    ### Priorities
    
    You may want to test certain items with a lower serve rate (bold new slogans).  You can assign priorities to any metric variant.  The change of a given metric variant being shown is
    
    my priority / sum(all priorities for this metric)    
    
## TODO
 - work on getting migrations better

## Copyright

Copyright (c) 2011 Geoffrey Hayes, drawn.to. See LICENSE for details.
