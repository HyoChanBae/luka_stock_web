package com.example.model;

public class LabeledValue {

    private final String label;
    private final String value;

    public LabeledValue(String label, String value) {
        this.label = label;
        this.value = value;
    }

    public String getLabel() {
        return label;
    }

    public String getValue() {
        return value;
    }
}
