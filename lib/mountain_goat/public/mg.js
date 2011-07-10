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
	});
})();
