package com.example.model;

public class ScenarioForm {

    private String capital = "10000000";
    private String currency = "KRW";
    private String botType = "지수 안정형";
    private String risk = "중립";
    private String targetReturn = "12%";
    private String maxDrawdown = "-10%";

    public String getCapital() {
        return capital;
    }

    public void setCapital(String capital) {
        this.capital = capital;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getBotType() {
        return botType;
    }

    public void setBotType(String botType) {
        this.botType = botType;
    }

    public String getRisk() {
        return risk;
    }

    public void setRisk(String risk) {
        this.risk = risk;
    }

    public String getTargetReturn() {
        return targetReturn;
    }

    public void setTargetReturn(String targetReturn) {
        this.targetReturn = targetReturn;
    }

    public String getMaxDrawdown() {
        return maxDrawdown;
    }

    public void setMaxDrawdown(String maxDrawdown) {
        this.maxDrawdown = maxDrawdown;
    }
}
