window.QuietAlpha = window.QuietAlpha || {};

QuietAlpha.BotDetail = {
  init: function () {
    var modal = document.getElementById("tradeModal");
    var title = document.getElementById("tradeModalBot");
    var quoteAt = document.getElementById("tradeModalQuoteAt");
    var body = document.getElementById("tradeModalBody");
    var chartPopup = document.getElementById("tradeChartPopup");
    if (!modal || !title || !body) {
      return;
    }

    var chart = bindChartPopup(chartPopup);
    var tradeBox = modal.querySelector(".trade-box");
    var tradeHead = tradeBox && tradeBox.querySelector("h2");
    bindDraggable(tradeBox, tradeHead);

    function setQuoteAt(value) {
      if (!quoteAt) {
        return;
      }
      quoteAt.textContent = value ? "현재가 업데이트 시각 " + value : "";
    }

    function resetTradeBox() {
      if (!tradeBox) {
        return;
      }
      tradeBox.classList.remove("dragging");
      tradeBox.style.position = "";
      tradeBox.style.margin = "";
      tradeBox.style.left = "";
      tradeBox.style.top = "";
      tradeBox.style.width = "";
    }

    function close() {
      modal.classList.remove("on");
      modal.classList.remove("comparing");
      resetTradeBox();
      if (chart) {
        chart.close();
      }
    }

    modal.addEventListener("click", function (event) {
      if (event.target === modal) {
        close();
      }
    });
    var closeBtn = modal.querySelector(".close");
    if (closeBtn) {
      closeBtn.addEventListener("click", close);
    }

    body.addEventListener("click", function (event) {
      var btn = event.target.closest(".trade-chart-link");
      if (!btn || !chart) {
        return;
      }
      event.preventDefault();
      event.stopPropagation();
      modal.classList.add("comparing");
      chart.open();
    });

    document.querySelectorAll(".js-bot-detail").forEach(function (btn) {
      btn.addEventListener("click", function () {
        var name = btn.getAttribute("data-bot-name") || "";
        var url = btn.getAttribute("data-trades-url");
        title.textContent = name;
        setQuoteAt("");
        body.textContent = "불러오는 중...";
        modal.classList.add("on");
        if (!url) {
          body.textContent = "거래내역 주소를 찾을 수 없습니다.";
          return;
        }
        fetch(url)
          .then(function (res) {
            if (!res.ok) {
              throw new Error("조회에 실패했습니다.");
            }
            return res.json();
          })
          .then(function (data) {
            var trades = Array.isArray(data) ? data : (data && data.trades) || [];
            setQuoteAt(data && data.currentPriceUpdatedAt);
            render(body, trades);
          })
          .catch(function () {
            setQuoteAt("");
            body.textContent = "거래내역을 불러오지 못했습니다.";
          });
      });
    });
  }
};

function createChartLink() {
  var btn = document.createElement("button");
  btn.type = "button";
  btn.className = "link trade-chart-link";
  btn.textContent = "Chart";
  return btn;
}

function render(body, trades) {
  body.replaceChildren();
  if (!trades || trades.length === 0) {
    var empty = document.createElement("p");
    empty.className = "small";
    empty.textContent = "이 봇의 거래내역이 아직 없습니다.";
    body.appendChild(empty);
    return;
  }

  var head = document.createElement("div");
  head.className = "trade-row trade-head";
  ["종목명", "종목코드", "종목 선정 이유", "구매단가", "현재가", "등락률", "구매일시"].forEach(function (label) {
    var col = document.createElement("div");
    if (label === "현재가") {
      col.className = "trade-price-head";
      var headLabel = document.createElement("span");
      headLabel.textContent = label;
      col.appendChild(headLabel);
      col.appendChild(createChartLink());
    } else {
      col.textContent = label;
    }
    head.appendChild(col);
  });
  body.appendChild(head);

  trades.forEach(function (trade) {
    var row = document.createElement("div");
    row.className = "trade-row";

    var name = document.createElement("div");
    var nameStrong = document.createElement("b");
    nameStrong.textContent = trade.symbolName || "—";
    name.appendChild(nameStrong);

    var symbol = document.createElement("div");
    symbol.textContent = trade.symbol || "—";

    var reason = document.createElement("div");
    reason.className = "small";
    reason.textContent = trade.selectReason || "";

    var price = document.createElement("div");
    price.textContent = trade.buyPriceDisplay || "—";

    var last = document.createElement("div");
    last.className = "trade-last";
    var lastValue = document.createElement("span");
    lastValue.textContent = trade.lastPriceDisplay || "—";
    last.appendChild(lastValue);
    last.appendChild(createChartLink());

    var change = document.createElement("div");
    change.textContent = trade.changePctDisplay || "—";
    if (trade.changeClass) {
      change.className = trade.changeClass;
    }

    var when = document.createElement("div");
    when.textContent = trade.buyAtDisplay || "—";

    row.appendChild(name);
    row.appendChild(symbol);
    row.appendChild(reason);
    row.appendChild(price);
    row.appendChild(last);
    row.appendChild(change);
    row.appendChild(when);
    body.appendChild(row);
  });
}

