window.QuietAlpha = window.QuietAlpha || {};

QuietAlpha.Scenario = {
  init: function () {
    var form = document.getElementById("scenarioForm");
    var capital = document.getElementById("capital");
    if (!form || !capital) {
      return;
    }

    form.addEventListener("submit", function () {
      capital.value = capital.value.replace(/,/g, "");
    });
  }
};
