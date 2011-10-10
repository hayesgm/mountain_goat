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
		
		if ($('.recent-record[data-reload="true"]').size() > 0) {
			setTimeout(function() { reloadRecords(); }, 4000);
		}
		
		$('.reload').click(function() { reloadRecords(); });
		
		var reloadRecords = function() {
			var record_id = parseInt($('.recent-record').data('record-id'));
			var goal_id = $('.recent-record').data('goal-id');
			if (record_id) {
				$.ajax({
						url: '/mg/records/new_records',
						data: { 'recent_record': record_id, 'goal_id': goal_id },
						success: function(json) {
							if (!json.success) {
								console.log('No new events');
							} else {
								$('.recent-record').data('record-id', json.recent_record_id);
								res = $(json.result);
								res.hide().prependTo($('.record-list')).fadeIn(3000);
								$('ul.record-list > li.record:gt(100)').remove(); //only show 100 elements
								
								if ($('.record-list abbr.time-ago').size() > 0) {
									$('.record-list abbr.time-ago').timeago();	
								}
							}
							
							if ($('.recent-record[data-reload="true"]').size() > 0) {
								setTimeout(function() { reloadRecords(); }, 4000);
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
