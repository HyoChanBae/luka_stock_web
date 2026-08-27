package com.example.model;

public class ScenarioResult {

    private final String estimatedAmount;
    private final String monthlyRateLabel;
    private final String stockWeight;
    private final String cashWeight;
    private final String maxMdd;

    public ScenarioResult(
            String estimatedAmount,
            String monthlyRateLabel,
            String stockWeight,
            String cashWeight,
            String maxMdd
    ) {
        this.estimatedAmount = estimatedAmount;
        this.monthlyRateLabel = monthlyRateLabel;
        this.stockWeight = stockWeight;
        this.cashWeight = cashWeight;
        this.maxMdd = maxMdd;
    }

    public String getEstimatedAmount() {
        return estimatedAmount;
    }

    public String getMonthlyRateLabel() {
        return monthlyRateLabel;
    }

    public String getStockWeight() {
        return stockWeight;
    }

    public String getCashWeight() {
        return cashWeight;
    }

    public String getMaxMdd() {
        return maxMdd;
    }
}
