#begin
#  require 'json'
#rescue LoadError
#  p "Flotilla will not work without the 'json' gem"
#end

module MGFlotilla
  module Helpers
      
    # Insert a flot chart into the page.  <tt>placeholder</tt> should be the 
    # name of the div that will hold the chart, <tt>collections</tt> is a hash 
    # of legends (as strings) and datasets with options as hashes, <tt>options</tt>
    # contains graph-wide options.
    # 
    # Example usage:
    #   
    #  chart("graph_div", { 
    #   "January" => { :collection => @january, :x => :day, :y => :sales, :options => { :lines => {:show =>true}} }, 
    #   "February" => { :collection => @february, :x => :day, :y => :sales, :options => { :points => {:show =>true} } },
    #   :grid => { :backgroundColor => "#fffaff" })
    # 
    # Options:
    #   :js_includes - includes flot library inline
    #   :js_tags - wraps resulting javascript in javascript tags if true.  Defaults to true.
    #   :placeholder_tag - appends a placeholder div for graph
    #   :placeholder_size - specifys the size of the placeholder div
    def mg_chart(placeholder, series, options = {}, html_options = {})
      html_options.reverse_merge!({ :js_includes => true, :js_tags => true, :placeholder_tag => true, :placeholder_size => "800x300", :pie_hover => false, :pie_hover_absolute => false })
      width, height = html_options[:placeholder_size].split("x") if html_options[:placeholder_size].respond_to?(:split)
      additional_js = mg_get_additional_js(placeholder, html_options)
      
      data, x_is_date, y_is_date = mg_series_to_json(series)
      if x_is_date
        options[:xaxis] ||= {}
        options[:xaxis].merge!({ :mode => 'time' })
      end
      if y_is_date
        options[:yaxis] ||= {}
        options[:yaxis].merge!({ :mode => 'time' })
      end

      if html_options[:js_includes]
        chart_js = <<-EOF
        <script type="text/javascript">
          (function () {
            if (typeof(jQuery) == 'undefined') {
              alert("Please include jQuery to view flot");
            } else {
              if (typeof(jQuery.plot) == 'undefined') {
                $('##{placeholder}').html("<span class='flot-error'>Please include jQuery.plot to view flot</span>");
              } else {
                var plot = jQuery.plot($('##{placeholder}'), #{data}, #{options.to_json});
                #{additional_js}
              }
            }
          })();
        </script>
        EOF
      else
        chart_js = <<-EOF
        (function () {
          if (typeof(jQuery) == 'undefined') {
            alert("Please include jQuery to view flot");
          } else {
            if (typeof(jQuery.plot) == 'undefined') {
              $('##{placeholder}').html("<span class='flot-error'>Please include jQuery.plot to view flot</span>");
            } else {
              var plot = jQuery.plot($('##{placeholder}'), #{data}, #{options.to_json});
              #{additional_js}
            }
          }
        })();
        EOF
      end        
      
      html_options[:js_tags] ? javascript_tag(chart_js) : chart_js
      output = html_options[:placeholder_tag] ? content_tag(:div, nil, :id => placeholder, :style => "width:#{width}px;height:#{height}px;", :class => "chart") + chart_js : chart_js
      output.html_safe
    end

    private
    def mg_series_to_json(series)
      data_sets = []
      x_is_date, y_is_date = false, false
      series.each do |name, values|
        set, data = {}, []
        set[:label] = name
        first = values[:collection].first
        logger.warn "Collection is: #{values[:collection].inspect}"
        if first #&& !values[:collection].is_a?(Array)
          if first.is_a?(Hash)
            x_is_date = first[values[:x]].acts_like?(:date) || first[values[:x]].acts_like?(:time)
            y_is_date = first[values[:y]].acts_like?(:date) || first[values[:y]].acts_like?(:time)
          else
            x_is_date = first.send(values[:x]).acts_like?(:date) || first.send(values[:x]).acts_like?(:time)
            y_is_date = first.send(values[:y]).acts_like?(:date) || first.send(values[:y]).acts_like?(:time)
          end
        end
        values[:collection].each do |object|
          if values[:collection].is_a?(Hash) || object.is_a?(Hash)
            x_value, y_value = object[values[:x]], object[values[:y]]
            #logger.warn "A: Object is: #{object}, x,y: #{[x_value, y_value]} from #{[values[:x], values[:y]]}"
          else
            x_value, y_value = object.send(values[:x]), object.send(values[:y])
            #logger.warn "B: Object is: #{object}, x,y: #{[x_value, y_value]}"
          end
          x = x_is_date ? x_value.to_time.to_i * 1000 : x_value.to_f
          y = y_is_date ? y_value.to_time.to_i * 1000 : y_value.to_f
          #logger.warn "Tally x,y: #{[x, y]}"
          data << [x,y]
        end
        set[:data] = data
        values[:options].each {|option, parameters| set[option] = parameters } if values[:options]
        data_sets << set
      end
      return data_sets.to_json, x_is_date, y_is_date
    end

    def mg_get_additional_js(placeholder, options)
      res = ""
      if options[:pie_hover]
        res << <<-EOF
           function showTooltip(x, y, contents) {
              $('<div id="tooltip">' + contents + '</div>').css( {
                  position: 'absolute',
                  //display: 'none',
                  top: y + 5,
                  left: x + 5,
                  border: '1px solid #fdd',
                  padding: '2px',
                  'background-color': '#fee',
                  opacity: 0.80
              }).appendTo("body");//.fadeIn(200);
          }
       
          var previousPoint = null;
          $('##{placeholder}').bind('mouseout', function() {
            plot.unhighlight();
            $("#tooltip").remove();
            $(this).data('previous-post', -1);
          });
          
          $('##{placeholder}').bind('plothover', function(event, pos, item) {
            if (item) {
              if ($(this).data('previous-post') != item.seriesIndex) {
                plot.unhighlight();
                plot.highlight(item.series, item.datapoint);
                $(this).data('previous-post', item.seriesIndex);
              }
              $("#tooltip").remove();
              #{ options[:line_hover_absolute] ? "y = 'on ' + (new Date(item.datapoint[0])).toDateString() + ': ' + item.datapoint[1] + ' #{options[:item_title] || ''}'" : !options[:pie_hover_absolute] ? "y = item.datapoint[0].toFixed(0) + '%';" : "y = item.datapoint[1][0][1] + ' #{options[:item_title] || ''}'" } 
              showTooltip(pos.pageX, pos.pageY, item.series.label + " " + y);
            } else {
              //console.log('unhighlight (3)');
              plot.unhighlight();
              $("#tooltip").remove();
              previousPost = $(this).data('previous-post', -1);
            }
          });
        EOF
      end
      
      res
    end
  end
end

class ActionView::Base
  include MGFlotilla::Helpers
end
