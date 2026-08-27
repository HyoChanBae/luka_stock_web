package com.example.model;

public class SummaryItem {

    private final String kind;
    private final String value;
    private final String detail;

    public SummaryItem(String kind, String value, String detail) {
        this.kind = kind;
        this.value = value;
        this.detail = detail;
    }

    public String getKind() {
        return kind;
    }

    public String getValue() {
        return value;
    }

    public String getDetail() {
        return detail;
    }
}
