/**
 * @author Geoff
 */

(function() {
	$(document).ready(function () {
		$('input.slider[type="checkbox"]').change(function() {
			if ($(this).is(':checked')) {
				$($(this).data('slider')).slideDown();
			} else {
				$($(this).data('slider')).slideUp();
			}
		}).change();
		
		if ($('.recent-rally[data-reload="true"]').size() > 0) {
			setTimeout(function() { reloadRallies(); }, 4000);
		}
		
		$('.reload').click(function() { reloadRallies(); });
		
		var reloadRallies = function() {
			var rally_id = parseInt($('.recent-rally').data('rally-id'));
			var convert_id = $('.recent-rally').data('convert-id');
			if (rally_id) {
				$.ajax({
						url: '/mg/rallies/new_rallies',
						data: { 'recent_rally': rally_id, 'convert_id': convert_id },
						success: function(json) {
							if (!json.success) {
								console.log('No new events');
							} else {
								$('.recent-rally').data('rally-id', json.recent_rally_id);
								res = $(json.result);
								res.hide().prependTo($('.rally-list')).fadeIn(3000);
								$('ul.rally-list > li.rally:gt(100)').remove(); //only show 100 elements
								
								if ($('.rally-list abbr.time-ago').size() > 0) {
									$('.rally-list abbr.time-ago').timeago();	
								}
							}
							
							if ($('.recent-rally[data-reload="true"]').size() > 0) {
								setTimeout(function() { reloadRallies(); }, 4000);
							}
						}
				});	
			}
		};
		
		if ($('abbr.time-ago').size() > 0) {
			$('abbr.time-ago').timeago();	
		}
		
		var pantherFormSubmit = function(e, obj) {
			e.preventDefault();
			
			$(this).trigger('pre-submit', [e, obj]);
			path = $(this).attr('action');
			res = $(this).data('res');
			
			Panther.ajax(path, res, $(this).serialize(), { 'doInlineLoading': true, 'method': 'post', 'context': this } );
		}
		
		$('.remote-form.report-item').live('finish', function(e, json, res) {
			if (json.close_dialog) {
				$('.jqmWindow').jqmHide(); //close these first	
			}
		});
		
		$('form.remote-form').submit(pantherFormSubmit);
		
		$('.remote-link').live('click', function(e, obj) {
			e.preventDefault();
			path = $(this).data('path');
			res = $(this).data('res');
			
			Panther.ajax(path, res, '', { 'doInlineLoading': true, 'context': this } );
		});
		
		$('*[data-varies]').each(function() {
			var that = $(this);
			that.bind($(this).data('varies'), function() {
				Panther.ajax( that.data('varies-url'), that.data('varies.res'), { value: that.val() } );
			});
		});
		
		$(document).bind('inject', function(e, selector, html, action) {
			if (!action || action == "inject") {
				$(selector).html(html);
				
			} else if (action == "prepend") {
				$(selector).prepend($(html));	
			}
		});
		
		$(document).bind('inject', function(e, selector, html) {
			$(selector).find('form.remote-form').submit(pantherFormSubmit);
			$(selector).find('*[data-varies]').each(function() {
				$(this).bind($(this).data('varies'), function() {
					console.log([$(this).data('varies-path'), $(this).data('varies-res'), { value: $(this).val() }]);
					Panther.ajax( $(this).data('varies-path'), $(this).data('varies-res'), { value: $(this).val() } );
				});
			});
		});
	});	
})();
