package com.example.model;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

final class MarketReportParser {

    private static final Pattern SOURCE_TIME = Pattern.compile("^기준 시각:\\s*(.+)$");
    private static final Pattern MARKDOWN_HEADING = Pattern.compile("^(#{2,3})\\s*(.+)$");
    private static final Pattern BULLET = Pattern.compile("^[-*•·ㆍ]\\s*(.+)$");

    private MarketReportParser() {
    }

    static Parsed parse(String raw) {
        if (raw == null || raw.isBlank()) {
            return new Parsed(null, List.of());
        }
        String normalized = raw.replace("\r\n", "\n");
        String sourceTime = extractSourceTime(normalized);
        if (hasMarkdownHeading(normalized)) {
            return new Parsed(sourceTime, parseMarkdown(normalized));
        }
        return new Parsed(sourceTime, parsePlain(normalized));
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

    private static String extractSourceTime(String raw) {
        for (String line : raw.split("\n")) {
            Matcher matcher = SOURCE_TIME.matcher(line.trim());
            if (matcher.matches()) {
                return matcher.group(1).trim();
            }
        }
        return null;
    }

    private static boolean hasMarkdownHeading(String raw) {
        for (String line : raw.split("\n")) {
            if (MARKDOWN_HEADING.matcher(line.trim()).matches()) {
                return true;
            }
        }
        return false;
    }

    private static List<MarketReportSection> parsePlain(String raw) {
        List<MarketReportSection> sections = new ArrayList<>();
        String title = null;
        List<String> items = new ArrayList<>();
        for (String line : raw.split("\n")) {
            String text = line.trim();
            if (text.isEmpty() || SOURCE_TIME.matcher(text).matches()) {
                continue;
            }
            Matcher bullet = BULLET.matcher(text);
            if (bullet.matches() || text.startsWith("-")) {
                String item = bullet.matches() ? bullet.group(1).trim() : text.replaceFirst("^-\\s*", "").trim();
                if (!item.isEmpty()) {
                    items.addAll(expandItem(item));
                }
                continue;
            }
            flushPlain(sections, title, items);
            title = text.replaceAll("\\s+-\\s*$", "").trim();
            items = new ArrayList<>();
        }
        flushPlain(sections, title, items);
        return sections;
    }

    private static void flushPlain(List<MarketReportSection> sections, String title, List<String> items) {
        if (title == null || title.isBlank() || items.isEmpty()) {
            return;
        }
        sections.add(new MarketReportSection(title, List.copyOf(items)));
    }

    private static List<MarketReportSection> parseMarkdown(String raw) {
        Builder builder = new Builder();
        for (String line : raw.split("\n")) {
            String text = line.trim();
            if (text.isEmpty()) {
                continue;
            }
            if (SOURCE_TIME.matcher(text).matches()) {
                continue;
            }
            if (isTableSeparator(text)) {
                continue;
            }
            if (isTableRow(text)) {
                builder.addTableRow(parseTableCells(text));
                continue;
            }
            builder.finishTable();
            Matcher heading = MARKDOWN_HEADING.matcher(text);
            if (heading.matches()) {
                builder.startSection(heading.group(2).trim(), heading.group(1).length());
                continue;
            }
            Matcher bullet = BULLET.matcher(text);
            if (bullet.matches() || text.startsWith("-")) {
                String item = bullet.matches() ? bullet.group(1).trim() : text.replaceFirst("^-\\s*", "").trim();
                if (!item.isEmpty()) {
                    builder.addItems(expandItem(item));
                }
                continue;
            }
            builder.startBlock(text.replaceAll("\\s+-\\s*$", "").trim());
        }
        return builder.build();
    }

    private static List<String> expandItem(String text) {
        String[] parts = text.split("\\s*;\\s*");
        if (parts.length >= 3) {
            List<String> items = new ArrayList<>();
            for (String part : parts) {
                String item = part.trim();
                if (!item.isEmpty()) {
                    items.add(item);
                }
            }
            return items;
        }
        return splitSentences(text);
    }

    private static boolean isTableRow(String text) {
        return text.startsWith("|") && text.indexOf('|', 1) >= 0;
    }

    private static boolean isTableSeparator(String text) {
        String compact = text.replace(" ", "");
        return compact.matches("^\\|?(:?-+:?\\|)+?:?-+:?\\|?$");
    }

    private static List<String> parseTableCells(String text) {
        String body = text;
        if (body.startsWith("|")) {
            body = body.substring(1);
        }
        if (body.endsWith("|")) {
            body = body.substring(0, body.length() - 1);
        }
        List<String> cells = new ArrayList<>();
        for (String cell : body.split("\\|", -1)) {
            cells.add(cell.trim());
        }
        return cells;
    }

    private static final class Builder {
        private final List<MarketReportSection> sections = new ArrayList<>();
        private String title;
        private int level = 2;
        private final List<MarketReportBlock> blocks = new ArrayList<>();
        private String blockHeading;
        private List<String> blockItems = new ArrayList<>();
        private List<String> tableHeaders;
        private List<List<MarketReportTableCell>> tableRows;

        private void startSection(String nextTitle, int nextLevel) {
            flushSection();
            title = nextTitle;
            level = nextLevel;
        }

        private void startBlock(String heading) {
            finishTable();
            flushBlock();
            blockHeading = heading;
        }

        private void addItems(List<String> items) {
            finishTable();
            ensureSection();
            blockItems.addAll(items);
        }

        private void addTableRow(List<String> cells) {
            ensureSection();
            if (tableHeaders == null) {
                flushBlock();
                tableHeaders = cells;
                tableRows = new ArrayList<>();
                return;
            }
            List<MarketReportTableCell> row = new ArrayList<>();
            for (String cell : cells) {
                row.add(new MarketReportTableCell(cell));
            }
            tableRows.add(List.copyOf(row));
        }

        private void finishTable() {
            if (tableHeaders == null) {
                return;
            }
            flushBlock();
            blocks.add(new MarketReportBlock(
                    null,
                    List.of(),
                    new MarketReportTable(List.copyOf(tableHeaders), List.copyOf(tableRows))
            ));
            tableHeaders = null;
            tableRows = null;
        }

        private void flushBlock() {
            if ((blockHeading == null || blockHeading.isBlank()) && blockItems.isEmpty()) {
                return;
            }
            blocks.add(new MarketReportBlock(blockHeading, List.copyOf(blockItems), null));
            blockHeading = null;
            blockItems = new ArrayList<>();
        }

        private void flushSection() {
            finishTable();
            flushBlock();
            if (title != null && !title.isBlank()) {
                sections.add(new MarketReportSection(title, level, List.copyOf(blocks)));
            }
            title = null;
            level = 2;
            blocks.clear();
        }

        private void ensureSection() {
            if (title == null || title.isBlank()) {
                title = "섹터 리포트";
                level = 2;
            }
        }

        private List<MarketReportSection> build() {
            flushSection();
            return List.copyOf(sections);
        }
    }

    record Parsed(String sourceTime, List<MarketReportSection> sections) {
    }
}
