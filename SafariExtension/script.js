'use strict';

const notifyTargetLink = (title, url) => {
  const absoluteURL = url.startsWith('/') ? `${location.protocol}//${location.host}${location.pathname}${url}` : url;
  safari.extension.dispatchMessage('linkInfo', {
    title: title,
    url: absoluteURL
  });
};

document.addEventListener('contextmenu', (event) => {

  const parent = event.srcElement.parentElement;
  const clickedLink = Array.from(parent.getElementsByTagName('a')).filter((element) => {
    return element.innerHTML === window.getSelection().toString();
  })[0];

  if (parent.tagName === 'a') {
    notifyTargetLink(parent.innerHTML, parent.href);

  } else if (clickedLink) {
    notifyTargetLink(clickedLink.innerHTML, clickedLink.href);

  } else {
    const selectedText = window.getSelection().toString();
    const title = selectedText.length === 0 ? document.title : selectedText;
    notifyTargetLink(title, location.href);
  }
}, true);
