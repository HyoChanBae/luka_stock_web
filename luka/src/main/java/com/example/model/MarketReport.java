package com.example.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class MarketReport {

    private static final DateTimeFormatter DISPLAY =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final String report;
    private final LocalDateTime createdAt;
    private final String sourceTime;
    private final List<MarketReportSection> sections;

    public MarketReport(String report, LocalDateTime createdAt) {
        this.report = report;
        this.createdAt = createdAt;
        MarketReportParser.Parsed parsed = MarketReportParser.parse(report);
        this.sourceTime = parsed.sourceTime();
        this.sections = parsed.sections();
    }

    public String getReport() {
        return report;
    }

    public List<MarketReportSection> getSections() {
        return sections;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public String getSourceTime() {
        return sourceTime;
    }

    public String getCreatedAtDisplay() {
        if (sourceTime != null && !sourceTime.isBlank()) {
            return sourceTime;
        }
        if (createdAt == null) {
            return "";
        }
        return createdAt.format(DISPLAY);
    }
}
