package com.example.service;

import com.example.model.BotRank;
import com.example.model.BotTrade;
import com.example.model.BotTradeHistory;
import com.example.repository.BotScenarioRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@Service
public class BotScenarioService {

    private static final Logger LOG = Logger.getLogger(BotScenarioService.class.getName());

    private final BotScenarioRepository botScenarioRepository;

    public BotScenarioService(BotScenarioRepository botScenarioRepository) {
        this.botScenarioRepository = botScenarioRepository;
    }

    public List<BotRank> league() {
        try {
            return botScenarioRepository.findLeague();
        } catch (Exception ex) {
            return List.of();
        }
    }

    public BotTradeHistory trades(long botId) {
        List<BotTrade> trades;
        try {
            trades = botScenarioRepository.findTrades(botId);
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "시나리오 봇 거래내역 조회 실패 botId=" + botId, ex);
            trades = List.of();
        }
        LocalDateTime updatedAt = null;
        try {
            updatedAt = botScenarioRepository.findLatestCurrentPriceUpdateDt();
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "현재가 업데이트 시각 조회 실패", ex);
        }
        return new BotTradeHistory(trades, updatedAt);
    }
}
