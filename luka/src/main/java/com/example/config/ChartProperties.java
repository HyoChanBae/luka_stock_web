package com.example.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class ChartProperties {

    private final String embedUrl;

    public ChartProperties(@Value("${chart.embed-url}") String embedUrl) {
        this.embedUrl = embedUrl;
    }

    public String getEmbedUrl() {
        return embedUrl;
    }
}
