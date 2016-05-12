var progressbar = document.querySelector('#progressbar');

if (progressbar && typeof(progressbar) != 'undefined') {
    location.hash = "#progressbar";
    document.querySelector('#progressbar').style.paddingTop = '10px';
}

var audio = null;

var bridge = null;
if (typeof(window.webkit) != 'undefined') {
	if (typeof(window.webkit.messageHandlers) != 'undefined') {
		bridge = window.webkit.messageHandlers.PodcastMenuApp;
	}
}

function installAudioPipeline() {
	try {
		if (audio == null || typeof(audio) == 'undefined') return;
	
		audio.addEventListener('pause', function(){
			bridge.postMessage('pause');
		}, false);
		audio.addEventListener('play', function(){
			bridge.postMessage('play');
		}, false);
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
		} else {
			bridge.postMessage('pause');
		}
	}, 500);
});