package com.example.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class MarketReport {

    private static final DateTimeFormatter DISPLAY =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final String report;
    private final LocalDateTime createdAt;
    private final List<MarketReportSection> sections;

    public MarketReport(String report, LocalDateTime createdAt) {
        this.report = report;
        this.createdAt = createdAt;
        this.sections = parseSections(report);
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

    public String getCreatedAtDisplay() {
        if (createdAt == null) {
            return "";
        }
        return createdAt.format(DISPLAY);
    }

    static List<MarketReportSection> parseSections(String raw) {
        List<MarketReportSection> sections = new ArrayList<>();
        if (raw == null || raw.isBlank()) {
            return sections;
        }

        String title = null;
        List<String> items = new ArrayList<>();
        for (String line : raw.replace("\r\n", "\n").split("\n")) {
            String text = line.trim();
            if (text.isEmpty()) {
                continue;
            }
            if (text.startsWith("-")) {
                String item = text.replaceFirst("^-\\s*", "").trim();
                if (!item.isEmpty()) {
                    items.addAll(splitSentences(item));
                }
                continue;
            }
            flush(sections, title, items);
            title = text.replaceAll("\\s+-\\s*$", "").trim();
            items = new ArrayList<>();
        }
        flush(sections, title, items);
        return sections;
    }

    static List<String> splitSentences(String text) {
        List<String> sentences = new ArrayList<>();
        for (String part : text.split("(?<=[.。])\\s+")) {
            String sentence = part.trim();
            if (!sentence.isEmpty()) {
                sentences.add(sentence);
            }
        }
        return sentences;
    }

    private static void flush(List<MarketReportSection> sections, String title, List<String> items) {
        if ((title == null || title.isBlank()) && items.isEmpty()) {
            return;
        }
        sections.add(new MarketReportSection(
                title == null || title.isBlank() ? "리포트" : title,
                List.copyOf(items)
        ));
    }
}
