package com.example.api;

public class BotCreateRequest {

    private String botCode;
    private String botName;
    private String description;
    private String modelType;
    private String strategyType;

    public String getBotCode() {
        return botCode;
    }

    public void setBotCode(String botCode) {
        this.botCode = botCode;
    }

    public String getBotName() {
        return botName;
    }

    public void setBotName(String botName) {
        this.botName = botName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getModelType() {
        return modelType;
    }

    public void setModelType(String modelType) {
        this.modelType = modelType;
    }

    public String getStrategyType() {
        return strategyType;
    }

    public void setStrategyType(String strategyType) {
        this.strategyType = strategyType;
    }
}
