package com.example.controller;

import com.example.config.ChartProperties;
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
    private final ChartProperties chartProperties;

    public BotScenarioController(BotScenarioService botScenarioService, ChartProperties chartProperties) {
        this.botScenarioService = botScenarioService;
        this.chartProperties = chartProperties;
    }

    @GetMapping
    public String botsScenario(Model model) {
        PageAttributes.apply(model, "bots-scenario", "봇 랭킹_시나리오");
        model.addAttribute("botLeague", botScenarioService.league());
        model.addAttribute("chartEmbedUrl", chartProperties.getEmbedUrl());
        return "bots-scenario";
    }
}
