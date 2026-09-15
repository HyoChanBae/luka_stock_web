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
                SELECT
                    t.TRADE_ID,
                    t.BOT_ID,
                    t.SYMBOL,
                    COALESCE(t.SYMBOL_NAME, q.SYMBOL_NAME) AS SYMBOL_NAME,
                    t.SELECT_REASON,
                    t.BUY_PRICE,
                    t.BUY_AT,
                    q.CURRENT_PRICE
                FROM DEMO_RAW_DB.RAW.BOT_TRADE_SENARIO t
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
                (rs, i) -> {
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
