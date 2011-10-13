/*
 * g.Raphael 0.4.1 - Charting library, based on Raphaël
 *
 * Copyright (c) 2009 Dmitry Baranovskiy (http://g.raphaeljs.com)
 *               2011 Geoffrey Hayes (http://github.com/hayesgm)
 * Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) license.
 */
Raphael.fn.g.funnelchart = function (cx, cy, cw, ch, values, opts) {
    opts = opts || {};
    var paper = this,
        sectors = [],
        covers = this.set(),
        chart = this.set(),
        series = this.set(),
		insetLabels = this.set(),
        order = [],
        len = values.length,
        angle = 0,
        total = 0,
        others = 0,
        cut = 9,
        defcut = true,
		max = 0.0,
		sh = ch / ( len + 0.0 );
    chart.covers = covers;
	
	function trap(x0, y0, w0, w1, h) {
		path = ['M', x0, y0, 'H', x0 + w0, 'L', ( w0 - w1 ) / 2.0 + x0 + w1, y0 + h, 'H', ( w0 - w1 ) / 2.0 + x0, 'Z'];
		return path;
	};
    
	var labeltext;
	for (var i = 0; i < len; i++) {
      total += values[i];
	  max = max > values[i] ? max : values[i] + 0.0;
	  
	  if (opts.legend && opts.legend.length > i)
	  	labeltext = opts.legend[i];
		
      values[i] = {value: values[i], order: i, valueOf: function () { return this.value; }, labeltext: labeltext};
    }
    
	//values.sort(function (a, b) {
    //  return b.value - a.value;
    //});
	
    for (i = 0; i < len; i++) {
		
		var sx0 = ( cx + (cw / 2.0 ) - cw * ( values[i] / ( 2.0 * max ) ) );
		var sy0 = cy + sh * i;
		var w0 = values[i] * cw / max;
		var w1 = ( i < len - 1 ) ? values[i + 1] * cw / max : 0;
		
    	if (opts.init) {
    		var ipath = trap(sx0, sy0, w0, w1, sh).join(",");
    	}
      	//console.log([sx0, sy0, w0, w1, sh]);
		var path = trap(sx0, sy0, w0, w1, sh);
		var p = this.path(path).attr({fill: opts.colors && opts.colors[i] || this.g.colors[i] || "#666", stroke: opts.stroke || "#fff", "stroke-width": (opts.strokewidth == null ? 1 : opts.strokewidth), "stroke-linejoin": "round"});
		if (values[i].labeltext)
			p.insetLabel = this.text(sx0 + w0 / 2.0, sy0 + sh / 3.0, values[i].labeltext + ( i > 0 ? ( " " + ( ( values[i] * 100 / values[i - 1] ).toFixed(2) ) + "%" ) : "")).attr({font: "20px Helvetica", stroke: "#fff", fill: "#bbb", "fill-opacity": 0.95, "stroke-opacity": 0 });
			
    	p.value = values[i];
    	sectors.push(p);
    	series.push(p);
    	opts.init && p.animate({path: path.join(",")}, (+opts.init - 1) || 1000, ">");
    }
	
    for (i = 0; i < len; i++) {
        p = paper.path(sectors[i].attr("path")).attr(this.g.shim);
        opts.href && opts.href[i] && p.attr({href: opts.href[i]});
        p.attr = function () {};
        covers.push(p);
        series.push(p);
    }

    chart.hover = function (fin, fout) {
        fout = fout || function () {};
        var that = this;
        for (var i = 0; i < len; i++) {
            (function (sector, cover, j) {
                var o = {
                    sector: sector,
                    cover: cover,
                    cx: cx,
                    cy: cy,
                    cw: cw,
					ch: ch,
                    value: values[j],
                    total: total,
                    label: that.labels && that.labels[j]
                };
                cover.mouseover(function () {
                    fin.call(o);
                }).mouseout(function () {
                    fout.call(o);
                });
            })(series[i], covers[i], i);
        }
        return this;
    };
    // x: where label could be put
    // y: where label could be put
    // value: value to show
    // total: total number to count %
    chart.each = function (f) {
        var that = this;
        for (var i = 0; i < len; i++) {
            (function (sector, cover, j) {
                var o = {
                    sector: sector,
                    cover: cover,
                    cx: cx,
                    cy: cy,
                    x: sector.middle.x,
                    y: sector.middle.y,
                    mangle: sector.mangle,
                    r: r,
                    value: values[j],
                    total: total,
                    label: that.labels && that.labels[j]
                };
                f.call(o);
            })(series[i], covers[i], i);
        }
        return this;
    };
    chart.inject = function (element) {
        element.insertBefore(covers[0]);
    };
    var legend = function (labels, otherslabel, mark, dir) {
        var x = cx + cw * 1.7,
            y = cy,
            h = y + 10;
        labels = labels || [];
        dir = (dir && dir.toLowerCase && dir.toLowerCase()) || "east";
        mark = paper.g.markers[mark && mark.toLowerCase()] || "disc";
        chart.labels = paper.set();
        for (var i = 0; i < len; i++) {
            var clr = series[i].attr("fill"),
                j = values[i].order,
                txt;
            values[i].others && (labels[j] = otherslabel || "Others");
            labels[j] = paper.g.labelise(labels[j], values[i], total);
            chart.labels.push(paper.set());
            chart.labels[i].push(paper.g[mark](x + 5, h, 5).attr({fill: clr, stroke: "none"}));
            chart.labels[i].push(txt = paper.text(x + 20, h, labels[j] || values[j]).attr(paper.g.txtattr).attr({fill: opts.legendcolor || "#000", "text-anchor": "start"}));
            covers[i].label = chart.labels[i];
            h += txt.getBBox().height * 1.2;
        }
        var bb = chart.labels.getBBox(),
            tr = {
                east: [0, -bb.height / 2],
                west: [-bb.width - cw - 20, -bb.height / 2],
                north: [-cw - bb.width / 2, -cw - bb.height - 10],
                south: [- ( cw / 2 ) - bb.width / 2, ( cw / 2 ) + 10]
            }[dir];
        chart.labels.translate.apply(chart.labels, tr);
        chart.push(chart.labels);
    };
    if (opts.legend) {
        legend(opts.legend, opts.legendothers, opts.legendmark, opts.legendpos);
    }
    chart.push(series, covers);
    chart.series = series;
    chart.covers = covers;
    return chart;
};