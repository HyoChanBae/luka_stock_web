package com.example.service;

import com.example.model.BotRank;
import com.example.model.BotTrade;
import com.example.repository.BotRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class BotService {

    private final BotRepository botRepository;

    public BotService(BotRepository botRepository) {
        this.botRepository = botRepository;
    }

    public List<BotRank> league() {
        try {
            return botRepository.findLeague();
        } catch (Exception ex) {
            return List.of();
        }
    }

    public List<BotTrade> trades(long botId) {
        try {
            return botRepository.findTrades(botId);
        } catch (Exception ex) {
            return List.of();
        }
    }

    public BotRank find(long botId) {
        return league().stream()
                .filter(bot -> bot.getBotId() == botId)
                .findFirst()
                .orElse(null);
    }

    public long createBot(String code, String name, String description, String modelType, String strategyType) {
        return botRepository.insertBot(code, name, description, modelType, strategyType);
    }

    public void savePerformance(long botId, LocalDate perfDate, Double dailyReturn, Double cumReturn) {
        botRepository.upsertPerformance(botId, perfDate, dailyReturn, cumReturn);
    }

    public void addTrade(long botId, String symbol, String selectReason, Double buyPrice, LocalDateTime buyAt) {
        botRepository.insertTrade(botId, symbol, selectReason, buyPrice, buyAt);
    }
}
