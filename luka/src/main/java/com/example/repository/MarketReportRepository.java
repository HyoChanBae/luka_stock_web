package com.example.repository;

import com.example.model.MarketReport;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;

@Repository
public class MarketReportRepository {

    private final JdbcTemplate jdbcTemplate;

    public MarketReportRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public MarketReport findLatest() {
        List<MarketReport> rows = jdbcTemplate.query(
                """
                SELECT REPORT, CREATED_AT
                FROM DEMO_RAW_DB.RAW.MARKET_REPORTS
                ORDER BY CREATED_AT DESC
                LIMIT 1
                """,
                (rs, i) -> {
                    Timestamp createdAt = rs.getTimestamp("CREATED_AT");
                    return new MarketReport(
                            rs.getString("REPORT"),
                            createdAt == null ? null : createdAt.toLocalDateTime()
                    );
                }
        );
        return rows.isEmpty() ? null : rows.get(0);
    }
}
