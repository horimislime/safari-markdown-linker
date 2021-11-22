browser.runtime.sendNativeMessage({ request: "getFormats" }).then((response) => {
    const container = document.getElementById("container");
    for (const format of response) {
        const button = document.createElement("button");
        button.id = format.command
        button.className = "border-2 border-blue-400 text-blue-400 px-4 py-2 m-2 rounded text-xl";
        button.innerText = format.name;
        button.addEventListener("click", onClick);
        container.appendChild(button);
    }
});

async function onClick(event) {
    const element = event.srcElement;
    const tab = await browser.tabs.getCurrent();
    const selectedText = window.getSelection().toString();
    const title = selectedText.length === 0 ? tab.title : selectedText;
    const payload = {
        title: title,
        link: tab.url,
        command: element.id
    }
    browser.runtime.sendNativeMessage({request: "copy", payload: payload}).then((response) => {
        const currentText = element.innerHTML;
        element.innerHTML = "Copied!";
        setTimeout(() => {
            element.innerHTML = currentText;
        }, 1000);
    });
};
