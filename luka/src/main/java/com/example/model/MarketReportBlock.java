package com.example.model;

import java.util.List;

public class MarketReportBlock {

    private final String heading;
    private final List<String> items;
    private final MarketReportTable table;

    public MarketReportBlock(String heading, List<String> items, MarketReportTable table) {
        this.heading = heading;
        this.items = items == null ? List.of() : items;
        this.table = table;
    }

    public String getHeading() {
        return heading;
    }

    public List<String> getItems() {
        return items;
    }

    public MarketReportTable getTable() {
        return table;
    }
}
