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
			setTimeout(function() { reloadRallies(); }, 3000);
		}
		
		$('.reload').click(function() { reloadRallies(); });
		
		var reloadRallies = function() {
			var rally_id = parseInt($('.recent-rally').data('rally-id'));
			var convert_id = $('.recent-rally').data('convert-id');
			if (rally_id) {
				$.ajax({
						url: '/mg/rallies/new',
						data: { 'recent_rally': rally_id, 'convert_id': convert_id },
						success: function(json) {
							if (!json.success) {
								console.log('No new events');
							} else {
								$('.recent-rally').data('rally-id', json.recent_rally_id);
								$('.rally-list').prepend($(json.result));
								
								$('.rally-list li:gt(100)').remove(); //only show 100 elements
							}
							
							if ($('.recent-rally[data-reload="true"]').size() > 0) {
								setTimeout(function() { reloadRallies(); }, 3000);
							}
						}
				});	
			}
		};
	});
	
	
})();
