package com.example.controller;

import com.example.service.InvestmentMockService;
import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/bots")
public class BotController {

    private final InvestmentMockService investmentMockService;

    public BotController(InvestmentMockService investmentMockService) {
        this.investmentMockService = investmentMockService;
    }

    @GetMapping
    public String bots(Model model) {
        PageAttributes.apply(model, "bots", "봇 랭킹");
        model.addAttribute("botLeague", investmentMockService.botLeague());
        model.addAttribute("botTypes", investmentMockService.botTypes());
        return "bots";
    }
}
