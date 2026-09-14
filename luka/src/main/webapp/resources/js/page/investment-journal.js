window.QuietAlpha = window.QuietAlpha || {};

QuietAlpha.InvestmentJournal = {
  init: function () {
    var $ = function (id) {
      return document.getElementById(id);
    };
    if (!$("ij-body")) {
      return;
    }

    var cols = ["date", "stock", "period", "buy", "qty", "current", "memo"];
    var blank = function () {
      return {
        date: "",
        stock: "",
        period: "",
        buy: "",
        qty: "",
        current: "",
        memo: "",
        analysis: "",
        report: "",
        legacyAmount: ""
      };
    };
    var sampleRows = [
      Object.assign(blank(), {
        date: "2026-09-14",
        stock: "삼성전자",
        period: "3년",
        buy: "75000",
        qty: "600",
        memo: "예시 내역 · 매수 단가와 수량은 가상 값입니다."
      }),
      Object.assign(blank(), {
        date: "2026-08-20",
        stock: "SK하이닉스",
        period: "1년",
        buy: "200000",
        qty: "100",
        memo: "예시 내역 · 현재가를 직접 입력해 주세요."
      })
    ];
    var tabNames = { long: "장기", medium: "중기", short: "단기" };
    var storageKey = "quietalpha-journal-v1";
    var data = sampleRows.slice();
    var history = [];
    var selected = new Set();
    var active = [0, 0];
    var detailIndex = 0;
    var storageOK = true;
    var currentTab = "long";
    var buckets = { long: [], medium: [], short: [] };
    var histories = { long: [], medium: [], short: [] };
    var pageTitle = document.querySelector(".page-journal .title h1");
    var pageSubtitle = document.querySelector(".page-journal .title p");

    function classify(row) {
      var text = (row.period || "").trim();
      if (text.indexOf("장기") !== -1) {
        return "long";
      }
      if (text.indexOf("중기") !== -1) {
        return "medium";
      }
      if (text.indexOf("단기") !== -1) {
        return "short";
      }
      var n = parseFloat(text);
      if (Number.isFinite(n)) {
        var months = text.indexOf("년") !== -1 ? n * 12 : n;
        if (months >= 36) {
          return "long";
        }
        if (months >= 12) {
          return "medium";
        }
        return "short";
      }
      return "long";
    }

    function validRows(rows) {
      return Array.isArray(rows) && rows.every(function (row) {
        return row && typeof row.date === "string" && typeof row.period === "string" &&
          (typeof row.stock === "string" || typeof row.sector === "string");
      });
    }

    function migrate(row) {
      if (typeof row.stock === "string") {
        return Object.assign(blank(), row);
      }
      return Object.assign(blank(), {
        date: row.date,
        period: row.period,
        stock: "",
        memo: [row.memo, row.sector ? "이전 섹터/종목: " + row.sector : ""].filter(Boolean).join(" · "),
        analysis: row.analysis || "",
        report: row.report || "",
        legacyAmount: row.amount || ""
      });
    }

    function loadSaved() {
      try {
        var saved = localStorage.getItem(storageKey) ||
          localStorage.getItem("investtracker-editable-v3") ||
          localStorage.getItem("investtracker-editable-v2");
        if (saved) {
          var parsed = JSON.parse(saved);
          if (!parsed.buckets || !Object.keys(tabNames).every(function (tab) {
            return validRows(parsed.buckets[tab]);
          })) {
            throw new Error("invalid buckets");
          }
          Object.keys(tabNames).forEach(function (tab) {
            buckets[tab] = parsed.buckets[tab].map(migrate);
          });
          currentTab = Object.prototype.hasOwnProperty.call(tabNames, parsed.currentTab)
            ? parsed.currentTab
            : "long";
          return;
        }
        var legacy = localStorage.getItem("investtracker-editable-v1");
        if (legacy) {
          var legacyParsed = JSON.parse(legacy);
          if (!validRows(legacyParsed)) {
            throw new Error("invalid legacy");
          }
          data = legacyParsed.map(migrate);
        }
        data.forEach(function (row) {
          buckets[classify(row)].push(row);
        });
      } catch (err) {
        storageOK = false;
        buckets.long = sampleRows.slice();
        $("ij-message").textContent = "저장된 데이터를 읽을 수 없습니다. 현재 내용은 CSV로 보관해 주세요.";
      }
    }

    loadSaved();
    data = buckets[currentTab];
    history = histories[currentTab];

    function persist() {
      buckets[currentTab] = data;
      histories[currentTab] = history;
      try {
        if (!storageOK) {
          throw new Error("storage unavailable");
        }
        localStorage.setItem(storageKey, JSON.stringify({ buckets: buckets, currentTab: currentTab }));
        $("ij-save").textContent = "● 이 브라우저에 저장됨";
      } catch (err) {
        $("ij-save").textContent = "자동 저장 불가 · CSV로 보관";
      }
    }

    function updateTabs() {
      buckets[currentTab] = data;
      Object.keys(tabNames).forEach(function (tab) {
        $("ij-count-" + tab).textContent = buckets[tab].length;
        var button = $("ij-tab-" + tab);
        button.setAttribute("aria-selected", String(tab === currentTab));
        button.tabIndex = tab === currentTab ? 0 : -1;
      });
      $("ij-panel").setAttribute("aria-labelledby", "ij-tab-" + currentTab);
      $("ij-total-label").textContent = tabNames[currentTab] + " 투자 총액";
    }

    function switchTab(tab) {
      if (tab === currentTab) {
        return;
      }
      if (document.activeElement && document.activeElement.blur) {
        document.activeElement.blur();
      }
      buckets[currentTab] = data;
      histories[currentTab] = history;
      currentTab = tab;
      data = buckets[tab];
      history = histories[tab];
      selected.clear();
      active = [0, 0];
      detailIndex = 0;
      $("ij-address").textContent = "A1";
      $("ij-formula").value = "";
      $("ij-message").textContent = "";
      showSheet();
      persist();
    }

    Object.keys(tabNames).forEach(function (tab) {
      var button = $("ij-tab-" + tab);
      button.onclick = function () {
        switchTab(tab);
      };
      button.onkeydown = function (event) {
        var keys = Object.keys(tabNames);
        var index = keys.indexOf(tab);
        if (event.key === "ArrowRight") {
          index = (index + 1) % 3;
        } else if (event.key === "ArrowLeft") {
          index = (index + 2) % 3;
        } else if (event.key === "Home") {
          index = 0;
        } else if (event.key === "End") {
          index = 2;
        } else {
          return;
        }
        event.preventDefault();
        switchTab(keys[index]);
        $("ij-tab-" + keys[index]).focus();
      };
    });

    function snapshot() {
      history.push(JSON.stringify(data));
      if (history.length > 60) {
        history.shift();
      }
      $("ij-undo").disabled = false;
    }

    function metrics(row) {
      var num = function (value) {
        return value !== "" && Number.isFinite(Number(value)) && Number(value) >= 0 ? Number(value) : null;
      };
      var buy = num(row.buy);
      var qty = num(row.qty);
      var current = num(row.current);
      var cost = buy !== null && qty !== null ? buy * qty : null;
      var value = current !== null && qty !== null ? current * qty : null;
      return {
        cost: cost,
        value: value,
        profit: cost !== null && value !== null ? value - cost : null,
        rate: buy !== null && buy > 0 && current !== null ? (current - buy) / buy * 100 : null
      };
    }

    function fmt(value) {
      return value === null ? "—" : value.toLocaleString("ko-KR", { maximumFractionDigits: 2 });
    }

    function calculated(row) {
      var m = metrics(row);
      return [m.cost, m.value, m.profit, m.rate];
    }

    function refreshCalculated() {
      data.forEach(function (row, i) {
        calculated(row).forEach(function (value, j) {
          var cell = $("ij-calc-" + i + "-" + j);
          if (!cell) {
            return;
          }
          cell.textContent = value === null ? "—" : (j >= 2 && value > 0 ? "+" : "") + fmt(value) + (j === 3 ? "%" : "");
          cell.className = "ij-calc" + (j >= 2 && value > 0 ? " ij-positive" : j >= 2 && value < 0 ? " ij-negative" : "");
          if (j === 0 && value === null && row.legacyAmount) {
            cell.textContent = fmt(Number(row.legacyAmount) * 10000) + " (이전)";
            cell.title = "기존 투자금액입니다. 매수 단가와 주식 수 입력 후 자동 계산됩니다.";
          }
        });
      });
    }

    function summary() {
      updateTabs();
      var total = data.reduce(function (sum, row) {
        var cost = metrics(row).cost;
        return sum + (cost != null ? cost : Number(row.legacyAmount || 0) * 10000);
      }, 0);
      $("ij-total").textContent = $("ij-sum").textContent = fmt(total / 10000);
      $("ij-count").textContent = data.length;
      $("ij-rows").textContent = data.length + "개 행 · " + selected.size + "개 선택";
      $("ij-latest").textContent = data.map(function (row) {
        return row.date;
      }).filter(Boolean).sort().pop() || "—";
      $("ij-del").disabled = !selected.size;
      $("ij-all").checked = data.length > 0 && selected.size === data.length;
      $("ij-all").indeterminate = selected.size > 0 && selected.size < data.length;
      refreshCalculated();
    }

    function render() {
      var body = $("ij-body");
      body.replaceChildren();
      data.forEach(function (row, i) {
        var tr = document.createElement("tr");
        var check = document.createElement("td");
        check.className = "ij-check";
        var cb = document.createElement("input");
        cb.type = "checkbox";
        cb.checked = selected.has(i);
        cb.setAttribute("aria-label", (i + 1) + "행 선택");
        cb.onchange = function () {
          if (cb.checked) {
            selected.add(i);
          } else {
            selected.delete(i);
          }
          summary();
        };
        check.append(cb);
        tr.append(check);

        var numCell = document.createElement("td");
        numCell.className = "ij-rownum";
        numCell.textContent = i + 1;
        tr.append(numCell);

        cols.forEach(function (col, j) {
          var td = document.createElement("td");
          var input = document.createElement("input");
          if ([3, 4, 5].indexOf(j) !== -1) {
            td.className = "num";
            input.inputMode = "decimal";
          }
          input.value = row[col];
          if (col === "stock") {
            input.placeholder = "예: 삼성전자";
          }
          if (col === "current") {
            input.placeholder = "직접 입력";
          }
          input.dataset.row = String(i);
          input.dataset.col = String(j);
          input.setAttribute("aria-label", String.fromCharCode(65 + j) + (i + 1) + " " + col);
          input.onfocus = function () {
            active = [i, j];
            $("ij-address").textContent = String.fromCharCode(65 + j) + (i + 1);
            $("ij-formula").value = input.value;
          };
          input.onchange = function () {
            commit(i, j, input.value);
          };
          input.onkeydown = function (event) {
            if (event.key === "Enter") {
              event.preventDefault();
              input.blur();
              focusCell(i + (event.shiftKey ? -1 : 1), j);
            }
          };
          input.onpaste = paste;
          td.append(input);
          tr.append(td);
        });

        calculated(row).forEach(function (value, j) {
          var td = document.createElement("td");
          td.id = "ij-calc-" + i + "-" + j;
          td.className = "ij-calc";
          tr.append(td);
        });

        var reportTd = document.createElement("td");
        var reportBtn = document.createElement("button");
        reportBtn.type = "button";
        reportBtn.className = "ij-detailbtn";
        reportBtn.textContent = "열기 ↗";
        reportBtn.onclick = function () {
          showDetail(i);
        };
        reportTd.append(reportBtn);
        tr.append(reportTd);
        body.append(tr);
      });
      summary();
      $("ij-undo").disabled = !history.length;
    }

    function focusCell(i, j) {
      var input = document.querySelector('input[data-row="' + i + '"][data-col="' + j + '"]');
      if (input) {
        input.focus();
      }
    }

    function normalize(j, value) {
      value = String(value).trim();
      if ([3, 4, 5].indexOf(j) !== -1 && value !== "") {
        value = value.replace(/,/g, "");
        if (!/^\d+(\.\d+)?$/.test(value) || !Number.isFinite(Number(value))) {
          throw new Error("단가와 주식 수는 0 이상의 숫자로 입력해 주세요.");
        }
      }
      if (j === 0 && value !== "") {
        if (!/^\d{4}-\d{2}-\d{2}$/.test(value) || !Number.isFinite(Date.parse(value)) ||
          new Date(value).toISOString().slice(0, 10) !== value) {
          throw new Error("날짜는 유효한 YYYY-MM-DD 형식으로 입력해 주세요.");
        }
      }
      return value;
    }

    function commit(i, j, value) {
      if (!data[i]) {
        return;
      }
      try {
        value = normalize(j, value);
        if (data[i][cols[j]] !== value) {
          snapshot();
          data[i][cols[j]] = value;
          persist();
          summary();
        }
        $("ij-message").textContent = "";
        var input = document.querySelector('input[data-row="' + i + '"][data-col="' + j + '"]');
        if (input) {
          input.value = value;
        }
        $("ij-formula").value = value;
      } catch (err) {
        $("ij-message").textContent = err.message;
        render();
        focusCell(i, j);
      }
    }

    function parseTSV(text) {
      var rows = [[]];
      var value = "";
      var quoted = false;
      for (var k = 0; k < text.length; k++) {
        var c = text[k];
        if (c === '"' && (quoted || value === "")) {
          if (quoted && text[k + 1] === '"') {
            value += '"';
            k += 1;
          } else {
            quoted = !quoted;
          }
        } else if (!quoted && (c === "\t" || c === "\n" || c === "\r")) {
          rows[rows.length - 1].push(value);
          value = "";
          if (c !== "\t") {
            if (c === "\r" && text[k + 1] === "\n") {
              k += 1;
            }
            rows.push([]);
          }
        } else {
          value += c;
        }
      }
      rows[rows.length - 1].push(value);
      if (rows[rows.length - 1].length === 1 && rows[rows.length - 1][0] === "" && rows.length > 1) {
        rows.pop();
      }
      return rows;
    }

    function paste(event) {
      var text = event.clipboardData.getData("text/plain");
      if (!/[\t\r\n]/.test(text)) {
        return;
      }
      event.preventDefault();
      var i = Number(event.target.dataset.row);
      var j = Number(event.target.dataset.col);
      try {
        var matrix = parseTSV(text);
        if (matrix.length > 5000) {
          throw new Error("한 번에 5,000행까지 붙여넣을 수 있습니다.");
        }
        if (matrix.some(function (row) {
          return row.length + j > cols.length;
        })) {
          throw new Error("붙여넣기 범위가 G열을 초과합니다. A~G열 범위를 확인해 주세요.");
        }
        var normalized = matrix.map(function (row) {
          return row.map(function (cell, k) {
            return normalize(j + k, cell);
          });
        });
        snapshot();
        normalized.forEach(function (row, x) {
          while (data.length <= i + x) {
            data.push(blank());
          }
          row.forEach(function (cell, y) {
            data[i + x][cols[j + y]] = cell;
          });
        });
        render();
        persist();
        focusCell(i, j);
        $("ij-message").textContent = matrix.length + "개 행을 붙여넣었습니다.";
      } catch (err) {
        $("ij-message").textContent = err.message;
      }
    }

    $("ij-formula").onchange = function () {
      commit(active[0], active[1], $("ij-formula").value);
    };
    $("ij-add").onclick = function () {
      snapshot();
      data.push(Object.assign(blank(), { period: tabNames[currentTab] }));
      render();
      persist();
      focusCell(data.length - 1, 0);
    };
    $("ij-all").onchange = function (event) {
      selected = event.target.checked ? new Set(data.map(function (_, i) {
        return i;
      })) : new Set();
      render();
    };
    $("ij-del").onclick = function () {
      snapshot();
      data = data.filter(function (_, i) {
        return !selected.has(i);
      });
      selected.clear();
      render();
      persist();
    };
    $("ij-undo").onclick = function () {
      if (!history.length) {
        return;
      }
      data = JSON.parse(history.pop());
      selected.clear();
      render();
      persist();
    };

    function showSheet() {
      $("ij-sheetview").style.display = "block";
      $("ij-detailview").style.display = "none";
      if (pageTitle) {
        pageTitle.textContent = "투자 기록";
      }
      if (pageSubtitle) {
        pageSubtitle.textContent = "생각부터 투자 내역까지, 셀에 바로 기록하세요.";
      }
      render();
    }

    function showDetail(i) {
      if (!data.length) {
        $("ij-message").textContent = "행을 추가한 뒤 상세 레포트를 작성해 주세요.";
        return;
      }
      detailIndex = Math.min(i, data.length - 1);
      var row = data[detailIndex];
      $("ij-sheetview").style.display = "none";
      $("ij-detailview").style.display = "block";
      if (pageTitle) {
        pageTitle.textContent = "상세 레포트";
      }
      if (pageSubtitle) {
        pageSubtitle.textContent = "투자 기록에 판단의 근거를 더하세요.";
      }
      $("ij-detailtitle").textContent = row.stock || "종목명 미입력";
      $("ij-detailmeta").textContent = [
        tabNames[currentTab],
        row.date || "날짜 미입력",
        row.period || "기간 미입력",
        "매수금액 " + fmt(metrics(row).cost) + " 원",
        "평가손익 " + fmt(metrics(row).profit) + " 원",
        "수익률 " + fmt(metrics(row).rate) + "%"
      ].join(" · ");
      $("ij-analysis").value = row.analysis || "";
      $("ij-report").value = row.report || "";
    }

    ["ij-analysis", "ij-report"].forEach(function (id) {
      $(id).addEventListener("focus", function () {
        snapshot();
      });
      $(id).oninput = function () {
        var field = id === "ij-analysis" ? "analysis" : "report";
        data[detailIndex][field] = $(id).value;
        persist();
      };
    });

    $("ij-back").onclick = showSheet;

    $("ij-export").onclick = function () {
      var csvCell = function (value) {
        var text = String(value == null ? "" : value);
        return '"' + (/^[=+\-@\t\r]/.test(text) ? "'" + text : text).replace(/"/g, '""') + '"';
      };
      var header = [
        "구매 날짜", "종목명", "목표 기간", "매수 단가 (원)", "주식 수 (주)", "현재가 (원)", "투자 메모",
        "매수금액 (원)", "평가금액 (원)", "평가손익 (원)", "수익률 (%)", "이전 투자금액 (만원)",
        "섹터 시황 / 투자 근거", "관련 레포트"
      ];
      var lines = [header].concat(data.map(function (row) {
        return cols.map(function (col) {
          return row[col] || "";
        }).concat(calculated(row).map(function (value) {
          return value === null ? "" : String(value);
        })).concat([row.legacyAmount || "", row.analysis || "", row.report || ""]);
      }));
      var csv = "\ufeff" + lines.map(function (row) {
        return row.map(csvCell).join(",");
      }).join("\r\n");
      var url = URL.createObjectURL(new Blob([csv], { type: "text/csv;charset=utf-8;" }));
      var link = document.createElement("a");
      link.href = url;
      link.download = "투자기록_" + tabNames[currentTab] + ".csv";
      link.click();
      setTimeout(function () {
        URL.revokeObjectURL(url);
      }, 1000);
    };

    render();
    persist();
  }
};
