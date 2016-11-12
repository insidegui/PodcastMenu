function parseTitle() {
	var titleComponents = document.title.split(" — ");
	if (titleComponents.count < 2) return "";
	
	return titleComponents[0];
}

parseTitle();
