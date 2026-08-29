package com.example.config;

import com.example.repository.BotRepository;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.logging.Level;
import java.util.logging.Logger;

@Component
public class BotSchemaInitializer implements InitializingBean {

    private static final Logger LOG = Logger.getLogger(BotSchemaInitializer.class.getName());

    private final BotRepository botRepository;

    public BotSchemaInitializer(BotRepository botRepository) {
        this.botRepository = botRepository;
    }

    @Override
    public void afterPropertiesSet() {
        try {
            botRepository.ensureSchema();
            if (botRepository.countBots() == 0) {
                seed();
            }
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "Snowflake 봇 테이블 초기화 실패", ex);
        }
    }

    private void seed() {
        LocalDate today = LocalDate.now();
        long wave = botRepository.insertBot(
                "trading_buy1_bot",
                "trading_buy1_bot",
                "파도타기",
                "GPT",
                "Swing"
        );
        long macro = botRepository.insertBot(
                "macroshield",
                "MacroShield",
                "거시 안정형",
                "Claude",
                "Macro"
        );
        long value = botRepository.insertBot(
                "bookvalue",
                "BookValue",
                "가치투자",
                "GPT",
                "Value"
        );
        long vol = botRepository.insertBot(
                "volquant",
                "VolQuant",
                "변동성 퀀트",
                "Rule+LLM",
                "Quant"
        );

        botRepository.upsertPerformance(wave, today, 12.4, -5.1);
        botRepository.upsertPerformance(macro, today, 9.7, -2.4);
        botRepository.upsertPerformance(value, today, 8.1, -4.0);
        botRepository.upsertPerformance(vol, today, 6.8, -7.8);

        botRepository.insertTrade(
                wave,
                "NVDA",
                "LLM 수요와 반도체 상대강도가 함께 유지되어 분할 매수 구간으로 판단했습니다.",
                128.45,
                LocalDateTime.now().minusDays(2).withHour(10).withMinute(21).withSecond(0).withNano(0)
        );
        botRepository.insertTrade(
                wave,
                "SMR",
                "원전 계약 모멘텀은 유효하나 ATM 리스크를 고려해 소량만 편입했습니다.",
                18.32,
                LocalDateTime.now().minusDays(1).withHour(14).withMinute(5).withSecond(0).withNano(0)
        );
        botRepository.insertTrade(
                macro,
                "QQQ",
                "금리 민감 구간에서 지수 ETF로 위험 노출을 낮추는 편이 낫다고 판단했습니다.",
                492.10,
                LocalDateTime.now().minusDays(3).withHour(9).withMinute(40).withSecond(0).withNano(0)
        );
    }
}
