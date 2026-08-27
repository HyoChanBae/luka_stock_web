package com.example.model;

public class AlertSetting {

    private final String title;
    private final String description;
    private final boolean enabled;

    public AlertSetting(String title, String description, boolean enabled) {
        this.title = title;
        this.description = description;
        this.enabled = enabled;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public boolean isEnabled() {
        return enabled;
    }
}
