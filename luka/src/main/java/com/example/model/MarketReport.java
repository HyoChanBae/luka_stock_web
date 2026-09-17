package com.example.model;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class MarketReport {

    private static final DateTimeFormatter DISPLAY =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    private static final ObjectMapper JSON = new ObjectMapper();
    private static final Map<String, String> REGIME_SUMMARIES = Map.ofEntries(
            Map.entry("GOLDILOCKS", "성장은 버티고 물가는 내려가는, 위험자산에 가장 우호적인 조합"),
            Map.entry("골디락스", "성장은 버티고 물가는 내려가는, 위험자산에 가장 우호적인 조합"),
            Map.entry("REFLATION", "성장과 물가가 함께 올라가는, 실물·경기민감 자산이 앞서는 조합"),
            Map.entry("리플레이션", "성장과 물가가 함께 올라가는, 실물·경기민감 자산이 앞서는 조합"),
            Map.entry("STAGFLATION", "성장은 꺾이는데 물가는 버티는, 방어와 실물자산이 동시에 필요한 조합"),
            Map.entry("스태그플레이션", "성장은 꺾이는데 물가는 버티는, 방어와 실물자산이 동시에 필요한 조합"),
            Map.entry("SLOWDOWN", "성장과 물가가 함께 내려가는, 금리 민감 방어주와 채권이 앞서는 조합"),
            Map.entry("둔화·디스인플레", "성장과 물가가 함께 내려가는, 금리 민감 방어주와 채권이 앞서는 조합"),
            Map.entry("둔화-디스인플레", "성장과 물가가 함께 내려가는, 금리 민감 방어주와 채권이 앞서는 조합"),
            Map.entry("UNRESOLVED", "성장 또는 물가 축을 산출할 수 없어 4분면 중 어디인지 특정하지 못하는 상태"),
            Map.entry("판정 보류", "성장 또는 물가 축을 산출할 수 없어 4분면 중 어디인지 특정하지 못하는 상태")
    );

    private final String report;
    private final LocalDateTime createdAt;
    private final String marketContext;
    private final String marketContextLabel;
    private final String marketContextSummary;
    private final String sourceTime;
    private final List<MarketReportSection> sections;

    public MarketReport(String report, LocalDateTime createdAt) {
        this(report, createdAt, null);
    }

    public MarketReport(String report, LocalDateTime createdAt, String marketContext) {
        this.report = report;
        this.createdAt = createdAt;
        this.marketContext = marketContext == null ? null : marketContext.trim();
        MarketContextView contextView = MarketContextView.parse(this.marketContext);
        this.marketContextLabel = contextView.label();
        this.marketContextSummary = contextView.summary();
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

    public String getMarketContext() {
        return marketContext;
    }

    public String getMarketContextLabel() {
        return marketContextLabel;
    }

    public String getMarketContextSummary() {
        return marketContextSummary;
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

    private record MarketContextView(String label, String summary) {
        static MarketContextView parse(String raw) {
            if (raw == null || raw.isBlank()) {
                return new MarketContextView(null, null);
            }
            if (!raw.startsWith("{") && !raw.startsWith("[")) {
                return new MarketContextView(raw, defaultSummary(null, raw));
            }
            try {
                JsonNode root = JSON.readTree(raw);
                JsonNode regime = root.path("regime");
                String key = text(regime, "key");
                String label = text(regime, "name");
                if (label == null) {
                    label = key;
                }
                String summary = defaultSummary(key, label);
                if (summary == null) {
                    summary = text(regime, "summary");
                }
                return new MarketContextView(label, summary);
            } catch (Exception ex) {
                return new MarketContextView(null, null);
            }
        }

        private static String defaultSummary(String key, String label) {
            String fromKey = lookupSummary(key);
            if (fromKey != null) {
                return fromKey;
            }
            return lookupSummary(label);
        }

        private static String lookupSummary(String value) {
            if (value == null || value.isBlank()) {
                return null;
            }
            String summary = REGIME_SUMMARIES.get(value.trim());
            if (summary != null) {
                return summary;
            }
            return REGIME_SUMMARIES.get(value.trim().toUpperCase(Locale.ROOT));
        }

        private static String text(JsonNode node, String field) {
            JsonNode value = node.path(field);
            if (value.isMissingNode() || value.isNull()) {
                return null;
            }
            String text = value.asText("").trim();
            return text.isEmpty() ? null : text;
        }
    }
}
