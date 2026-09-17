package com.example.model;

import java.util.List;

public class MarketReportTable {

    private final List<String> headers;
    private final List<List<MarketReportTableCell>> rows;

    public MarketReportTable(List<String> headers, List<List<MarketReportTableCell>> rows) {
        this.headers = headers;
        this.rows = rows;
    }

    public List<String> getHeaders() {
        return headers;
    }

    public List<List<MarketReportTableCell>> getRows() {
        return rows;
    }
}
