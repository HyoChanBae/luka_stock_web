window.QuietAlpha = window.QuietAlpha || {};

QuietAlpha.Sidebar = {
  init: function () {
    var toggle = document.getElementById("sidebarToggle");
    if (!toggle) {
      return;
    }

    var key = "quietalpha-nav-collapsed";

    function collapsed() {
      return document.documentElement.classList.contains("nav-collapsed");
    }

    function apply(isCollapsed) {
      document.documentElement.classList.toggle("nav-collapsed", isCollapsed);
      toggle.setAttribute("aria-expanded", isCollapsed ? "false" : "true");
      toggle.setAttribute("aria-label", isCollapsed ? "사이드바 펼치기" : "사이드바 접기");
      toggle.setAttribute("title", isCollapsed ? "사이드바 펼치기" : "사이드바 접기");
      try {
        localStorage.setItem(key, isCollapsed ? "1" : "0");
      } catch (e) {}
    }

    apply(collapsed());
    toggle.addEventListener("click", function () {
      apply(!collapsed());
    });
  }
};
