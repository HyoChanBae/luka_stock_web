package com.example.repository;

import com.example.model.BotRank;
import com.example.model.BotTrade;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public class BotRepository {

    private final JdbcTemplate jdbcTemplate;

    public BotRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void ensureSchema() {
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS DEMO_RAW_DB.RAW.BOT (
                    BOT_ID          NUMBER AUTOINCREMENT START 1 INCREMENT 1,
                    BOT_CODE        VARCHAR(100) NOT NULL UNIQUE,
                    BOT_NAME        VARCHAR(200) NOT NULL,
                    DESCRIPTION     VARCHAR(500),
                    MODEL_TYPE      VARCHAR(50),
                    STRATEGY_TYPE   VARCHAR(100),
                    PAPER_TRADING   CHAR(1) DEFAULT 'Y',
                    IS_ACTIVE       CHAR(1) DEFAULT 'Y',
                    CREATED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
                )
                """);
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS DEMO_RAW_DB.RAW.BOT_PERF_DAILY (
                    BOT_ID          NUMBER NOT NULL,
                    PERF_DATE       DATE NOT NULL,
                    DAILY_RETURN    FLOAT,
                    CUM_RETURN      FLOAT,
                    PRIMARY KEY (BOT_ID, PERF_DATE)
                )
                """);
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS DEMO_RAW_DB.RAW.BOT_TRADE (
                    TRADE_ID        NUMBER AUTOINCREMENT START 1 INCREMENT 1,
                    BOT_ID          NUMBER NOT NULL,
                    SYMBOL          VARCHAR(100) NOT NULL,
                    SELECT_REASON   VARCHAR(1000),
                    BUY_PRICE       NUMBER(18, 4),
                    BUY_AT          TIMESTAMP_NTZ NOT NULL,
                    CREATED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
                )
                """);
    }

    public List<BotRank> findLeague() {
        return jdbcTemplate.query(
                """
                SELECT
                    ROW_NUMBER() OVER (ORDER BY CUM_RETURN DESC NULLS LAST) AS RANK_NO,
                    BOT_ID,
                    BOT_CODE,
                    BOT_NAME,
                    DESCRIPTION,
                    MODEL_TYPE,
                    DAILY_RETURN,
                    CUM_RETURN
                FROM (
                    SELECT
                        b.BOT_ID,
                        b.BOT_CODE,
                        b.BOT_NAME,
                        b.DESCRIPTION,
                        b.MODEL_TYPE,
                        p.DAILY_RETURN,
                        p.CUM_RETURN
                    FROM DEMO_RAW_DB.RAW.BOT b
                    JOIN DEMO_RAW_DB.RAW.BOT_PERF_DAILY p
                        ON p.BOT_ID = b.BOT_ID
                    WHERE b.IS_ACTIVE = 'Y'
                    QUALIFY ROW_NUMBER() OVER (
                        PARTITION BY b.BOT_CODE
                        ORDER BY p.PERF_DATE DESC, b.BOT_ID
                    ) = 1
                ) league
                ORDER BY RANK_NO
                """,
                (rs, i) -> new BotRank(
                        rs.getLong("BOT_ID"),
                        rs.getInt("RANK_NO"),
                        rs.getString("BOT_CODE"),
                        rs.getString("BOT_NAME"),
                        rs.getString("DESCRIPTION"),
                        rs.getString("MODEL_TYPE"),
                        toDouble(rs.getObject("DAILY_RETURN")),
                        toDouble(rs.getObject("CUM_RETURN"))
                )
        );
    }

    public BotRank findById(long botId) {
        return findLeague().stream()
                .filter(bot -> bot.getBotId() == botId)
                .findFirst()
                .orElse(null);
    }

    public List<BotTrade> findTrades(long botId) {
        return jdbcTemplate.query(
                """
                SELECT TRADE_ID, BOT_ID, SYMBOL, SELECT_REASON, BUY_PRICE, BUY_AT
                FROM DEMO_RAW_DB.RAW.BOT_TRADE
                WHERE BOT_ID = ?
                ORDER BY BUY_AT DESC
                """,
                (rs, i) -> {
                    Timestamp buyAt = rs.getTimestamp("BUY_AT");
                    return new BotTrade(
                            rs.getLong("TRADE_ID"),
                            rs.getLong("BOT_ID"),
                            rs.getString("SYMBOL"),
                            rs.getString("SELECT_REASON"),
                            toDouble(rs.getObject("BUY_PRICE")),
                            buyAt == null ? null : buyAt.toLocalDateTime()
                    );
                },
                botId
        );
    }

    public long insertBot(
            String code,
            String name,
            String description,
            String modelType,
            String strategyType
    ) {
        jdbcTemplate.update(
                """
                MERGE INTO DEMO_RAW_DB.RAW.BOT t
                USING (
                    SELECT
                        ? AS BOT_CODE,
                        ? AS BOT_NAME,
                        ? AS DESCRIPTION,
                        ? AS MODEL_TYPE,
                        ? AS STRATEGY_TYPE
                ) s
                ON t.BOT_CODE = s.BOT_CODE
                WHEN MATCHED THEN UPDATE SET
                    BOT_NAME = s.BOT_NAME,
                    DESCRIPTION = s.DESCRIPTION,
                    MODEL_TYPE = s.MODEL_TYPE,
                    STRATEGY_TYPE = s.STRATEGY_TYPE
                WHEN NOT MATCHED THEN INSERT
                    (BOT_CODE, BOT_NAME, DESCRIPTION, MODEL_TYPE, STRATEGY_TYPE)
                VALUES
                    (s.BOT_CODE, s.BOT_NAME, s.DESCRIPTION, s.MODEL_TYPE, s.STRATEGY_TYPE)
                """,
                code, name, description, modelType, strategyType
        );
        Long id = jdbcTemplate.queryForObject(
                "SELECT BOT_ID FROM DEMO_RAW_DB.RAW.BOT WHERE BOT_CODE = ?",
                Long.class,
                code
        );
        return id == null ? 0L : id;
    }

    public void upsertPerformance(long botId, LocalDate perfDate, Double dailyReturn, Double cumReturn) {
        Date date = Date.valueOf(perfDate);
        int updated = jdbcTemplate.update(
                """
                UPDATE DEMO_RAW_DB.RAW.BOT_PERF_DAILY
                SET DAILY_RETURN = ?, CUM_RETURN = ?
                WHERE BOT_ID = ? AND PERF_DATE = ?
                """,
                dailyReturn, cumReturn, botId, date
        );
        if (updated == 0) {
            jdbcTemplate.update(
                    """
                    INSERT INTO DEMO_RAW_DB.RAW.BOT_PERF_DAILY
                        (BOT_ID, PERF_DATE, DAILY_RETURN, CUM_RETURN)
                    VALUES (?, ?, ?, ?)
                    """,
                    botId, date, dailyReturn, cumReturn
            );
        }
    }

    public void insertTrade(
            long botId,
            String symbol,
            String selectReason,
            Double buyPrice,
            LocalDateTime buyAt
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO DEMO_RAW_DB.RAW.BOT_TRADE
                    (BOT_ID, SYMBOL, SELECT_REASON, BUY_PRICE, BUY_AT)
                VALUES (?, ?, ?, ?, ?)
                """,
                botId,
                symbol,
                selectReason,
                buyPrice,
                Timestamp.valueOf(buyAt)
        );
    }

    private static Double toDouble(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.doubleValue();
        }
        return Double.valueOf(value.toString());
    }
}
