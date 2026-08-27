package com.example.model;

public class BotType {

    private final String title;
    private final String description;
    private final String chip;
    private final String modalTitle;
    private final String modalText;

    public BotType(String title, String description, String chip, String modalTitle, String modalText) {
        this.title = title;
        this.description = description;
        this.chip = chip;
        this.modalTitle = modalTitle;
        this.modalText = modalText;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getChip() {
        return chip;
    }

    public String getModalTitle() {
        return modalTitle;
    }

    public String getModalText() {
        return modalText;
    }
}
