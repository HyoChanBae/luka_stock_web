package com.example.service;

import com.example.model.BotRank;
import com.example.model.BotTrade;
import com.example.repository.BotScenarioRepository;
import org.springframework.stereotype.Service;

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

    public List<BotTrade> trades(long botId) {
        try {
            return botScenarioRepository.findTrades(botId);
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "시나리오 봇 거래내역 조회 실패 botId=" + botId, ex);
            return List.of();
        }
    }
}
