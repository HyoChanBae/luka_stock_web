package com.example.web;

import org.springframework.ui.Model;

public final class PageAttributes {

    private PageAttributes() {
    }

    public static void apply(Model model, String activeNav, String pageTitle) {
        model.addAttribute("activeNav", activeNav);
        model.addAttribute("pageTitle", pageTitle);
        model.addAttribute(
                "pageSubtitle",
                "복잡한 시장 정보 대신, 지금 알아야 할 것부터 보여드려요."
        );
    }
}
