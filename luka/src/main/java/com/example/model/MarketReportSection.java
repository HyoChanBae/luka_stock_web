package com.example.model;

import java.util.List;

public class MarketReportSection {

    private final String title;
    private final List<String> items;

    public MarketReportSection(String title, List<String> items) {
        this.title = title;
        this.items = items;
    }

    public String getTitle() {
        return title;
    }

    public List<String> getItems() {
        return items;
    }
}
