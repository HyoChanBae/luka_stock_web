package com.example.model;

public class BotRank {

    private final int rank;
    private final String name;
    private final String style;
    private final String llm;
    private final String returnRate;
    private final String mdd;
    private final String trades;

    public BotRank(
            int rank,
            String name,
            String style,
            String llm,
            String returnRate,
            String mdd,
            String trades
    ) {
        this.rank = rank;
        this.name = name;
        this.style = style;
        this.llm = llm;
        this.returnRate = returnRate;
        this.mdd = mdd;
        this.trades = trades;
    }

    public int getRank() {
        return rank;
    }

    public String getName() {
        return name;
    }

    public String getStyle() {
        return style;
    }

    public String getLlm() {
        return llm;
    }

    public String getReturnRate() {
        return returnRate;
    }

    public String getMdd() {
        return mdd;
    }

    public String getTrades() {
        return trades;
    }
}
