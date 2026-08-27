window.QuietAlpha = window.QuietAlpha || {};

QuietAlpha.Modal = {
  init: function () {
    var modal = document.getElementById("modal");
    var title = document.getElementById("modalTitle");
    var text = document.getElementById("modalText");
    if (!modal || !title || !text) {
      return;
    }

    document.querySelectorAll(".js-open-modal").forEach(function (el) {
      el.addEventListener("click", function () {
        title.textContent = el.getAttribute("data-title") || "";
        text.textContent = el.getAttribute("data-text") || "";
        modal.classList.add("on");
      });
    });

    modal.addEventListener("click", function (event) {
      if (event.target === modal) {
        modal.classList.remove("on");
      }
    });

    var closeBtn = modal.querySelector(".close");
    if (closeBtn) {
      closeBtn.addEventListener("click", function () {
        modal.classList.remove("on");
      });
    }
  }
};
