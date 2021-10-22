console.log("Hello World!", browser);

const onClick = (element) => {
  document.getElementById("test").innerHTML = "hellooooooo";
  const currentText = element.innerHTML;
  element.innerHTML = "Copied!";
  setTimeout(() => {
    element.innerHTML = currentText;
  }, 1000);
};
