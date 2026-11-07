var root = document.documentElement;
var box = document.getElementById("theme-toggle");
function current() {
  return root.dataset.theme ||
    (matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
}
function update() {
  Array.prototype.forEach.call(box.querySelectorAll("button[data-theme]"), function (b) {
    b.setAttribute("aria-pressed", b.dataset.theme === current());
  });
}
["light", "dark"].forEach(function (name) {
  var b = document.createElement("button");
  b.type = "button";
  b.textContent = name;
  b.dataset.theme = name;
  b.addEventListener("click", function () {
    root.dataset.theme = name;
    try { localStorage.setItem("theme", name); } catch (e) {}
    update();
  });
  box.appendChild(b);
});
update();
