package com.example.model;

import com.fasterxml.jackson.annotation.JsonIgnore;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class BotTrade {

    private static final DateTimeFormatter DISPLAY =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final long tradeId;
    private final long botId;
    private final String symbol;
    private final String symbolName;
    private final String selectReason;
    private final Double buyPrice;
    private final LocalDateTime buyAt;
    private final Double lastPrice;

    public BotTrade(
            long tradeId,
            long botId,
            String symbol,
            String symbolName,
            String selectReason,
            Double buyPrice,
            LocalDateTime buyAt
    ) {
        this(tradeId, botId, symbol, symbolName, selectReason, buyPrice, buyAt, null);
    }

    public BotTrade(
            long tradeId,
            long botId,
            String symbol,
            String symbolName,
            String selectReason,
            Double buyPrice,
            LocalDateTime buyAt,
            Double lastPrice
    ) {
        this.tradeId = tradeId;
        this.botId = botId;
        this.symbol = symbol;
        this.symbolName = symbolName;
        this.selectReason = selectReason;
        this.buyPrice = buyPrice;
        this.buyAt = buyAt;
        this.lastPrice = lastPrice;
    }

    public BotTrade withLastPrice(Double price) {
        return new BotTrade(tradeId, botId, symbol, symbolName, selectReason, buyPrice, buyAt, price);
    }

    public long getTradeId() {
        return tradeId;
    }

    public long getBotId() {
        return botId;
    }

    public String getSymbol() {
        return symbol;
    }

    public String getSymbolName() {
        return symbolName;
    }

    public String getSelectReason() {
        return selectReason;
    }

    public Double getBuyPrice() {
        return buyPrice;
    }

    public String getBuyPriceDisplay() {
        return formatPrice(buyPrice);
    }

    public Double getLastPrice() {
        return lastPrice;
    }

    public String getLastPriceDisplay() {
        return formatPrice(lastPrice);
    }

    public Double getChangePct() {
        if (buyPrice == null || lastPrice == null || buyPrice == 0) {
            return null;
        }
        return (lastPrice - buyPrice) / buyPrice * 100;
    }

    public String getChangePctDisplay() {
        Double pct = getChangePct();
        if (pct == null) {
            return "—";
        }
        return String.format(java.util.Locale.US, "%+.2f%%", pct);
    }

    public String getChangeClass() {
        Double pct = getChangePct();
        if (pct == null) {
            return "";
        }
        if (pct < 0) {
            return "neg";
        }
        return "perf";
    }

    @JsonIgnore
    public LocalDateTime getBuyAt() {
        return buyAt;
    }

    public String getBuyAtDisplay() {
        if (buyAt == null) {
            return "—";
        }
        return buyAt.format(DISPLAY);
    }

    private static String formatPrice(Double value) {
        if (value == null) {
            return "—";
        }
        return String.format(java.util.Locale.US, "%,.2f", value);
    }
}
