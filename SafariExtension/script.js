
function notifyTargetLink(title, url) {
    var absoluteURL = url.startsWith('/') ? location.protocol + '//' + location.host + location.pathname + url : url
    safari.extension.dispatchMessage("linkInfo", {
      "title": title,
      "url": url
    });
}

document.addEventListener("contextmenu", function(event) {

  var parent = event.srcElement.parentElement;
  const clickedLink = Array.from(parent.getElementsByTagName('a')).filter((element) => {
     return element.innerHTML == window.getSelection().toString();
   })[0];

  if (parent.tagName == 'a') {
    notifyTargetLink(parent.innerHTML, parent.href);

  } else if (clickedLink) {
    notifyTargetLink(clickedLink.innerHTML, clickedLink.href);

  } else {
    notifyTargetLink(document.title, location.href);
  }
}, true);
