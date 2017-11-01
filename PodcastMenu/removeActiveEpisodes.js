// Remove active episode section
document.getElementsByClassName('ocseparatorbar')[0].remove();

var episodecells = document.getElementsByClassName('episodecell');

for (var i = 0; i < episodecells.length; i++) {
    episodecells[i].parentNode.removeChild(episodecells[i])
    i--;
}
