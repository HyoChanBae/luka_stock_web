window.QuietAlpha = window.QuietAlpha || {};

QuietAlpha.BotDetail = {
  init: function () {
    var modal = document.getElementById("tradeModal");
    var title = document.getElementById("tradeModalBot");
    var quoteAt = document.getElementById("tradeModalQuoteAt");
    var body = document.getElementById("tradeModalBody");
    if (!modal || !title || !body) {
      return;
    }

    function setQuoteAt(value) {
      if (!quoteAt) {
        return;
      }
      quoteAt.textContent = value ? "현재가 업데이트 시각 " + value : "";
    }

    function close() {
      modal.classList.remove("on");
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
    col.textContent = label;
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
    last.textContent = trade.lastPriceDisplay || "—";

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
