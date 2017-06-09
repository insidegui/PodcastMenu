PodcastMenuLook = new function(){
	this.scrollHidden = true;
	
    function overrideContextMenu() {
        document.addEventListener('contextmenu', function(e) {
          e.preventDefault();
        }, false);
    }
    overrideContextMenu();
    
	function injectStyle() {
		document.styleSheets[0].insertRule('html { overflow: auto; }', 0);
		document.styleSheets[0].insertRule('body { position: absolute; top: 5px; left: 0; bottom: 5px; right: 5px; padding: 5px; overflow-y: scroll; overflow-x: hidden; }', 0);
		document.styleSheets[0].insertRule('::-webkit-scrollbar { width: 1px; opacity:0; }', 0);
		document.styleSheets[0].insertRule('::-webkit-scrollbar-track { background: #eee; }', 0);
		document.styleSheets[0].insertRule('::-webkit-scrollbar-thumb { -webkit-border-radius: 10px; border-radius: 10px; background: rgba(252,126,15,0.8); }', 0);
		document.styleSheets[0].insertRule('::-webkit-scrollbar-thumb:window-inactive { background: rgba(252,126,15,0.4); }', 0);
		document.styleSheets[0].insertRule('input.podcastsearchbox { width: 115px; }', 0);
        
        // DARK MODE
        document.styleSheets[0].insertRule('body.pm-dark-mode { color: #fff !important; background-color: #303333 !important; }');
        document.styleSheets[0].insertRule('a.pm-dark-mode, .linkcolor.pm-dark-mode, .extendedepisodecell.usernewepisode.pm-dark-mode .title { color: #49B5BE !important; }');
        document.styleSheets[0].insertRule('.ocbutton.pm-dark-mode, .ocborderedbutton.pm-dark-mode, .ocsegmentedbutton.pm-dark-mode { display: inline-block !important; }');
        document.styleSheets[0].insertRule('.ocborderedbutton.pm-dark-mode, .ocsegmentedbutton.pm-dark-mode { border: 1px solid #49B5BE !important; }');
        document.styleSheets[0].insertRule('.ocborderedbutton.pm-dark-mode:active, .ocsegmentedbuttonselected.pm-dark-mode { background-color: #49B5BE !important; }');
        document.styleSheets[0].insertRule('.feedcell.pm-dark-mode, .episodecell.pm-dark-mode { color: #FFF !important; }');
        document.styleSheets[0].insertRule('.feedcell.pm-dark-mode:hover, .episodecell.pm-dark-mode:hover, .extendedepisodecell.pm-dark-mode:hover { background-color: rgba(15, 126, 252, 0.05) !important; }');
        document.styleSheets[0].insertRule('.extendedepisodecell.pm-dark-mode { color: #FFF !important; }');
        document.styleSheets[0].insertRule('.art.pm-dark-mode { border: 1px solid #666 !important; }');
        document.styleSheets[0].insertRule('input.podcastsearchbox.pm-dark-mode {  background-color:black !important;  box-shadow:none !important;  border:1px solid #6f6f6f !important;  color:white !important; }');
        document.styleSheets[0].insertRule('a.autocomplete_result.pm-dark-mode { color: #eee !important; }');
        document.styleSheets[0].insertRule('.autocomplete_result.pm-dark-mode h4 { color: #eee !important; }');
        document.styleSheets[0].insertRule('.ocfeedlistinput.pm-dark-mode .wildcard_result { background-color: #BFE6DE !important; }');
        document.styleSheets[0].insertRule('.ocfeedlistinput.pm-dark-mode .excluded_result { background-color: #BFE6DE !important; }');
        document.styleSheets[0].insertRule('#upload_progress.pm-dark-mode { color: #49B5BE !important; }');
        document.styleSheets[0].insertRule('#upload_progress.pm-dark-mode::-webkit-progress-bar { background-color: #49B5BE !important; }');
        document.styleSheets[0].insertRule('#progresssliderbackground.pm-dark-mode { border: 1px solid #666 !important; }');
        document.styleSheets[0].insertRule('#progresssliderbackground.pm-dark-mode::-webkit-progress-value { background-color: #BFE6DE !important; }');
        document.styleSheets[0].insertRule('#progressslider.pm-dark-mode::-webkit-slider-thumb { background: #49B5BE !important; }');
        document.styleSheets[0].insertRule('.progresssliderloadedrange.pm-dark-mode { background-color: #49B5BE !important; }');
        document.styleSheets[0].insertRule('#speedcontrol.pm-dark-mode::-webkit-slider-runnable-track { background-color: #BFE6DE !important; }');
        document.styleSheets[0].insertRule('#speedcontrol.pm-dark-mode::-webkit-slider-thumb { background: #49B5BE !important; }');
        document.styleSheets[0].insertRule('#stripe-checkout-button.pm-dark-mode { background-color: #49B5BE !important; color: #fff !important; }');
        document.styleSheets[0].insertRule('.adtext.pm-dark-mode { color: #FFF !important; }');
        document.styleSheets[0].insertRule('input.pure-input-1.pm-dark-mode {  background-color:black !important;  box-shadow:none !important;  color:white !important; }');
        document.styleSheets[0].insertRule('.nav.pm-dark-mode { border-bottom: 1px solid #444 !important; }');
	}
	injectStyle();

    this.toggleDarkMode = function(enabled) {
        if (enabled) {
            $("*").addClass("pm-dark-mode");
        } else {
            $("*").removeClass("pm-dark-mode");
        }
    }
    
	this.hideScroll = function() {
		if (this.scrollHidden) return;
		this.scrollHidden = true;
		
		var self = this;
		
		var currentRule = null;
		var currentOpacity = 1.0;
		var hideScrollAnimStep = function() {
			var targetSheet = document.styleSheets[document.styleSheets.length - 1];
			
			// if (currentRule != null) targetSheet.removeRule(currentRule);
		
			currentOpacity -= 0.05;
			if (currentOpacity <= 0.1) currentOpacity = 0;
		
			currentRule = "opacity:"+currentOpacity;
			targetSheet.addRule("::-webkit-scrollbar", currentRule);
			
			if (currentOpacity <= 0.0) {
				currentRule = null;
				return;
			}
		
			requestAnimationFrame(hideScrollAnimStep);
		}
		hideScrollAnimStep();
	}

	this.showScroll = function() {
		if (!this.scrollHidden) return;
		this.scrollHidden = false;
		
		var self = this;
		
		if (self.showStyle) return;
		
		var currentRule = null;
		var currentOpacity = 0.0;
		var showScrollAnimStep = function() {
			var targetSheet = document.styleSheets[document.styleSheets.length - 1];
			
			// if (currentRule != null) targetSheet.removeRule(currentRule);
		
			currentOpacity += 0.1;
			if (currentOpacity >= 0.9) currentOpacity = 1;
		
			currentRule = "opacity:"+currentOpacity;
			targetSheet.addRule("::-webkit-scrollbar", currentRule);
			
			if (currentOpacity >= 1.0) {
				currentRule = null;
				return;
			}
		
			requestAnimationFrame(showScrollAnimStep);
		}
		showScrollAnimStep();
	}
}();
