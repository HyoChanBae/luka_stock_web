package com.example.model;

public class Decision {

    private final String title;
    private final String description;
    private final String actionLabel;
    private final String actionClass;
    private final String reasonLabel;
    private final String reasonTitle;
    private final String reasonText;

    public Decision(
            String title,
            String description,
            String actionLabel,
            String actionClass,
            String reasonLabel,
            String reasonTitle,
            String reasonText
    ) {
        this.title = title;
        this.description = description;
        this.actionLabel = actionLabel;
        this.actionClass = actionClass;
        this.reasonLabel = reasonLabel;
        this.reasonTitle = reasonTitle;
        this.reasonText = reasonText;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getActionLabel() {
        return actionLabel;
    }

    public String getActionClass() {
        return actionClass;
    }

    public String getReasonLabel() {
        return reasonLabel;
    }

    public String getReasonTitle() {
        return reasonTitle;
    }

    public String getReasonText() {
        return reasonText;
    }
}
