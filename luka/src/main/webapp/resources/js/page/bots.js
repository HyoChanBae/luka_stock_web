window.QuietAlpha = window.QuietAlpha || {};

QuietAlpha.BotDetail = {
  init: function () {
    var modal = document.getElementById("tradeModal");
    var title = document.getElementById("tradeModalBot");
    var body = document.getElementById("tradeModalBody");
    if (!modal || !title || !body) {
      return;
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
          .then(function (trades) {
            render(body, trades);
          })
          .catch(function () {
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
  ["종목", "종목 선정 이유", "구매단가", "구매일시"].forEach(function (label) {
    var col = document.createElement("div");
    col.textContent = label;
    head.appendChild(col);
  });
  body.appendChild(head);

  trades.forEach(function (trade) {
    var row = document.createElement("div");
    row.className = "trade-row";

    var symbol = document.createElement("div");
    var strong = document.createElement("b");
    strong.textContent = trade.symbol || "";
    symbol.appendChild(strong);

    var reason = document.createElement("div");
    reason.className = "small";
    reason.textContent = trade.selectReason || "";

    var price = document.createElement("div");
    price.textContent = trade.buyPriceDisplay || "—";

    var when = document.createElement("div");
    when.textContent = trade.buyAtDisplay || "—";

    row.appendChild(symbol);
    row.appendChild(reason);
    row.appendChild(price);
    row.appendChild(when);
    body.appendChild(row);
  });
}
