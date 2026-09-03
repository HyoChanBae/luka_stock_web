window.QuietAlpha = window.QuietAlpha || {};

QuietAlpha.Chart = {
  init: function () {
    var container = document.getElementById("tv_chart_container");
    if (!container || !window.TradingView) {
      return;
    }
    if (isRealMobile()) {
      document.body.classList.add("touch-chart");
      waitForContainerSize(container, 0, function () {
        createWidget(container, true);
      });
      return;
    }
    createWidget(container, false);
  }
};

function isRealMobile() {
  var ua = navigator.userAgent || "";
  var phone = /iPhone|iPod|Android.+Mobile|webOS|BlackBerry|IEMobile|Opera Mini/i.test(ua);
  var ipad = /iPad/i.test(ua) || (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1);
  var coarse = window.matchMedia("(pointer: coarse)").matches && window.matchMedia("(hover: none)").matches;
  return phone || ipad || coarse;
}

function waitForContainerSize(container, tries, done) {
  var ready = container.clientWidth >= 80 && container.clientHeight >= 160;
  if (ready || tries >= 30) {
    done();
    return;
  }
  window.setTimeout(function () {
    waitForContainerSize(container, tries + 1, done);
  }, 50);
}

function createWidget(container, mobile) {
  var libraryPath = (window.QuietAlphaChartConfig && window.QuietAlphaChartConfig.libraryPath)
      || "/resources/js/charting_library/";
  var symbols = dummySymbols();
  var datafeed = createDummyDatafeed(symbols);
  var disabled = ["header_saveload", "use_localstorage_for_settings"];
  var options = {
    symbol: "AAPL",
    interval: "1D",
    container: container,
    datafeed: datafeed,
    library_path: libraryPath,
    locale: "kr",
    timezone: "Asia/Seoul",
    autosize: true,
    enabled_features: [
      "show_spread_operators",
      "compare_symbol_search_spread_operators",
      "custom_resolutions",
      "hide_left_toolbar_by_default"
    ],
    disabled_features: disabled,
    overrides: {
      "mainSeriesProperties.style": 2,
      "mainSeriesProperties.statusViewStyle.symbolTextSource": "ticker-and-description"
    },
    symbol_search_request_delay: 500,
    custom_formatters: {
      dateFormatter: {
        format: function (date) {
          return date.getUTCFullYear() + "/" + (date.getUTCMonth() + 1) + "/" + date.getUTCDate();
        }
      },
      tickMarkFormatter: function (date, tickMarkType) {
        switch (tickMarkType) {
          case "Year":
            return date.getUTCFullYear() + "년";
          case "Month":
            return date.getUTCMonth() + 1 + "월";
          case "DayOfMonth":
            return date.getUTCDate() + "일";
          case "Time":
            return date.getUTCHours() + ":" + date.getUTCMinutes();
          case "TimeWithSeconds":
            return date.getUTCHours() + ":" + date.getUTCMinutes() + ":" + date.getUTCSeconds();
          default:
            return "";
        }
      }
    }
  };

  if (mobile) {
    disabled.push("left_toolbar", "header_compare", "header_screenshot", "header_undo_redo");
    options.header_widget_buttons_mode = "compact";
    options.width = Math.max(container.clientWidth, 280);
    options.height = Math.max(container.clientHeight, 360);
  }

  window.tvWidget = new TradingView.widget(options);
  window.tvWidget.onChartReady(function () {
    window.tvWidget.activeChart().setChartType(2);
    var iframe = container.querySelector("iframe");
    if (iframe) {
      iframe.style.width = "100%";
      iframe.style.height = "100%";
    }
  });
}

function dummySymbols() {
  return [
    { symbol: "AAPL", ticker: "AAPL", description: "Apple Inc.", exchange: "NASDAQ", type: "stock", pricescale: 100, minmov: 1, base: 185 },
    { symbol: "NVDA", ticker: "NVDA", description: "NVIDIA", exchange: "NASDAQ", type: "stock", pricescale: 100, minmov: 1, base: 128 },
    { symbol: "QQQ", ticker: "QQQ", description: "Invesco QQQ Trust", exchange: "NASDAQ", type: "etf", pricescale: 100, minmov: 1, base: 492 },
    { symbol: "SMR", ticker: "SMR", description: "NuScale Power", exchange: "NYSE", type: "stock", pricescale: 100, minmov: 1, base: 18 }
  ];
}

