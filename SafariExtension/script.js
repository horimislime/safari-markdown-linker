
function notifyTargetLink(title, url) {
    
    var absoluteURL = url.startsWith('/') ? location.protocol + '//' + location.host + location.pathname + url : url
    
    safari.extension.dispatchMessage("linkInfo", {
      "title": title,
      "url": url
    });
}

document.addEventListener("contextmenu", function(event) {

  var parent = event.srcElement.parentElement;
  var candidates = parent.getElementsByTagName('a');

  if (parent.tagName == 'a') {
    notifyTargetLink(parent.innerHTML, parent.href);

  } else if (candidates.length > 0 && window.getSelection().toString().length > 0) {
    notifyTargetLink(candidates[0].innerHTML, candidates[0].href);

  } else {
    notifyTargetLink(document.title, location.href);
  }
}, true);
