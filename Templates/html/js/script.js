function $() {
	return document.querySelector.apply(document, arguments);
}

if (navigator.userAgent.toLowerCase().indexOf("xcode") != -1) {
	document.documentElement.classList.add("xcode");
}

if (localStorage["hideTOC"]) {
	document.documentElement.classList.add("hide-toc");
}

$("#toc-button").addEventListener("click", function(e) {
	e.preventDefault();
	document.documentElement.classList.toggle("hide-toc");
});

$("#jump-to").addEventListener("change", function(e) {
	location.hash = this.options[this.selectedIndex].value;
});
