# Mountain-Goat

Embed a professional analytics platform into your application in minutes.  Gain important business insights through bandit (automated a/b) testing, view the results and analytics in real time, and get delivered daily or weekly usage reports. 

Add simple hooks in your code to display a/b metrics

     <%= bd(:homescreen_text, "Welcome here") %>
  
This creates a database entry for your a/b test "homescreen_text".  Visit "http://yourdomain.com/mg" and you can add / adjust options (variants) for this text.  When a user converts on a goal, you run the following code.
  
  	 #e.g. users_controller.rb
     def create
       record_conversion(:user_signup)
       ...
     end

This will track a conversion not only for the goal, but for the variant of "homescreen_text" that the user was served when your user came to the home-page.

Bandit testing (see [Wikipedia - Multi-armed Bandit](http://en.wikipedia.org/wiki/Multi-armed_bandit) automatically converges on the variant that achieves the highest success through exploration each variant.  You essentially get a Bayesian solution with no hassle! 

The best part?  The Mountain-Goat Administrative console is located on your server and you can view and analyze your data in real time (or through setting up usage report emails).

 - See which metric variants are working and not working ("Cowabunga!" did 120% better than "Enter here", but 10% worse than "Do it rockapella!")
 - Get daily / weekly / whenever emails delivered to your inbox, full of the data you crave (e.g. Signs up by day / comments by referring domain )
 - Similar to Bayesian learning, Multi-armed bandit solutions will automatically deliver the highest performing variants
 - This is done while still achieving minimal (logarithmically decreasing) regret (showing of poorer performing variants)
 - A/B testing?  How about A/B/C/D/E testing?  Add as many variants as you like.
 - Visually analyze the your metric variants; change them on the fly, adding new ones or kicking out poor performers.
 - Watch goal conversions in real-time with live-action console (grab the popcorn and watch how your users "sign up" and "view items" and ...)
 - You can do more than change text, "switch variants" let you enter arbitrary ruby code, change the control of your site ("Do my users have to sign-in before commenting?  Let's test!")
 - Track goals with meta data (record_conversion(:user_signup, :referrer => request.env['HTTP_REFERER']))
   * Mountain goat tracks as much arbitrary meta data as you want
   * You are presented with charts for each goal, broken down by meta
   * See what referrers are driving goals, or which of your blog posts are drawing an audience
 - Much, much more, e.g. deliver views of this data to your consumers, streamline your site, customize it by user, it's all up to you. 

For more information, read my blog post on how mountain goat quickly accomplishes a/b testing: http://blog.drawn.to/how-we-do-ab-testing

## Upgrade from < 1.0.0

If you are upgrading from Mountain Goat < 1.0.0, please run the following command (please overwrite mountain-goat.yml when prompted):

     ./script/generate mg --update
     
     rake db:migrate
     
This will install new migrations necessary for version 1.0.0.
 
## Install

### Mountain Goat gem

     gem install mountain-goat

### Mountain Goat configration
    
Next run generator to create config file and necessary database migration (optionally pass in --password=my_mg_password)
     
     ./script/generate mg
    
This will generate

     /config/mountain-goat.yml (for storing a password to access mountain-goat)
     /db/migrate/xxx_create_mountain_goat_tables.rb (necessary database migrations to store mg data)
     /lib/tasks/mountain_goat_reports.rake (add tasks for report delivery)

Modify /config/mountain-goat.yml to setup a password for each environment of your product

     development:
       password: my-mountain-goat-password

Run your new migration

    db:migrate
    
## Usage

Mountain Goat hinges around three core concepts:
	
- Conversions are what you want  E.g. "user purchases coffee"
- Metrics are how you draw people to convert  E.g. "a banner on the store-front"
- Metric variants are A/B tests for metrics  E.g. "free coffee" "chuck norris is inside"
	
After you set up your database with some mountain-goat tables, the code will handle populating these tables for you.  In your code, you can start A/B testing immediately.
	
     <h2><%= bd(:banner_on_store_front, "Now arsenic and gluten-free") %></h2>
	
The bandit (bd) function takes two parameters:
	
     bd(metric_name, default)
	
This will automatically create a metric and populate a metric variant with the default value.  Easy, eh?

From here, you can go into the mountain goat admin center and add new metric variants to fit your need.  It's all built into *your* application, in house. 

     http://{your_rails_app}/mg  (e.g. if you're at railsrocks.com, then visit http://railsrocks.com/mg)

The other important code you'll need to implement is to tell the system when a goal is achieved.
	
     def purchase #in coffees_controller.rb
       rw(:user_purchases_coffee, 10) #10 "points"
       ...
     end
	
This will go in and record a conversion (a "rally") for a user purchasing coffee.  Further, it will track a hit for any metric-variants served to that user.  For example "Chuck Norris works here" might get reward points.  You will see which metrics lead to a conversion; this is the core of A/B and bandit testing.

## Bandit Testing

Why points?  Bandit testing is about maximizing a return.  The original idea is if I have a slot machine with 30 handles each with different payouts, how do I maximize my return?  You pull the arm that has given you the best pay out so far, but occasionally pull other arms to make sure there's not something better.  Mountain-Goat's Bandit system will do the same for you.

The most common solution to the multi-armed bandit solution is epsilon-greedy (documented [here](http://www.cs.nyu.edu/~mohri/pub/bandit.pdf)).

     Given epsilon in [0, 1] #commonly 0.05 - 0.15
     
     If any variant has never been pulled
       Pull that variant
     Otherwise
     
       If random(0..1) < epsilon
         Pull random arm
       Else
         Pull winning arm #highest "reward"
	   End

This way, we most commonly explore the best arm (e.g. your best slogan) while occasionally trying other arms.

A small variant on this is called epsilon-greedy-decreasing, which reduces epsilon each pull by 1/total_pulls.  Thus, after 100 pulls, epsilon = epsilon_0 / 100.  This is shown to have an optimal minimal expectation of regret.

You can configure these options in `mountain-goat.yml`.

## Mountain Goat admin suite

Navigate to /mg in your rails application (on your actual server instance) to reach the mountain-goat admin center.  Here, you can analyze / adjust your A/B tests.

The front page gives you a breakdown of each of your Goals, and the efficacy of each metric and metric-variant.  Select a given metric to drill into its variants.  Once you are in a specific metric, you'll be able to add new metric-variants and see what works best for your clients.

###Goals

Goals show you what users are doing.  Are they purchasing coffee?  Are they logging in?  Are they posting flames on your message board?  You can measure all of these things!

In the Goals section, you'll get a break down of your goals and what metrics are leading in conversions.  Don't see anything here?  Add some metrics / goals / metric-variants from the code above.  Hint: Add meta data (see below) to see meta data associated with your conversions

###Metrics

Go to "Metrics" and visit a specific metric.  You'll see which metric variants are getting the highest conversion rates.  Does having the font on the homescreen large draw more people into signing up, or does it turn people away?  This is where you can check and see.  Click 'New variant' below to add additional variants for testing.

* Click into a metric to explore (see above on how to create metrics from within your code-base)
* Charts show you visually which variants are doing better than others
* "Add variant" to add new variants for this metric

###Rallies

Rallies shows you what's going on, in real time.  You will see conversions (goals) being hit by your clients in real time.  Grab a bag of pop-corn and watch users struggle (or glide) across your site.  Add meta data to get further information.   This page automatically updates as new rallies come in.

###Reports

In the Mountain Goat Administrative suite, you can add reports.  Reports will be delivered as emails with an attached pdf showing statistics about your product.  You'll need the following installed to use Mountain Goat Reports.

     gem install pdfkit
     gem install svg-graph

You'll need [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) installed.  Please configure the location of the executable in `mountain-goat.yml`.

Finally, simply set up a cron task on your system when you would like your reports delivered.  E.g.

     crontab -l | { cat; echo "45 6 * * * cd /path/to/project && /usr/bin/rake RAILS_ENV=production mg:deliver[daily] >> /path/to/project/log/cron.log 2>&1"; } | crontab -
     crontab -l | { cat; echo "10 6 1 * * cd /path/to/project && /usr/bin/rake RAILS_ENV=production mg:deliver[monthly]  >> $app_root/current/log/cron.log 2>&1"; } | crontab -     
     
## Advanced Features

### Meta data
    
You can track meta-data with any conversion.  E.g.
    
     rc(:user_visit, :referring_domain => request.env['HTTP_REFERER'], :user_id => session[:user_id])
    
These will be stored with the rally for the conversion and can get used for complex analytics down the line.  (see Converts.meta)
    
### Switch variants
    
Instead of just serving text, you can also serve flow control in Mountain Goat, like so:
    
      sv(:user_discount, :purchase_coffee) do |variant|
      
        variant.ten_percent do # "ten_percent" is the variant-name
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
    
### Meta Options

There is certain meta data that you may wish to collect for a number of different conversions.  For example, you may want to track ip-address so you can later pivot this column to find new / returning users.  To do this, add an initializer that calls MountainGoat.add_meta_option().

     MountainGoat.add_meta_option(:stats) do |c|
       { :ip => c.request.remote_ip }
     end
     
Then, simply add ':stats => true' to your record_conversion call.  This will call into your block and replace the key-pair with the map returned from the block.  E.g.

     record_conversion(:user_login, :login => @user.login, :stats => true)
     
Then, when we track the conversion, you'll get meta-data for the user's ip-address.  You can add any number of "meta-options" that you would like.

## Technical

As mountain goat is a suite that is added into your project dynamically, the following routes and tables are added during setup:

- Tables
  * ci_metas (indexes: ci_metas_cmt_data_index, ci_metas_cmt_index, ci_metas_rally_index)
  * convert_meta_types
  * converts
  * cs_metas (indexes: cs_metas_cmt_data_index, cs_metas_cmt_index, cs_metas_rally_index)
  * metric_variants
  * metrics
  * rallies

- Routes
  * map.mg '/mg', :controller => :mountain_goat_converts, :action => :index
  * map.mg_login '/mg/login', :controller => :mountain_goat, :action => :login
  * map.mg_login_create '/mg/login/create', :controller => :mountain_goat, :action => :login_create
  * map.resources :mountain_goat_metric_variants
  * map.resources :mountain_goat_converts, :has_many => [ :mountain_goat_metrics, :mountain_goat_rallies ]
  * map.resources :mountain_goat_metrics, :has_many => :mountain_goat_metric_variants
  * map.resources :mountain_goat_rallies
  * map.new_rallies '/mg/rallies/new', :controller => :mountain_goat_rallies, :action => :new_rallies 
  * map.fresh_metrics '/fresh-metrics', :controller => :mountain_goat_metrics, :action => :fresh_metrics
  * map.connect '/mg/public/:file', :controller => :mountain_goat, :action => :fetch
    
## TODO
 - Better documentation (rdocs)
 - Add namespacing to avoid conflicts

## Copyright

Copyright (c) 2011 Geoffrey Hayes, drawn.to. Contact me, Geoff, <geoff@drawn.to> with any questions / ideas / enhacements.  See LICENSE for details.
