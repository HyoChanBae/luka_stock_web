package com.example.model;

public class BotRank {

    private final long botId;
    private final int rank;
    private final String code;
    private final String name;
    private final String description;
    private final String modelType;
    private final Double dailyReturn;
    private final Double cumReturn;

    public BotRank(
            long botId,
            int rank,
            String code,
            String name,
            String description,
            String modelType,
            Double dailyReturn,
            Double cumReturn
    ) {
        this.botId = botId;
        this.rank = rank;
        this.code = code;
        this.name = name;
        this.description = description;
        this.modelType = modelType;
        this.dailyReturn = dailyReturn;
        this.cumReturn = cumReturn;
    }

    public long getBotId() {
        return botId;
    }

    public int getRank() {
        return rank;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getModelType() {
        return modelType;
    }

    public Double getDailyReturn() {
        return dailyReturn;
    }

    public Double getCumReturn() {
        return cumReturn;
    }

    public String getDailyDisplay() {
        return formatPercent(dailyReturn);
    }

    public String getCumDisplay() {
        return formatPercent(cumReturn);
    }

    public String getDailyClass() {
        return cssClass(dailyReturn);
    }

    public String getCumClass() {
        return cssClass(cumReturn);
    }

    private static String formatPercent(Double value) {
        if (value == null) {
            return "—";
        }
        return String.format(java.util.Locale.US, "%+.1f%%", value);
    }

    private static String cssClass(Double value) {
        if (value == null || value < 0) {
            return "neg";
        }
        return "perf";
    }
}
