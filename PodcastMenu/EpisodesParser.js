var episodeCells = document.querySelectorAll('.episodecell');

var year = (new Date()).getFullYear();

var episodeCellsArray = [];
var len = episodeCells.length;
for (var i = 0; i < len; i++) {
	episodeCellsArray.push(episodeCells[i]);
}

var episodes = episodeCellsArray.map(function(cell){
	var link = cell.href;
	if (!link) return;
		
	var poster = cell.querySelector('img.art').src;
	if (!poster) return;
	
	var dataDivs = cell.querySelectorAll('.cellcontent .titlestack div');
	if (dataDivs.length < 3) return;
	
	var showName = dataDivs[0].innerText;
	var title = dataDivs[1].innerText;
	var info = dataDivs[2].innerText;
	
	var infoComponents = info.split(" • ");
	if (infoComponents.length < 2) return;
	
	var date = infoComponents[0];
	if (date.indexOf(",") == -1) date += ", " + year;
	
	var timeComponents = infoComponents[1].split(" ");
	var time = timeComponents[0];
	var timeType = (infoComponents[1].indexOf("remaining") != -1) ? "remaining" : "duration";
	
	return {
		"podcast": {
			"name": showName,
			"poster": poster
		},
		"title": title,
		"poster": poster,
		"date": date,
		"time": {
			"type": timeType,
			"value": time
		},
		"link": link
	};
});

JSON.stringify(episodes);