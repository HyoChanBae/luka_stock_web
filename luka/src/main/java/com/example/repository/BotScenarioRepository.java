package com.example.repository;

import com.example.model.BotRank;
import com.example.model.BotTrade;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;

@Repository
public class BotScenarioRepository {

    private final JdbcTemplate jdbcTemplate;

    public BotScenarioRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
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
                    FROM DEMO_RAW_DB.RAW.BOT_SENARIO b
                    JOIN DEMO_RAW_DB.RAW.BOT_PERF_DAILY_SENARIO p
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

    public List<BotTrade> findTrades(long botId) {
        return jdbcTemplate.query(
                """
                SELECT TRADE_ID, BOT_ID, SYMBOL, SYMBOL_NAME, SELECT_REASON, BUY_PRICE, BUY_AT
                FROM DEMO_RAW_DB.RAW.BOT_TRADE_SENARIO
                WHERE BOT_ID = ?
                ORDER BY BUY_AT DESC
                """,
                (rs, i) -> {
                    Timestamp buyAt = rs.getTimestamp("BUY_AT");
                    return new BotTrade(
                            rs.getLong("TRADE_ID"),
                            rs.getLong("BOT_ID"),
                            rs.getString("SYMBOL"),
                            rs.getString("SYMBOL_NAME"),
                            rs.getString("SELECT_REASON"),
                            toDouble(rs.getObject("BUY_PRICE")),
                            buyAt == null ? null : buyAt.toLocalDateTime()
                    );
                },
                botId
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
