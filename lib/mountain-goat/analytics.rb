class Analytics
  #extend Garb::Model

  #metrics :exits, :pageviews, :unique_pageviews
  #dimensions :page_path, :date
  
  #filters do
  #  contains(:page_path, '/xxx')
  #end
  
  def self.pivot(item, dimension)
    item.sort! do |x,y|
    #logger.warn "x: #{x.send(:date)}, y: #{y.send(:date)}"
      x.send(dimension) <=> y.send(dimension)
    end
    
    item
    #item.map { |res| { dimension => res.send(dimension), value => res.send(value) } }
  end
  
  def self.insert_missing_dates_as_zero_through_today(item, dimension, start, valuemap)
    #assume sorted object-- and that dates are on day-intervals
    
    result = []
    running_date = start #item[0].send(dimension)
    i = 0

    while running_date < ( Date.today + 1 )
      if i >= item.count
        break if running_date >= Date.today #skip missing data for today
        result.push( { dimension => running_date }.merge(valuemap) )
      else
        if running_date < item[i].send(dimension)
          result.push( { dimension => running_date }.merge(valuemap) )
        elsif running_date == item[i].send(dimension)
          map = { dimension => running_date }
          valuemap.each do |dim, val|
            map[dim] = item[i].send(dim)
          end
          result.push(map)
          i += 1
        else
          raise "Dates dont align on time"
          #running_date > item[i], we've run over the end of the list
        end
      end
      
      running_date = running_date + 1
    end
    
    result
  end
  
  def self.convert_date_to_javascript_time(item, dimension)
    item.each do |i|
      date = i.send(dimension)
      i[dimension] = Time.utc(date.year, date.month, date.day).to_i * 1000
    end
  end
  
  def self.pivot_hash_to_titled(map)
    res = []
    res_titles = {}
    i = 0
    
    map.each do |k,v|
      res.push( { :name => i, :val => v.to_i } )
      res_titles.merge!({ i => k })
    end
    
    [res, res_titles]
  end
  
  def self.options_for_titled_chart(h, t)
    { :collection => h, :x => :name, :y => :val }
  end
  
  def self.options_for_pie_chart(h)
    res = {}
    h.each do |k, v|
      res.merge!( k => { :collection => [{ :x => 1, :val => v.to_i }], :x => :x, :y => :val, :options => { :color => "##{hash_color( k )}" } })
    end
    res
  end
  
  def self.options_for_line_chart(h)
    res = {}
    h.each do |k, v|
      title = k || "Direct"
      res.merge!( title => { :collection => v, :x => :x, :y => :y, :options => { :color => "##{hash_color( title )}" }} )
    end

    res
  end
  
  
  def self.hash_color(str)
     s = ( ( 7.times.map { str }.join.hash ** 2 ) % 2**24 ).to_s(16)
     (6 - s.length).times.map { "0" }.join << s
  end
 
  def self.pivot_by_date(collection, start_date, end_date = Time.zone.now)
    #assume sorted object-- and that dates are on day-intervals
    
    result = {}
    start_date -= 60 * 60 * 24 #no day 0??
    end_date += 60 * 60 * 30 #let's just push this forward a bit..
    
    running_date = Date.new(start_date.year, start_date.month, start_date.day) #item[0].send(dimension)
    end_date = Date.new(end_date.year, end_date.month, end_date.day) #item[0].send(dimension)
    indices = {}
    collection.each { |source,dates| indices.merge!({ source => 0 }); result[source] = [] }
    #puts indices.inspect
    while running_date < end_date
      collection.each do |source, value|
        #Get the index in the current channel
        i = indices[source]
        
        #Otherwise, let's count the dates
        v = 0
        v += 1 and i += 1 while i < value.length && value[i] > running_date && value[i] < (running_date + 1)
        
        #Store results back
        indices[source] = i
        result[source].push( { :x => running_date, :y => v } )
      end
      
      running_date = running_date + 1
    end
  
    #result.each { |s| s.sort }
    result
  end
end