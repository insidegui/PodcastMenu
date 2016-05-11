var progressbar = document.querySelector('#progressbar');

if (progressbar && typeof(progressbar) != 'undefined') {
    location.hash = "#progressbar";
    document.querySelector('#progressbar').style.paddingTop = '10px';
}

var audio = null;

function installAudioPipeline() {
	try {
		var bridge = null;
		if (typeof(window.webkit) != 'undefined') {
			if (typeof(window.webkit.messageHandlers) != 'undefined') {
				bridge = window.webkit.messageHandlers.PodcastMenuApp;
			}
		}
		
		if (audio == null || typeof(audio) == 'undefined') return;
	
		audio.pause();

		var context = new webkitAudioContext();
		var source = context.createMediaElementSource(audio);

		var analyser = context.createAnalyser();

		analyser.smoothingTimeConstant = 0.3;
		analyser.fftSize = 1024;

		var processor = context.createScriptProcessor(2048, 1, 1);

		source.connect(analyser);
		analyser.connect(processor);
		processor.connect(context.destination);
		source.connect(context.destination);

		function convertRange( value, r1, r2 ) { 
			return ( value - r1[ 0 ] ) * ( r2[ 1 ] - r2[ 0 ] ) / ( r1[ 1 ] - r1[ 0 ] ) + r2[ 0 ];
		}

		processor.onaudioprocess = function() {
			if (audio.paused) return;
			
			var array = new Uint8Array(analyser.frequencyBinCount);
	
			analyser.getByteFrequencyData(array);
			var average = getAverageVolume(array);
	
			if (bridge) {
				bridge.postMessage(average);
			} else {
				console.log(average);
			}
		}

		function getAverageVolume(array) {
			var values = 0;
			var average;

			var length = array.length;
	
			for (var i = 0; i < length; i++) {
				values += array[i];
			}

			average = values / length;
			return average;
		}

		context.startRendering();
	} catch(e) {
		console.log(e);
	}
}

$(function(){
	var findAudioInterval = setInterval(function(){
		audio = document.querySelector('audio');
		if (audio != null) {
			clearInterval(findAudioInterval);
			installAudioPipeline();
		}
	}, 500);
});