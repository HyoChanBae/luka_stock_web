package com.example.model;

public class MarketReportTableCell {

    private final String text;
    private final String tone;

    public MarketReportTableCell(String text) {
        this.text = text == null ? "" : text;
        this.tone = toneOf(this.text);
    }

    public String getText() {
        return text;
    }

    public String getTone() {
        return tone;
    }

    static String toneOf(String text) {
        String value = text.trim();
        if (value.matches("^[+▲]\\s*\\d.*")) {
            return "pos";
        }
        if (value.matches("^[-−▼]\\s*\\d.*")) {
            return "neg";
        }
        return "";
    }
}
