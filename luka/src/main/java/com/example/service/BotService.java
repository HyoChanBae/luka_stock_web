package com.example.service;

import com.example.model.BotRank;
import com.example.model.BotTrade;
import com.example.model.BotTradeHistory;
import com.example.repository.BotRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@Service
public class BotService {

    private static final Logger LOG = Logger.getLogger(BotService.class.getName());

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

    public BotTradeHistory trades(long botId) {
        List<BotTrade> trades;
        try {
            trades = botRepository.findTrades(botId);
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "봇 거래내역 조회 실패 botId=" + botId, ex);
            trades = List.of();
        }
        LocalDateTime updatedAt = null;
        try {
            updatedAt = botRepository.findLatestCurrentPriceUpdateDt();
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "현재가 업데이트 시각 조회 실패", ex);
        }
        return new BotTradeHistory(trades, updatedAt);
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

    public void addTrade(
            long botId,
            String symbol,
            String symbolName,
            String selectReason,
            Double buyPrice,
            LocalDateTime buyAt
    ) {
        botRepository.insertTrade(botId, symbol, symbolName, selectReason, buyPrice, buyAt);
    }
}
