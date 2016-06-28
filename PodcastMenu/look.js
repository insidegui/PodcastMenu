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
	}
	injectStyle();

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