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
    private final String selectReason;
    private final Double buyPrice;
    private final LocalDateTime buyAt;

    public BotTrade(
            long tradeId,
            long botId,
            String symbol,
            String selectReason,
            Double buyPrice,
            LocalDateTime buyAt
    ) {
        this.tradeId = tradeId;
        this.botId = botId;
        this.symbol = symbol;
        this.selectReason = selectReason;
        this.buyPrice = buyPrice;
        this.buyAt = buyAt;
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

    public String getSelectReason() {
        return selectReason;
    }

    public Double getBuyPrice() {
        return buyPrice;
    }

    public String getBuyPriceDisplay() {
        if (buyPrice == null) {
            return "—";
        }
        return String.format(java.util.Locale.US, "%,.2f", buyPrice);
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
}
