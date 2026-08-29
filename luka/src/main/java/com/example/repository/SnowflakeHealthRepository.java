package com.example.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.LinkedHashMap;
import java.util.Map;

@Repository
public class SnowflakeHealthRepository {

    private final JdbcTemplate jdbcTemplate;

    public SnowflakeHealthRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Map<String, Object> ping() {
        String version = jdbcTemplate.queryForObject("SELECT CURRENT_VERSION()", String.class);
        String user = jdbcTemplate.queryForObject("SELECT CURRENT_USER()", String.class);
        String role = jdbcTemplate.queryForObject("SELECT CURRENT_ROLE()", String.class);
        String database = jdbcTemplate.queryForObject("SELECT CURRENT_DATABASE()", String.class);
        String schema = jdbcTemplate.queryForObject("SELECT CURRENT_SCHEMA()", String.class);
        String warehouse = jdbcTemplate.queryForObject("SELECT CURRENT_WAREHOUSE()", String.class);

        Map<String, Object> row = new LinkedHashMap<>();
        row.put("ok", true);
        row.put("check", "v2");
        row.put("version", version);
        row.put("user", user);
        row.put("role", role);
        row.put("database", database);
        row.put("schema", schema);
        row.put("warehouse", warehouse);
        return row;
    }
}
