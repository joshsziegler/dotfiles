// ==UserScript==
// @name         Remove Comments
// @version      0.1
// @description  Attempts to find and remvoe comments.
// @author       Josh S Ziegler
// @exclude		 *stackoverflow.com/*
// @exclude      *stackexchange.com/*
// ==/UserScript==

function removeElement(el){
	if(el === null || el === undefined){return;}
	el.parentElement.removeChild(el);
}

function removeElements(elements){
	if(elements === null){return "Null";}
	if(elements.length < 1){return "Empty";}
	for(var i=elements.length-1; i>=0; i--){
		var el = elements[i];
		el.parentElement.removeChild(el);
	}
}

function removeComments(){
	// Find all elements with the class or id of "comment(s)"
	removeElement(document.getElementById("comments"));
	removeElement(document.getElementById("comment"));
	removeElements(document.getElementsByClassName("comment"));
	removeElements(document.getElementsByClassName("comments"));
}

removeComments();