function createDummyDatafeed(symbols) {
  var resolutions = ["1D", "1W", "1M", "12M"];

  return {
    onReady: function (callback) {
      setTimeout(function () {
        callback({
          supported_resolutions: resolutions,
          exchanges: [
            { value: "", name: "All Exchanges", desc: "" },
            { value: "NASDAQ", name: "NASDAQ", desc: "NASDAQ" },
            { value: "NYSE", name: "NYSE", desc: "NYSE" }
          ],
          symbols_types: [
            { name: "ALL", value: "" },
            { name: "주식", value: "stock" },
            { name: "ETF", value: "etf" }
          ]
        });
      }, 0);
    },

    searchSymbols: function (userInput, exchange, symbolType, onResult) {
      var query = (userInput || "").toLowerCase();
      var result = symbols.filter(function (item) {
        var matchesQuery = !query
            || item.symbol.toLowerCase().indexOf(query) !== -1
            || item.description.toLowerCase().indexOf(query) !== -1;
        var matchesExchange = !exchange || item.exchange === exchange;
        var matchesType = !symbolType || item.type === symbolType;
        return matchesQuery && matchesExchange && matchesType;
      }).map(function (item) {
        return {
          symbol: item.symbol,
          ticker: item.ticker,
          full_name: item.exchange + ":" + item.symbol,
          description: item.description,
          exchange: item.exchange,
          type: item.type
        };
      });
      onResult(result);
    },

    resolveSymbol: function (symbolName, onResolve, onError) {
      var key = String(symbolName || "").split(":").pop();
      var item = symbols.find(function (row) {
        return row.symbol === key || row.ticker === key;
      });
      if (!item) {
        onError("unknown_symbol");
        return;
      }
      setTimeout(function () {
        onResolve({
          name: item.symbol,
          ticker: item.ticker,
          description: item.description,
          type: item.type,
          session: "0930-1600",
          timezone: "America/New_York",
          exchange: item.exchange,
          listed_exchange: item.exchange,
          minmov: item.minmov,
          pricescale: item.pricescale,
          has_intraday: false,
          has_weekly_and_monthly: true,
          supported_resolutions: resolutions,
          volume_precision: 0,
          data_status: "endofday",
          format: "price"
        });
      }, 0);
    },

    getBars: function (symbolInfo, resolution, periodParams, onResult, onError) {
      try {
        var item = symbols.find(function (row) {
          return row.ticker === symbolInfo.ticker || row.symbol === symbolInfo.name;
        });
        var bars = buildBars(item || symbols[0], resolution, periodParams.from, periodParams.to);
        if (!bars.length) {
          onResult([], { noData: true });
          return;
        }
        onResult(bars, { noData: false });
      } catch (err) {
        onError(err);
      }
    },

    subscribeBars: function () {},
    unsubscribeBars: function () {}
  };
}

function buildBars(item, resolution, fromSec, toSec) {
  var step = stepSeconds(resolution);
  var seed = hashString(item.ticker);
  var start = alignTime(fromSec, step);
  var bars = [];
  var price = item.base;
  var cursor = start;

  while (cursor < fromSec) {
    if (resolution === "1D" && isWeekend(cursor)) {
      cursor += step;
      continue;
    }
    price = nextClose(price, seed, cursor);
    cursor += step;
  }

  while (cursor <= toSec) {
    if (resolution === "1D" && isWeekend(cursor)) {
      cursor += step;
      continue;
    }
    var open = price;
    var close = nextClose(open, seed, cursor);
    var high = Math.max(open, close) * (1 + 0.008 + (noise(seed, cursor + 1) * 0.006));
    var low = Math.min(open, close) * (1 - 0.008 - (noise(seed, cursor + 2) * 0.006));
    bars.push({
      time: cursor * 1000,
      open: roundPrice(open),
      high: roundPrice(high),
      low: roundPrice(low),
      close: roundPrice(close),
      volume: Math.round(800000 + noise(seed, cursor + 3) * 2200000)
    });
    price = close;
    cursor += step;
  }
  return bars;
}

function stepSeconds(resolution) {
  if (resolution === "1W" || resolution === "W") {
    return 7 * 86400;
  }
  if (resolution === "1M" || resolution === "M") {
    return 30 * 86400;
  }
  if (resolution === "12M") {
    return 365 * 86400;
  }
  return 86400;
}

function alignTime(unixSec, step) {
  return Math.floor(unixSec / step) * step;
}

function isWeekend(unixSec) {
  var day = new Date(unixSec * 1000).getUTCDay();
  return day === 0 || day === 6;
}

function nextClose(price, seed, unixSec) {
  var change = (noise(seed, unixSec) - 0.48) * 0.035;
  return Math.max(1, price * (1 + change));
}

function noise(seed, unixSec) {
  var x = Math.sin(seed * 12.9898 + unixSec * 78.233) * 43758.5453;
  return x - Math.floor(x);
}

function hashString(value) {
  var hash = 0;
  for (var i = 0; i < value.length; i++) {
    hash = ((hash << 5) - hash) + value.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash) + 1;
}

function roundPrice(value) {
  return Math.round(value * 100) / 100;
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", function () {
    QuietAlpha.Chart.init();
  });
} else {
  QuietAlpha.Chart.init();
}
