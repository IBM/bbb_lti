var input = document.getElementById("presentation_url");
var a = document.getElementById("check_link_button");

const handler = function () {
  // show/hide button
  if (input.value.length > 0) a.classList.remove("invisible");
  else if (!a.classList.contains("invisible")) a.classList.add("invisible");

  // strip away protocol if present
  input.value = input.value.replace("http://", "");
  input.value = input.value.replace("https://", "");

  a.href = "http://" + input.value;
};

// we need to check the input and update the button's action
// when the window loads as well as when the input field updates
window.onload = handler;
input.oninput = handler;
