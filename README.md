# Mountain-Goat

Embed a high-quality analytics platform in your application in minutes.  Gain important A/B test business insights, and view the results and analytics in real time.

Add simple hooks in your code to display a/b metrics

  metric_variant(:homescreen_text, :user_signup, "Welcome here")
  
This creates a database entry to a/b test "homescreen_text" against a goal "user signup".  Visit "http://yourdomain.com/mg" and you can add / adjust options (variants) for this text.  When a user converts on this goal, you run the following code.
  
  record_conversion(:user_signup)

This will track a conversion not only for the goal, but for the variant of "homescreen_text" (and any other associated metrics) that the user was served when he came to the home-page.

The best part?  The mountain-goat admin console is located on your server and you can view and analyze your data in real time.

 - See which metric variants are working and not working ("Cowabunga!" did 120% better than "Enter here", but 10% worse than "Do it rockapella!")
 - Visually analyze the your metric variants; change them on the fly, adding new ones.
 - You can do more than change text, "switch variants" let you enter arbitrary ruby code, change the control of your site ("Do my users have to sign-in before commenting?  Let's test!")
 - Track goals with meta data (record_conversion(:user_signup, :referrer => request.env['HTTP_REFERER']))
   * Mountain goat tracks as much arbitrary meta data as you want
   * You are presented with charts for each goal, broken down by meta
   * See what referrers are driving goals, or which of your blog posts are drawing an audience
 - Much, much more, e.g. deliver views of this data to your consumers, streamline your site, customize it by user, it's all up to you. 

## Install

### Mountain Goat gem

    gem install mountain-goat

### Mountain Goat configration
    
    #Next run generator to create config file and necessary database migration (optionally pass in --password=my_mg_password)
     
    ./script/generate mg
    
    #This will generate
    #  /config/mountain-goat.yml (for storing a password to access mountain-goat)
    #  /db/migrate/xxx_create_mountain_goat_tables.rb (necessary databae migrations to store mg data)

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
 - Better documentation (rdocs)
 - Add namespacing to avoid conflicts

## Copyright

Copyright (c) 2011 Geoffrey Hayes, drawn.to. Contact me, Geoff, <geoff@drawn.to> with any questions / ideas / enhacements.  See LICENSE for details.
