/**********************/
/*  Wavelength        */
/*    Geoffrey Hayes  */
/*    Robert Leshner  */
/*    ChattrLLC, 2011 */
/**********************/

/*************************************/
/*                                   */
/* UTILS.JS                          */
/*                                   */
/* General utilities                 */
/* that are properly namescoped      */
/* (more and more functions should   */
/*  move into this file)             */
/*                                   */
/*  Requirements:                    */
/*   JQuery                          */
/*                                   */
/*************************************/
 
var Panther = function() {
	
	/**********************/
	/*  Private variables */
	/**********************/
	
	var debugMessages = null;
	var loadingHTML = "<div class=\"loading\"></div>"
	var baseURL;
	var ajaxRequests = [];
	var deviceReady = false;
	var discreet = '';
	
	var deviceTypes = {
		iphone: /iphone/i,
		ipod: /ipod/i,
		ipad: /ipad/i,
		android: /android/i,
		blackberry: /blackberry/i,
		windows: /windows ce/i,
		palm: /palm/i,
		symbian: /symbian/i
	}
	
	/**********************/
	/*  Private functions */
	/**********************/
	
	var bind = function(scope, fn) {
    	return function () {
        	fn.apply(scope, arguments);
    	};
	};
	
	var extend = function(obj1, obj2) { 
		var result = obj1, val;
		for (val in obj2) {
			if (obj2.hasOwnProperty(val)) {
				result[val] = obj2[val];
			}
		}
		return result;
	};
	
	//If pathOrURL is a relative path (e.g. /users/1), then we return a qualified
	// URL, such as http://mydomain.com/users/1
	// otherwise, we return the URL as is
	//TODO: considerations? what is path doesn't start with /
	var qualifyURL = function(pathOrURL) {
		//if (!(new RegExp('^(http(s)?[:]//)','i')).test(pathOrURL)) {
		//	return baseURL + pathOrURL;
		//}
		
		return pathOrURL;
	};
	
	var stopDownloads = function() {
	    if (window.stop !== undefined) {
	        window.stop();
	    }
	    else if (document.execCommand !== undefined) {
	        document.execCommand("Stop", false);
	    }   
	};
	
	/**********************/
	/*  TODO: Initialize  */
	/**********************/
	
	var getDeviceType = function() {
		for (j in deviceTypes) {
			if (deviceTypes[j].test(navigator.userAgent)) {
				return j;
			}
		}
		return '';
	};
	
	$(document).ready(function() {
		baseURL = $('body').data('base-url');
		$('body').data('browser', getDeviceType());
		$('body').addClass(getDeviceType());
	});
	
	return {
	
		invalidIPhoneApp: function() {
			return getDeviceType() == 'iphone' && window.navigator.standalone != true;
		},
		
		//This is used to ensure we are an iPhone web app status
		enforceIPhoneApp: function(path) {
			 if (this.invalidIPhoneApp() && !(new RegExp(path, 'i')).test(window.location)) {
				this.ajax(path, '.hand-off', null, { doLoading: true, isDomChange: true, isPageTransition: true } );
				return false;
			}
			
			return true;
		},
		
		determineDeviceType: function() {
			return getDeviceType();
		},
		
		isMobile: function() {
			this.debugMessage("Navigator: " + navigator.userAgent);
			return /(iphone|ipod|ipad|android|blackberry|windows ce|palm|symbian)/i.test(navigator.userAgent);
		},
		
		isDeviceReady: function() {
			return deviceReady;
		},
		
		setDeviceReady: function(ready) {
			deviceReady = ready;
		},
		
		refreshPage: function() {
			window.location.reload();
		},
		
		sortObject: function(o) {
			var sorted = {},
			key, a = [];

			for (key in o) {
				if (o.hasOwnProperty(key)) {
					a.push(key);
				}
			}

			a.sort();

			for (key = 0; key < a.length; key++) {
				sorted[a[key]] = o[a[key]];
			}
			return sorted;
		},  
		
		//TODO: What's the difference between loading and inline-loading?
		displayLoading: function(el) {
			$(el).addClass('loading');
			$('body').addClass('loading');
			$('body').bind('domChange removeLoading', function() { $(el).removeClass('loading').removeClass('inline-loading'); $('body').removeClass('loading'); } );
		},
		
		displayInlineLoading: function(el) {
			if (el != "" && typeof(el) != "undefined") {
				$(el).addClass('inline-loading');
				that = this;
				$(el).bind('contentChange', function() { $(el).removeClass('loading').removeClass('inline-loading'); } );
			}
		},
		
		displayNotice: function(noticeMessage) {
			//Clear error and vice versa  ??
			noticeMessage = noticeMessage || '';
		
			if ((n = $('.notice')).size() > 0) {
				n.text(noticeMessage); //TODO: fade after some time?
			}
		},
	
		displayError: function(errorMessage) {
			errorMessage = errorMessage || '';
		
			if ((e = $('.error')).size() > 0) {
				e.text(errorMessage); //TODO: fade after some time?
			}
		},
		
		discreetMessage: function(text) {
			discreet += text;
			$('.discreetMessages').text(discreet);
			this.sendSystemStats(discreet); //send this to the server	
		},
		
		//TODO: Get this fast for non-debug
		//TODO: Why isn't this working?
		//This is our core debug message for device debugging
		debugMessage: function(text) {
			date = new Date();
			if (debugMessages != null || (debugMessages = $('.debugMessages')).size() > 0) {
				debugMessages.prepend('<div style="">' + text + '</div>');
				//console.log(text + ' - ' + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds());
			} else {
				//console.log(text + ' - ' + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds());
			}
		},
		
		checkPath: function(url) {
			//return /([a-z0-9/%?&-])+/i.test(path)
			return true;
		},
		
		sendJscriptError: function(error) {
			try {
				this.debugMessage('JS Error: ' + error);
				var history = '';
				try {
					history = $('body').data('back');
				} catch (ex) { }
				
				if (baseURL) {
					$.ajax({
						url: baseURL + '/jserror',
						type: 'get',
						dataType: 'json',
						data: { 'error': error, 'history': history }
					}); //Don't catch return
				}	//else: default?
			} catch (ex) {
				//it's buried, what can we do?
			}
		},
		
		//This is the start of our "User Health" stats-- we need to get better at tracking/understanding this
		//So that we know if clients are working or broken-- and by user-agent
		sendSystemStats: function(stats) {
			try {
				this.debugMessage('System Stats: ' + stats);
				var history = '';
				try {
					history = $('body').data('back');
				} catch (ex) { }
				
				if (baseURL) {
					$.ajax({
						url: baseURL + '/system/stats',
						type: 'get',
						dataType: 'json',
						data: { 'stats': stats, 'history': history }
					}); //Don't catch return
				}	//else: default?
			} catch (ex) {
				//it's buried, what can we do?
			}
		},
		
		onError: function(ex) {
			this.debugMessage('Javascript Error: <em>' + ex + '</em>');
			this.sendJscriptError(ex);
		},
		
		redirectTo: function(url) {
			this.debugMessage('Redirecting to ' + url);
			
			this.ajax(url, '.hand-off', null, { doLoading: true, isDomChange: true, isPageTransition: true } );
		},
		
		goBack: function() {
			backList = $('body').data('back').split(';');
			if (backList.length == 0) { return; /* do nothing */ }
			
			backList.pop(); //current page
			path = backList.pop(); //previous page
			$('body').data('back', backList.join(';'));
				
			Panther.debugMessage('Remote-page to ' + path);
			Panther.ajax(path, '.hand-off', '', { 'doLoading': true, 'isDomChange': true, 'context': this, 'isPageTransition': true } );
		},
		
		goThis: function() {
			path = $('body').data('this');
			
			Panther.debugMessage('Remote-page to ' + path);
			Panther.ajax(path, '.hand-off', '', { 'doLoading': true, 'isDomChange': true, 'context': this, 'isPageTransition': true } );
		},
		
		abortActiveAjax: function() {
			while (ajaxRequests.length > 0) {
				ajaxRequests.pop().abort();
			}
		},
		
		//TODO: We can probably get more out of this in the future
		trackAnalytics: function(url, res, params, options) {
			try {
				if (typeof(_gaq) != "undefined") {
					_gaq.push(['_trackPageview', url]);
					for (j in options) {
						if (!(new RegExp('password', 'i')).test(j)) {
							_gaq.push(['_setCustomVar', 1, j, options[j], 3]);
						}
					}
				}
			} catch (e) {
				//do nothing
			}
		},
		
		ajaxFileUpload: function(url, fileUpload, successUrl) {
			try {
				$.ajaxFileUpload({
					url: qualifyURL(url),
					fileElementId: fileUpload,
					dataType: 'json',
					success: function(data, status) {
						return;
						if ( ( typeof(data.error) != 'undefined' ) && data.error == '' ) {
							//Panther.redirectTo(successUrl);
						} else {
							Panther.displayError("Sorry, we are experiencing technical difficulties.");
						}
					},
					error: function (data, status, e) {
						return;
						Panther.displayError("Sorry, we are experiencing connectivity difficulties.");
					}
				});	
			}
			catch (ex) {
				this.onError(ex);
			}
		},
		
		//TODO: Unload even on error
		ajax: function(url, res, params, options) {
			try {
			
				//this.debugMessage('Panther ajax starting');
				this.trackAnalytics(url, res, params, options);
				
				var ajaxRequest = null;
				
				defaultOptions = {
					'doLoading': false,
					'doInlineLoading': false,
					'isDomChange': false,
					'method': 'get',
					'context': document,
					'trigger': null,
					'isPageTransition': false, //this will cancel all occuring ajax requests, even non-page transitions
					'hasFile': false //set context to containing form
				//I separate this from isDomChange just because it's rather volitle
				
				};
				
				//Setup Defaults
				params = params || '';
				options = extend(defaultOptions, options || {});
				
				this.debugMessage('Panther ajax ' + url + '?' + params + ' to ' + res);
				
				//Check if what we are res'ing to exists
				if (typeof(res) != "undefined" && res != "" && res != null) {
					if ($(res).size() == 0) {
						Panther.displayError("Invalid result area");
						return;
					}
					if (options.doLoading) {
						this.displayLoading($(res));
					}
					else 
						if (options.doInlineLoading) {
							this.displayInlineLoading($(res));
						}
				}
				
				//If isPageTransition, we are going to abort all current requests (they are outdated, by definition)
				if (options.isPageTransition) {
					while (ajaxRequests.length > 0) {
						ajaxRequests.pop().abort();
					}
					
					//stopDownloads(); //hit the imaginary 'Stop' button
				}
				
				that = this;
				
				var ajaxOptions = {
					url: qualifyURL(url),
					type: options.method,
					dataType: 'json',
					context: options.context,
					data: params,
					iframe: true,
					success: function(json) {
						that.debugMessage('Panther ajax response');
						
						if (json.redirect) {
							if (json.window) {
								auth_window = window.open(json.redirect, json.window, json.windowOptions || "");
							} else {
								window.location.href = json.redirect;	
							}
						}
						
						if (!json.success) {
							if (json.message) {
								that.displayError(json.message);
							}
							else {
								that.displayError('Sorry, we are experiencing some difficulties.')
							}
							$('body').trigger('error', $(this));
							$('body').trigger('removeLoading'); //we need to kill the blocking div on an error
							$(this).trigger('error', [json.result]);
						}
						else {
							if (typeof(json.forward_to) != "undefined" && json.forward_to.length > 0 && Panther.checkPath(json.forward_to)) {
								that.redirectTo(json.forward_to);
								return;
							}

							$(this).trigger('result', [json.result, json]); //custom result handling
							if (res != null && res != "" && typeof(res) != "undefined") {
								if (typeof(json.result) == "undefined") {
									//eh, whatever!
									//that.displayError("Sorry, we are experiencing technical difficulties.");
									//return;
								}
								else {
									$(document).trigger('inject', [res, json.result]);
									$(res).trigger('contentChange'); //Trigger a content change on _res
									if (options['isDomChange']) {
										$('body').trigger('domChange'); //We've done something
									}
									
									if ($(res).data('model')) {
										$($(res).data('model')).jqm().jqmShow();
									}
								}
							}

							//State handling for updates
							var oldState;
							
							if (json.state) {
								oldState = $(json.state.item).data('state');
								$(json.state.item).data('state', json.state.value);
							}
							
							if (json.also) {
								$.each(json.also, function (i, also) {
									if (!(json.depends && oldState && json.depends != oldState)) {
										$(document).trigger('inject', [also.item, also.result, also.action]);	
									}
								});
							}

							//Clear the error and call 'finish' event
							that.displayError();
							$(this).trigger('finish', [json, res]);
						}
					},
					error: function(json){
						that.displayError('We are having difficulties connecting to the server.');
						$('body').trigger('removeLoading'); //we need to kill the blocking div on an error
						$('body').trigger('error', $(this));
					}
				};
				
				if (options.hasFile) {
					ajaxRequest = $(options.context).ajaxSubmit(ajaxOptions);
					return;
				} else {
					ajaxRequest = $.ajax(ajaxOptions);
				}
				
				//Keep the array accurate by removing when we return
			
				ajaxRequest.complete(bind(this, function(jqXHR, textStatus) {
					//this.debugMessage('Removing ajax');
					//Here, we'll also call any specific triggers
					$(options.context).trigger('complete');
					if (options.trigger != null) {
						this.debugMessage('Triggering custom trigger: ' + options.trigger);
						$('body').trigger(options.trigger, $(this));
					} else {
						$('body').trigger(textStatus, $(this));
					}
					
					return; //do we need any of this now?
					if (options.isPageTransition && options.method != 'post') { //don't add post to back log
						//Panther.debugMessage('DataBack (before): ' + $('body').data('back') + ", URL: " + url);
						backList = $('body').data('back').split(';');
						backList.push(url);
						$('body').data('back', backList.slice(-5).join(';'));
						//Panther.debugMessage('DataBack (after): ' + $('body').data('back'));
					}
					
					ajaxRequests.splice(ajaxRequests.indexOf(ajaxRequest),1);
					
				 }));
				 
				//Add this request to the heap
				ajaxRequests.push(ajaxRequest);
				
				//this.debugMessage('Current ajaxes ' + ajaxRequests.length);
				
				return ajaxRequest;
			}
			catch (ex) {
				this.onError(ex);
			}
		}
	};
}();
