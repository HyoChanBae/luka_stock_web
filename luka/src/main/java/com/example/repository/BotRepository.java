package com.example.repository;

import com.example.model.BotRank;
import com.example.model.BotTrade;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
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
                    SYMBOL_NAME     VARCHAR(200),
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
                SELECT
                    t.TRADE_ID,
                    t.BOT_ID,
                    t.SYMBOL,
                    COALESCE(t.SYMBOL_NAME, q.SYMBOL_NAME) AS SYMBOL_NAME,
                    t.SELECT_REASON,
                    t.BUY_PRICE,
                    t.BUY_AT,
                    q.CURRENT_PRICE
                FROM DEMO_RAW_DB.RAW.BOT_TRADE t
                LEFT JOIN (
                    SELECT SYMBOL, SYMBOL_NAME, CURRENT_PRICE
                    FROM DEMO_RAW_DB.RAW.BOT_TRADE_CURRENT_INFO
                    QUALIFY ROW_NUMBER() OVER (
                        PARTITION BY TRIM(TO_VARCHAR(SYMBOL))
                        ORDER BY UPDATE_DT DESC NULLS LAST, CREATE_DT DESC NULLS LAST
                    ) = 1
                ) q
                    ON (
                        TRIM(TO_VARCHAR(q.SYMBOL)) = TRIM(TO_VARCHAR(t.SYMBOL))
                        OR SPLIT_PART(TRIM(TO_VARCHAR(q.SYMBOL)), '.', 1) = TRIM(TO_VARCHAR(t.SYMBOL))
                        OR TRIM(TO_VARCHAR(q.SYMBOL)) = SPLIT_PART(TRIM(TO_VARCHAR(t.SYMBOL)), '.', 1)
                    )
                WHERE t.BOT_ID = ?
                QUALIFY ROW_NUMBER() OVER (
                    PARTITION BY t.TRADE_ID
                    ORDER BY q.CURRENT_PRICE DESC NULLS LAST
                ) = 1
                ORDER BY t.BUY_AT DESC
                """,
                (rs, i) -> mapTrade(rs),
                botId
        );
    }

    public LocalDateTime findLatestCurrentPriceUpdateDt() {
        List<LocalDateTime> rows = jdbcTemplate.query(
                """
                SELECT UPDATE_DT
                FROM DEMO_RAW_DB.RAW.BOT_TRADE_CURRENT_INFO
                ORDER BY UPDATE_DT DESC
                LIMIT 1
                """,
                (rs, i) -> {
                    Timestamp updatedAt = rs.getTimestamp("UPDATE_DT");
                    return updatedAt == null ? null : updatedAt.toLocalDateTime();
                }
        );
        return rows.isEmpty() ? null : rows.get(0);
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
            String symbolName,
            String selectReason,
            Double buyPrice,
            LocalDateTime buyAt
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO DEMO_RAW_DB.RAW.BOT_TRADE
                    (BOT_ID, SYMBOL, SYMBOL_NAME, SELECT_REASON, BUY_PRICE, BUY_AT)
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                botId,
                symbol,
                symbolName,
                selectReason,
                buyPrice,
                Timestamp.valueOf(buyAt)
        );
    }

    private static BotTrade mapTrade(ResultSet rs) throws SQLException {
        Timestamp buyAt = rs.getTimestamp("BUY_AT");
        return new BotTrade(
                rs.getLong("TRADE_ID"),
                rs.getLong("BOT_ID"),
                rs.getString("SYMBOL"),
                rs.getString("SYMBOL_NAME"),
                rs.getString("SELECT_REASON"),
                toDouble(rs.getObject("BUY_PRICE")),
                buyAt == null ? null : buyAt.toLocalDateTime(),
                toDouble(rs.getObject("CURRENT_PRICE"))
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
