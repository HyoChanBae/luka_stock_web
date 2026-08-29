package com.example.controller;

import com.example.service.BotService;
import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/bots")
public class BotController {

    private final BotService botService;

    public BotController(BotService botService) {
        this.botService = botService;
    }

    @GetMapping
    public String bots(Model model) {
        PageAttributes.apply(model, "bots", "봇 랭킹");
        model.addAttribute("botLeague", botService.league());
        return "bots";
    }
}