function bindDraggable(el, handle) {
  if (!el || !handle) {
    return;
  }

  var dragging = false;
  var startX = 0;
  var startY = 0;
  var origLeft = 0;
  var origTop = 0;

  function point(event) {
    if (event.touches && event.touches[0]) {
      return { x: event.touches[0].clientX, y: event.touches[0].clientY };
    }
    return { x: event.clientX, y: event.clientY };
  }

  function onMove(event) {
    if (!dragging) {
      return;
    }
    event.preventDefault();
    var p = point(event);
    var left = origLeft + (p.x - startX);
    var top = origTop + (p.y - startY);
    var maxLeft = Math.max(8, window.innerWidth - el.offsetWidth - 8);
    el.style.left = Math.min(Math.max(8, left), maxLeft) + "px";
    el.style.top = Math.min(Math.max(8, top), window.innerHeight - 48) + "px";
  }

  function stopDrag() {
    if (!dragging) {
      return;
    }
    dragging = false;
    el.classList.remove("dragging");
    document.removeEventListener("mousemove", onMove);
    document.removeEventListener("mouseup", stopDrag);
    document.removeEventListener("touchmove", onMove);
    document.removeEventListener("touchend", stopDrag);
  }

  function startDrag(event) {
    if (event.target.closest(".close") || event.target.closest(".trade-chart-link")) {
      return;
    }
    var p = point(event);
    var rect = el.getBoundingClientRect();
    dragging = true;
    startX = p.x;
    startY = p.y;
    origLeft = rect.left;
    origTop = rect.top;
    el.classList.add("dragging");
    el.style.position = "fixed";
    el.style.margin = "0";
    el.style.left = rect.left + "px";
    el.style.top = rect.top + "px";
    el.style.width = rect.width + "px";
    document.addEventListener("mousemove", onMove);
    document.addEventListener("mouseup", stopDrag);
    document.addEventListener("touchmove", onMove, { passive: false });
    document.addEventListener("touchend", stopDrag);
    event.preventDefault();
  }

  handle.addEventListener("mousedown", startDrag);
  handle.addEventListener("touchstart", startDrag, { passive: false });
}

function bindChartPopup(popup) {
  if (!popup) {
    return null;
  }

  var iframe = popup.querySelector("iframe");
  var shield = popup.querySelector(".chart-popup-shield");
  var head = popup.querySelector(".chart-popup-head");
  var loaded = false;
  var dragging = false;
  var startX = 0;
  var startY = 0;
  var origLeft = 0;
  var origTop = 0;

  function point(event) {
    if (event.touches && event.touches[0]) {
      return { x: event.touches[0].clientX, y: event.touches[0].clientY };
    }
    return { x: event.clientX, y: event.clientY };
  }

  function clamp(left, top) {
    var maxLeft = Math.max(8, window.innerWidth - popup.offsetWidth - 8);
    var maxTop = Math.max(8, window.innerHeight - 48);
    return {
      left: Math.min(Math.max(8, left), maxLeft),
      top: Math.min(Math.max(8, top), maxTop)
    };
  }

  function setShield(on) {
    if (!shield) {
      return;
    }
    shield.classList.toggle("on", !!on);
  }

  function moveTo(left, top) {
    var next = clamp(left, top);
    popup.style.left = next.left + "px";
    popup.style.top = next.top + "px";
    popup.style.right = "auto";
  }

  function onMove(event) {
    if (!dragging) {
      return;
    }
    event.preventDefault();
    var p = point(event);
    moveTo(origLeft + (p.x - startX), origTop + (p.y - startY));
  }

  function stopDrag() {
    if (!dragging) {
      return;
    }
    dragging = false;
    popup.classList.remove("dragging");
    setShield(false);
    document.removeEventListener("mousemove", onMove);
    document.removeEventListener("mouseup", stopDrag);
    document.removeEventListener("touchmove", onMove);
    document.removeEventListener("touchend", stopDrag);
  }

  function startDrag(event) {
    if (event.target.closest(".close")) {
      return;
    }
    var p = point(event);
    var rect = popup.getBoundingClientRect();
    dragging = true;
    startX = p.x;
    startY = p.y;
    origLeft = rect.left;
    origTop = rect.top;
    popup.classList.add("dragging");
    setShield(true);
    moveTo(rect.left, rect.top);
    document.addEventListener("mousemove", onMove);
    document.addEventListener("mouseup", stopDrag);
    document.addEventListener("touchmove", onMove, { passive: false });
    document.addEventListener("touchend", stopDrag);
    event.preventDefault();
  }

  if (head) {
    head.addEventListener("mousedown", startDrag);
    head.addEventListener("touchstart", startDrag, { passive: false });
  }

  var closeBtn = popup.querySelector(".close");
  if (closeBtn) {
    closeBtn.addEventListener("click", function () {
      popup.classList.remove("on");
      var modal = document.getElementById("tradeModal");
      if (modal) {
        modal.classList.remove("comparing");
      }
    });
  }

  return {
    open: function () {
      if (iframe && !loaded) {
        var url = popup.getAttribute("data-chart-url") || "";
        if (url) {
          iframe.src = url;
          loaded = true;
        }
      }
      popup.classList.add("on");
      if (!popup.style.left) {
        var width = popup.offsetWidth || 720;
        moveTo(Math.max(8, window.innerWidth - width - 28), 72);
      }
    },
    close: function () {
      stopDrag();
      popup.classList.remove("on");
    }
  };
}
