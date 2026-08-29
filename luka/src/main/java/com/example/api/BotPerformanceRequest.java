package com.example.api;

public class BotPerformanceRequest {

    private String perfDate;
    private Double dailyReturn;
    private Double cumReturn;

    public String getPerfDate() {
        return perfDate;
    }

    public void setPerfDate(String perfDate) {
        this.perfDate = perfDate;
    }

    public Double getDailyReturn() {
        return dailyReturn;
    }

    public void setDailyReturn(Double dailyReturn) {
        this.dailyReturn = dailyReturn;
    }

    public Double getCumReturn() {
        return cumReturn;
    }

    public void setCumReturn(Double cumReturn) {
        this.cumReturn = cumReturn;
    }
}
