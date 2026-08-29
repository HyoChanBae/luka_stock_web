package com.example.controller;

import com.example.api.BotCreateRequest;
import com.example.api.BotPerformanceRequest;
import com.example.api.BotTradeRequest;
import com.example.model.BotRank;
import com.example.model.BotTrade;
import com.example.service.BotService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bots")
public class BotApiController {

    private final BotService botService;

    public BotApiController(BotService botService) {
        this.botService = botService;
    }

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public List<BotRank> list() {
        return botService.league();
    }

    @GetMapping(value = "/{botId}/trades", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<BotTrade> trades(@PathVariable("botId") long botId) {
        return botService.trades(botId);
    }

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> create(@RequestBody BotCreateRequest request) {
        long botId = botService.createBot(
                request.getBotCode(),
                request.getBotName(),
                request.getDescription(),
                request.getModelType(),
                request.getStrategyType()
        );
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("ok", true);
        result.put("botId", botId);
        return result;
    }

    @PostMapping(
            value = "/{botId}/performance",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public Map<String, Object> performance(
            @PathVariable("botId") long botId,
            @RequestBody BotPerformanceRequest request
    ) {
        LocalDate date = request.getPerfDate() == null || request.getPerfDate().isBlank()
                ? LocalDate.now()
                : LocalDate.parse(request.getPerfDate());
        botService.savePerformance(botId, date, request.getDailyReturn(), request.getCumReturn());
        return Map.of("ok", true, "botId", botId);
    }

    @PostMapping(
            value = "/{botId}/trades",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public Map<String, Object> addTrade(
            @PathVariable("botId") long botId,
            @RequestBody BotTradeRequest request
    ) {
        botService.addTrade(
                botId,
                request.getSymbol(),
                request.getSelectReason(),
                request.getBuyPrice(),
                parseDateTime(request.getBuyAt())
        );
        return Map.of("ok", true, "botId", botId);
    }

    private LocalDateTime parseDateTime(String raw) {
        if (raw == null || raw.isBlank()) {
            return LocalDateTime.now();
        }
        String normalized = raw.trim().replace(' ', 'T');
        if (normalized.length() == 10) {
            return LocalDate.parse(normalized).atStartOfDay();
        }
        if (normalized.length() == 16) {
            normalized = normalized + ":00";
        }
        if (normalized.length() > 19) {
            normalized = normalized.substring(0, 19);
        }
        return LocalDateTime.parse(normalized);
    }
}
