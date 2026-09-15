package com.example.controller;

import com.example.service.BotScenarioService;
import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/bots-scenario")
public class BotScenarioController {

    private final BotScenarioService botScenarioService;

    public BotScenarioController(BotScenarioService botScenarioService) {
        this.botScenarioService = botScenarioService;
    }

    @GetMapping
    public String botsScenario(Model model) {
        PageAttributes.apply(model, "bots-scenario", "봇 랭킹_시나리오");
        model.addAttribute("botLeague", botScenarioService.league());
        return "bots-scenario";
    }
}
