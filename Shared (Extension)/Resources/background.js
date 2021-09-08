browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log("Received request: ", request);
    
    

    if (request.greeting === "hello")
        sendResponse({ farewell: "goodbye" });
});

console.log("background script");

function onCreated() {
  if (browser.runtime.lastError) {
    console.log(`Error: ${browser.runtime.lastError}`);
  } else {
    console.log("Item created successfully");
  }
}

browser.menus.create({
  id: "remove-me",
    type: "normal",
  title: "Web Extension Demo",
  contexts: ["all"]
}, onCreated);
console.log('created');
console.log(browser.menus);
