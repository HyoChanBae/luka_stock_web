package com.example.model;

public class Position {

    private final String ticker;
    private final String name;
    private final String strategy;
    private final String weight;
    private final String returnRate;
    private final String returnClass;
    private final String chip;

    public Position(
            String ticker,
            String name,
            String strategy,
            String weight,
            String returnRate,
            String returnClass,
            String chip
    ) {
        this.ticker = ticker;
        this.name = name;
        this.strategy = strategy;
        this.weight = weight;
        this.returnRate = returnRate;
        this.returnClass = returnClass;
        this.chip = chip;
    }

    public String getTicker() {
        return ticker;
    }

    public String getName() {
        return name;
    }

    public String getStrategy() {
        return strategy;
    }

    public String getWeight() {
        return weight;
    }

    public String getReturnRate() {
        return returnRate;
    }

    public String getReturnClass() {
        return returnClass;
    }

    public String getChip() {
        return chip;
    }
}
