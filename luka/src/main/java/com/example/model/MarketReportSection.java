package com.example.model;

import java.util.List;

public class MarketReportSection {

    private final String title;
    private final int level;
    private final List<MarketReportBlock> blocks;

    public MarketReportSection(String title, List<String> items) {
        this(title, 2, List.of(new MarketReportBlock(null, items, null)));
    }

    public MarketReportSection(String title, int level, List<MarketReportBlock> blocks) {
        this.title = title;
        this.level = level;
        this.blocks = blocks == null ? List.of() : blocks;
    }

    public String getTitle() {
        return title;
    }

    public int getLevel() {
        return level;
    }

    public boolean isSubsection() {
        return level >= 3;
    }

    public List<MarketReportBlock> getBlocks() {
        return blocks;
    }

    public List<String> getItems() {
        return blocks.stream().flatMap(block -> block.getItems().stream()).toList();
    }
}
