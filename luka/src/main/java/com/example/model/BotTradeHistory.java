package com.example.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class BotTradeHistory {

    private static final DateTimeFormatter DISPLAY =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final List<BotTrade> trades;
    private final String currentPriceUpdatedAt;

    public BotTradeHistory(List<BotTrade> trades, LocalDateTime currentPriceUpdatedAt) {
        this.trades = trades == null ? List.of() : List.copyOf(trades);
        this.currentPriceUpdatedAt = currentPriceUpdatedAt == null
                ? null
                : currentPriceUpdatedAt.format(DISPLAY);
    }

    public List<BotTrade> getTrades() {
        return trades;
    }

    public String getCurrentPriceUpdatedAt() {
        return currentPriceUpdatedAt;
    }
}
