# Mountain-Goat

Embed a professional analytics and reporting platform into your application in minutes.  Gain important business insights through bandit (automated a/b) testing, view the results and analytics in real time, and get delivered daily or weekly usage reports. 

Note: For updating from version < 1.0.0, please read the **Upgrade** section below.

Add simple hooks in your code to display a/b metrics

     <%= bd(:homescreen_text, "Welcome here") %>
  
This creates a database entry for your a/b test "homescreen_text".  Visit "http://yourdomain.com/mg" and you can add / adjust choices for this text.  When a user completes a goal, you run the following code.
  
  	 #e.g. users_controller.rb
     def create
       rw(:user_signup, 10) # Reward 10 points
       ...
     end

This will track a record not only for the goal, but for the choice of "homescreen_text" that the user was served when he or she came to the home-page.

Bandit testing (see [Wikipedia - Multi-armed Bandit](http://en.wikipedia.org/wiki/Multi-armed_bandit) automatically converges on the variant that achieves the highest success through exploration each variant.  You essentially get a Bayesian solution with no hassle! 

The best part?  The Mountain-Goat Administrative console is located on your server and you can view and analyze your data in real time (or through setting up usage report emails).

 - See which metric variants are working and not working ("Cowabunga!" did 120% better than "Enter here", but 10% worse than "Do it rockapella!")
 - Get daily / weekly / whenever emails delivered to your inbox, full of the data you crave (e.g. Signs up by day / comments by referring domain )
 - Similar to Bayesian learning, Multi-armed bandit solutions will automatically deliver the highest performing variants
 - This is done while still achieving minimal (logarithmically decreasing) regret (showing of poorer performing variants)
 - A/B testing?  How about A/B/C/D/E testing?  Add as many variants as you like.
 - Visually analyze the your choices; change them on the fly, adding new ones or kicking out poor performers.
 - Watch goals complete in real-time with live-action console (grab the popcorn and watch how your users "sign up" and "view items" and ...)
 - You can do more than change text, "switch variants" let you enter arbitrary ruby code, change the control of your site ("Do my users have to sign-in before commenting?  Let's test!")
 - Track goals with meta data (rw(:user_signup, 10, :referrer => request.env['HTTP_REFERER']))
   * Mountain goat tracks as much arbitrary meta data as you want
   * You are presented with charts for each goal, broken down by meta
   * See what referrers are driving goals, or which of your blog posts are drawing an audience
 - Much, much more, e.g. deliver views of this data to your consumers, streamline your site, customize it by user, it's all up to you. 

For more information, read my blog post on how mountain goat quickly accomplishes a/b testing: http://blog.drawn.to/how-we-do-ab-testing

## Upgrade from < 1.0.0

If you are upgrading from Mountain Goat < 1.0.1, please run the following command (please overwrite mountain-goat.yml when prompted):

     ./script/generate mg --update=1.0.0,1.0.1

     rake db:migrate
     
This will install new migrations necessary for version 1.0.1.  Leave out the 1.0.0 from the command if you are upgrading from version 1.0.0.
 
## Install

### Mountain Goat gem

     gem install mountain-goat

### Mountain Goat configuration
    
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
	
- Goals are what you want  E.g. "user purchases coffee"
- Tests are how you draw people to complete a goal  E.g. "a banner on the store-front"
- Choices are A/B tests for tests  E.g. "free coffee" "chuck norris inside"
	
After you set up your database with some mountain-goat tables, the code will handle populating these tables for you.  In your code, you can start A/B testing immediately.
	
     <h2><%= bd(:banner_on_store_front, "Now arsenic and gluten-free") %></h2>
	
The bandit (bd) function takes two parameters:
	
     bd(metric_name, default)
	
This will automatically create a `test` and populate a `choice` with the default value.  Easy, eh?

From here, you can go into the mountain goat admin center and add new `choices` to fit your need.  It's all built into *your* application, in house. 

     http://{your_rails_app}/mg  (e.g. if you're at railsrocks.com, then visit http://railsrocks.com/mg)

The other important code you'll need to implement is to tell the system when a goal is achieved.
	
     def purchase #in coffees_controller.rb
       rw(:user_purchases_coffee, 10) #10 "points"
       ...
     end
	
This will go in and record a goal (a `record`) for a user purchasing coffee.  Further, it will track a hit for any choices served to that user.  For example "Chuck Norris works here" might get reward points.  You will see which test choices lead to a goal; this is the core of A/B and bandit testing.

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

## Mountain Goat Admin Suite

Navigate to /mg in your rails application (on your actual server instance) to reach the mountain-goat admin center.  Here, you can analyze / adjust your A/B tests.

The front page gives you a breakdown of each of your Goals, and the efficacy of each test and its choices.  Select a given test to drill into its choices.  Once you are in a specific test page, you'll be able to add new choices and see what works best for your clients.

###Goals

Goals show you what users are doing.  Are they purchasing coffee?  Are they logging in?  Are they posting flames on your message board?  You can measure all of these things!

In the Goals section, you'll get a break down of your goals and what tests are leading in reward points.  Don't see anything here?  Add some tests / goals / choices from the code above.  Hint: Add meta data (see below) to see meta data associated with your records.

###Tests

Go to `Tests` and visit a specific test.  You'll see which choices are getting the highest rewards.  Does having a large font on the homescreen draw more people into signing up, or does it turn people away?  This is where you can check and see.  Click 'New Choice' below to add additional variants for testing.

* Click into a test to explore (see above on how to create tests from within your code-base)
* Charts show you visually which choices are doing better than others
* "Add Choice" to add new variants for this test

###Records

Records shows you what's going on, in real time.  You will see goals being hit by your clients in real time.  Grab a bag of popcorn and watch users struggle (or glide) across your site.  Add meta data to get further information.   This page automatically updates as new records come in.

###Reports

In the Mountain Goat Administrative suite, you can add reports.  Reports will be delivered as emails with an attached pdf showing statistics about your product.  You'll need the following installed to use Mountain Goat Reports.

Funnel reports will display your goals as a flow of conversions across the site.  For instance, you may choose "hits" then "sign ups" then "purchases" and see how the funnel changes through these different goals.

####Daily / Weekly Reports

To get reports delivered to your inbox, first install the following gems:

     gem install pdfkit
     gem install svg-graph

You'll need [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) installed.  Please configure the location of the executable in `mountain-goat.yml`.

Finally, simply set up a cron task on your system when you would like your reports delivered.  E.g.

     crontab -l | { cat; echo "45 6 * * * cd /path/to/project && /usr/bin/rake RAILS_ENV=production mg:deliver[daily] >> /path/to/project/log/cron.log 2>&1"; } | crontab -
     crontab -l | { cat; echo "10 6 1 * * cd /path/to/project && /usr/bin/rake RAILS_ENV=production mg:deliver[monthly]  >> $app_root/current/log/cron.log 2>&1"; } | crontab -     
     
## Advanced Features

### Meta data
    
You can track meta-data with any goal.  E.g.
    
     rw(:user_visit, 10, :referring_domain => request.env['HTTP_REFERER'], :user_id => session[:user_id])
    
These will be stored with the record for the goal and can get used for complex analytics down the line.  (see Goals.meta)
    
### Switch variants
    
Instead of just serving text, you can also serve flow control in Mountain Goat, like so:
    
      bds(:user_discount, :purchase_coffee) do |variant|
      
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

Mountain goat will automatically break those down into three cases (:ten_percent, :big_winner, :whomp_whomp) and serve them out to users using bandit methodology.
    
### Meta Options

There is certain meta data that you may wish to collect for a number of different goals.  For example, you may want to track IP-address so you can later pivot this column to find new / returning users.  To do this, add an initializer that calls MountainGoat.add_meta_option().

     MountainGoat.add_meta_option(:stats) do |c|
       { :ip => c.request.remote_ip }
     end
     
Then, simply add ':stats => true' to your `rw` call.  This will call into your block and replace the key-pair with the map returned from the block.  E.g.

     rw(:user_login, 20, :login => @user.login, :stats => true)
     
Then, when we track the conversion, you'll get meta-data for the user's IP-address.  You can add any number of "meta-options" that you would like.

### Mountain-Goat.yml

You can configure Mountain-Goat configuration through `config/mountain-goat.yml`.  There are application-wide settings and environment-specific settings.  E.g.

     settings:
       epsilon: 0.85
       strategy: e-greedy
       storage: session
   
     development:
       password: your-password
       wkhtmltopdf: /usr/local/bin/wkhtmltopdf

- Settings:
  * `Epsilon` - How often should Bandit deliver the best `choice` versus a random `choice`.  The idea is that we want to deliver the best choice ("Free Donuts When you Sign-Up") versus new (or less successful) choices ("Now Arsenic Free!").  0.85 means the system will deliver the best result 85% of the time (for strategy `e-greedy`)
  * `Strategy` - Choice of "e-greedy", "e-greedy-decreasing" or "a/b".  For E-Greedy, as above, best case will be delivered epsilon-percent of the time.  For E-Greedy decreasing, this will decrease over time (so after a thousand tests, only the best result will be displayed).  Finally, a/b will ignore epsilon and always deliver a random choice.
  * `Storage` - Should we store user choices in `session` or through `cookies`?  This is used to track the choices delivered to a user so we can reward points to these choices when the user completes a goal.  Cookies will also help ensure the page is consistent across many sessions (e.g. if you a/b test the background image, do you want it to be the same the next day for a user)
- Environment:
  * `Password` - Password to access Mountain Goat Admin Suite on this environment.  Choose a very secure password (a mix of letters, numbers, and symbols).
  * `wkhtmltopdf` - Path to wkhtmltopdf executable for reports.  E.g. *Nix: `/usr/local/bin/wkhtmltopdf`, Windows: `C:\Program Files (x86)\wkhtmltopdf\wkhtmltopdf.exe` 
 
## Technical

As mountain goat is a suite that is added into your project dynamically, the following models and tables are added during setup:

- ActiveRecord Models
  * Mg::GiMeta - Integer-typed meta data for Records (e.g. 'Click Count')
  * Mg::GoalMetaType - Meta-types for Records
  * Mg::Goal - Goals (e.g. 'Page View', 'User Sign-up')
  * Mg::GsMeta - String-typed meta data for Records (e.g. 'Referring domain')
  * Mg::Choice - Variant for a/b testing (e.g. 'Come see our store!')
  * Mg::Test - Test to vary for a/b testing (e.g. 'Homescreen Text')
  * Mg::Record - Instance of a goal completion (e.g. when a user clicks sign up)
  * Mg::ReportItem - Item to show in a report (e.g. Sign ups by day)
  * Mg::Report - Report to deliver (e.g. collection of user report items)

- Database Tables
  * mg_gi_metas
  * mg_goal_meta_types
  * mg_goals
  * mg_gs_metas
  * mg_choices
  * mg_tests
  * mg_records
  * mg_report_items
  * mg_reports
  
## Change log
  1.0.1 - Renamed objects to reflect real-world thinking (e.g. metric => test)
        - Fixed glitch in bandit choice selection
  1.0.0 - Changed from a/b testing to multi-armed bandit
        - Added Mountain Goat Reporting
        - Added extensive test cases for stability
        
## TODO
 - Better documentation (rdocs)

## Copyright

Copyright (c) 2011 Geoffrey Hayes, meloncard.com. Contact me, Geoff, <geoff@meloncard.com> with any questions / ideas / enhancements.  See LICENSE for details.
