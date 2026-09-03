package com.example.config;

import com.example.repository.BotRepository;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.stereotype.Component;

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
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "Snowflake 봇 테이블 초기화 실패", ex);
        }
    }
}
