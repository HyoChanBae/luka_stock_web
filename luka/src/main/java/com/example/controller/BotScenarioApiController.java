package com.example.controller;

import com.example.model.BotTradeHistory;
import com.example.service.BotScenarioService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/bots-scenario")
public class BotScenarioApiController {

    private final BotScenarioService botScenarioService;

    public BotScenarioApiController(BotScenarioService botScenarioService) {
        this.botScenarioService = botScenarioService;
    }

    @GetMapping(value = "/{botId}/trades", produces = MediaType.APPLICATION_JSON_VALUE)
    public BotTradeHistory trades(@PathVariable("botId") long botId) {
        return botScenarioService.trades(botId);
    }
}
