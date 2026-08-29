package com.example.controller;

import com.example.repository.SnowflakeHealthRepository;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
public class DbHealthController {

    private final SnowflakeHealthRepository snowflakeHealthRepository;

    public DbHealthController(SnowflakeHealthRepository snowflakeHealthRepository) {
        this.snowflakeHealthRepository = snowflakeHealthRepository;
    }

    @GetMapping(value = "/db-health", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> health() {
        try {
            return snowflakeHealthRepository.ping();
        } catch (Exception ex) {
            Throwable root = rootCause(ex);
            Map<String, Object> error = new LinkedHashMap<>();
            error.put("ok", false);
            error.put("check", "v2");
            error.put("error", root.getMessage());
            error.put("type", root.getClass().getSimpleName());
            return error;
        }
    }

    private Throwable rootCause(Throwable ex) {
        Throwable current = ex;
        while (current.getCause() != null && current.getCause() != current) {
            current = current.getCause();
        }
        return current;
    }
}
