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
        
		audio.addEventListener('play', function(){
           // stop autoplay and buffering
           audio.pause();
                               
           var msg = {"name": "audioURL", "url": audio.currentSrc};
           bridge.postMessage(JSON.stringify(msg));
                               
           audio.src = "";
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
		}
	}, 500);
});
