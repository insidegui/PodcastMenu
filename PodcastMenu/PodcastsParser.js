var podcastCells = document.querySelectorAll('.feedcell');

var podcastCellsArray = [];
var len = podcastCells.length;
for (var i = 0; i < len; i++) {
	podcastCellsArray.push(podcastCells[i]);
}

var podcasts = podcastCellsArray.map(function(cell){
	var link = cell.href;
	if (!link) return;
		
	var poster = cell.querySelector('img.art').src;
	if (!poster) return;
	
	var dataDivs = cell.querySelectorAll('.cellcontent .titlestack div');
	if (!dataDivs.length) return;
	
	var showName = dataDivs[0].innerText;
	
	return {
		"name": showName,
		"poster": poster,
		"link": link
	};
});

JSON.stringify(podcasts);