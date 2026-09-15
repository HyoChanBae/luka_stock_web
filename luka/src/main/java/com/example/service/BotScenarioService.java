package com.example.service;

import com.example.model.BotRank;
import com.example.model.BotTrade;
import com.example.repository.BotScenarioRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BotScenarioService {

    private final BotScenarioRepository botScenarioRepository;
    private final DummyQuoteService dummyQuoteService;

    public BotScenarioService(BotScenarioRepository botScenarioRepository, DummyQuoteService dummyQuoteService) {
        this.botScenarioRepository = botScenarioRepository;
        this.dummyQuoteService = dummyQuoteService;
    }

    public List<BotRank> league() {
        try {
            return botScenarioRepository.findLeague();
        } catch (Exception ex) {
            return List.of();
        }
    }

    public List<BotTrade> trades(long botId) {
        try {
            return botScenarioRepository.findTrades(botId).stream()
                    .map(trade -> trade.withLastPrice(
                            dummyQuoteService.lastPrice(trade.getSymbol(), trade.getBuyPrice())
                    ))
                    .toList();
        } catch (Exception ex) {
            return List.of();
        }
    }
}
