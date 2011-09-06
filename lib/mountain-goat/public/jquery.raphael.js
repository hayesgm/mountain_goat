/**
 * @author Geoff
 */

(function($) {
	function trace(s) {
  		try { console.log(s); } catch (e) { /* alert(s) */ }
	};	
	
	/* CONSTANTS */
	var txt = {font: '12px Helvetica, Arial', fill: "#d6d6d6", stroke: "#d6d6d6"};
	var txt1 = {font: '10px Helvetica, Arial', fill: "#fff"};
	var txt2 = {font: '12px Helvetica, Arial', fill: "#000"};
	var colorhue = .6 || Math.random();
	var color = "hsb(" + [colorhue, .5, 1] + ")";
	var normalLegend = {'fill': '#D6D6D6','font': '10px Helvetica, Arial', 'font-weight': '400'};
	var highlightedLegend = {'fill': '#FFFFFF','font-weight': '800'};

	Raphael.fn.drawGrid = function (x, y, w, h, wv, hv, color) {
	    color = color || "#000";
	    var path = ["M", Math.round(x) + .5, Math.round(y) + .5, "L", Math.round(x + w) + .5, Math.round(y) + .5, Math.round(x + w) + .5, Math.round(y + h) + .5, Math.round(x) + .5, Math.round(y + h) + .5, Math.round(x) + .5, Math.round(y) + .5],
	        rowHeight = h / hv,
	        columnWidth = w / wv;
	    for (var i = 1; i < hv; i++) {
	        path = path.concat(["M", Math.round(x) + .5, Math.round(y + i * rowHeight) + .5, "H", Math.round(x + w) + .5]);
	    }
	    for (i = 1; i < wv; i++) {
	        path = path.concat(["M", Math.round(x + i * columnWidth) + .5, Math.round(y) + .5, "V", Math.round(y + h) + .5]);
	    }
	    return this.path(path.join(",")).attr({stroke: color});
	};
	
	Raphael.fn.g.addChartLabels = function(chart, titles) {
 	    chart.labels = this.set();
 	    var x = 15; var h = 5;
 	    for( var i = 0; i < titles.length; ++i ) {
 	      var clr = chart.lines[i].attr("stroke");
 	      chart.labels.push(this.set());
 	      chart.labels[i].push(this.g["disc"](x + 5, h, 5)
 	                           .attr({fill: clr, stroke: "none"}));
 	      chart.labels[i].push(txt = this.text(x + 20, h, titles[i])
 	                           .attr(this.g.txtattr)
							   .attr(normalLegend)
 	                           .attr({"text-anchor": "start"}));
 	      x += chart.labels[i].getBBox().width * 1.2;
		  chart.labels[i].txt = txt;
		  chart.lines[i].legend = chart.labels[i];
 	    };
	};
	
	var hoverOver = function(e, r, chart) {
		trace(arguments);
		trace(this);
		trace(chart);
		trace(chart.frame);
		trace(this.attr("cx"));
		//trace(this.symbols[0]);
		if (typeof(chart.leave_timer) != "undefined" && chart.leave_timer != null) {
			clearTimeout(chart.leave_timer);
			chart.leave_timer = null;
		}
		
		if (!this.attr("cx")) {
			trace("whatever!");
			return;
		}
		
		var side = 3;
		trace([this.attr("cx") + chart.frame.getBBox().width, chart.width]);
		if (this.attr("cx") + chart.frame.getBBox().width > chart.width) {
			side = 1;
		}

		var data = parseInt(this.value);
		var lbl = this.axis;
		
		if (!data || !lbl) {
			//For non-labeled items
			return;
		}
		
		var label = chart.frame.label.clone();
		var clone = r.g.popupit(this.attrs.cx, this.attrs.cy, label, side).attr({fill: "#000", stroke: "#666", "stroke-width": 2, "fill-opacity": .7}).hide();
		
		chart.is_label_visible = chart.is_label_visible || false;
		
		chart.frame.show().stop().animate({ path: clone.attr("path") }, 200 * chart.is_label_visible );
		chart.frame.label[0].attr({text: data + " hit" + (data == 1 ? "" : "s")}).show().stop().animateWith(chart.frame, {x: label[0].attr("x"), y: label[0].attr("y")}, 200 * chart.is_label_visible );
		chart.frame.label[1].attr({text: newText = $.datepicker.formatDate('MM d', new Date(parseInt(lbl)))}).show().stop().animateWith(chart.frame, {x: label[1].attr("x"), y: label[1].attr("y")}, 200 * chart.is_label_visible );
		
		clone.remove();
		label.remove();
		
		//this.attr("r_normal", this.attr("r"));
		//this.attr("r", 15);
		chart.is_label_visible = true;
		
		//Let's also select the legend label
		this.line.legend.txt.attr(highlightedLegend);
		
		chart.labels.stop();
		var labelsBB = chart.axis.getBBox();
		var legendBB = this.line.legend.getBBox();
		var totalLabelsBB = chart.labels.getBBox();
		trace([labelsBB, legendBB, totalLabelsBB]);
		
		if (totalLabelsBB.width > labelsBB.width) {
			offset = ( labelsBB.width / 2.0 - legendBB.width / 2.0 + 20.0 /*adjustment*/ ) - legendBB.x;
			trace("Animate to " + offset);
			chart.labels.animate({'translation': [ offset, 0.0] }, 200);
		}
	};
	
	var hoverOut = function (e, r, chart) {
		//this.attr("r", this.attr("r_normal"));
		this.line.legend.txt.attr(normalLegend);
		
		chart.leave_timer = setTimeout(function () {
			chart.frame.hide();
			chart.frame.label.hide();
			chart.is_label_visible = false;
		}, 400);
	};
	
	var formatAxis = function(chart, axis, type) {
		if (type == "date") {
			$.each(chart.axis[axis].text.items, function(i, label) {
				//trace(label);
				originalText = label.attr('text');
	    		newText = $.datepicker.formatDate('m/dd', new Date(parseInt(originalText)));
	    		label.attr({'text': newText, 'fill': '#D6D6D6'});
			});
		} else {
			$.each(chart.axis[axis].text.items, function(i, label) {
				label.attr({'fill': '#D6D6D6'});
			});
		}
		chart.axis[axis].attr({'stroke': "#404040"});
	};
	
	$.fn.raphael = function() {
		return this.each(function() {
			var r = Raphael(this.id);
			var x, y, titles;
			var type = $(this).data('raphael') || "line";
			
			if ($(this).data('x') && $(this).data('y')) {
				x = eval('[' + $(this).data('x') + ']');
				y = eval('[' + $(this).data('y') + ']');
			} else {
				x = [];
				y = [];
				titles = [];
				var i = 0;
				while ($(this).data('x' + i) && $(this).data('y' + i)) {
					x.push(eval('[' + $(this).data('x' + i) + ']'));
					y.push(eval('[' + $(this).data('y' + i) + ']'));
					titles.push($(this).data('title' + i) || "Item " + i);
					i++;
				}
			}
			
			if (type == "line") {
				r.drawGrid(25, 25, $(this).width() - 50, $(this).height() - 50, 6, 5, "#333");
			
				var label = r.set();
				var chart = r.g.linechart(10, 10, $(this).width() - 20, $(this).height() - 20, x, y, { axis: "0 0 1 1", symbol: '', gutter: 15 } ).attr({x: x, y: y});
				chart.width = $(this).width() - 20;
				chart.height = $(this).height() - 20;
			
				if (titles != null) r.g.addChartLabels(chart, titles);
			
				var label = r.set(r.text(60, 12, "24 hits").attr(txt), r.text(60, 27, "22 September 2008").attr(txt1).attr({fill: color})).hide();
				chart.frame = r.g.popupit(100, 100, label, 1).attr({fill: "#fff", stroke: "#666", "stroke-width": 2, "fill-opacity": .7}).hide();
				chart.frame.label = label;
			
				chart.hover(function(e) { hoverOver.call(this, e, r, chart); }, function(e){ hoverOut.call(this, e, r, chart); } );
				formatAxis(chart, 0, $(this).data('x-axis'));
				formatAxis(chart, 1, $(this).data('y-axis'));
			} else if (type == "pie") {
				r.g.txtattr.font = txt;
				var pie = r.g.piechart($(this).width() / 2.2, $(this).height() / 2.0, Math.min($(this).width(), $(this).height()) / 2.4, y, {legend: x, legendcolor: "#d6d6d6", legendpos: "east", href: ["http://raphaeljs.com", "http://g.raphaeljs.com"]});
                pie.hover(function () {
                    this.sector.stop();
                    this.sector.scale(1.1, 1.1, this.cx, this.cy);
                    if (this.label) {
                        this.label[0].stop();
                        this.label[0].scale(1.5);
                        this.label[1].attr({"font-weight": 800});
                    }
                }, function () {
                    this.sector.animate({scale: [1, 1, this.cx, this.cy]}, 500, "bounce");
                    if (this.label) {
                        this.label[0].animate({scale: 1}, 500, "bounce");
                        this.label[1].attr({"font-weight": 400});
                    }
                });
			}			
			
		});
	};
	
	$(document).ready(function() {
		$('*[data-raphael]').raphael();
	});
	
})(jQuery);
			