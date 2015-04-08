// ==UserScript==
// @name         Simplified Article View
// @version      0.1
// @description  Attempts to find the article in the page and strip everything else out.
// @author       Josh S Ziegler
// @include		 http://*.vox.com/*
// @include      http://*.washingtonpost.com/*
// @include      http://*.nytimes.com/*
// ==/UserScript==

function findArticle(){
	// Find parent element with most child <p> elements
	// which is hopefully the article on this page.
	var graphs = document.getElementsByTagName("p");
	if(graphs.length < 1){
		return null;
	}
	var article = graphs[0].parentElement;
	var numParagraphs = article.querySelectorAll("p").length;
	var tmpNumGraphs = 0;
	for(var i=1;i<graphs.length;i++){
		tmpNumGraphs = graphs[i].parentElement.querySelectorAll("p").length;
		if(tmpNumGraphs > numParagraphs){
			numParagraphs = tmpNumGraphs;
			article = graphs[i].parentElement;
		}
	}
	return article;
}

function simplifyArticleView(){
	var article = findArticle();
	if(article === null){
		return;
	}
	var title = document.head.getElementsByTagName("title")[0].innerHTML;
	var html = "<article style=\"max-width:550px; margin:auto; padding: .6em; line-height: 1.65; font-family: georgia, 'times new roman', times, serif; color: #333; -webkit-font-smoothing: antialiased;\"" + "<header><h1>" + title + "</h1></header>" + article.innerHTML + "</article>";

	//document.head.innerHTML = "<title>"+title+"</title>";
	document.body.innerHTML = html;
}

simplifyArticleView();