window.QuietAlpha = window.QuietAlpha || {};

QuietAlpha.Switch = {
  init: function () {
    document.querySelectorAll(".switch").forEach(function (el) {
      el.addEventListener("click", function () {
        el.classList.toggle("on");
      });
    });
  }
};
