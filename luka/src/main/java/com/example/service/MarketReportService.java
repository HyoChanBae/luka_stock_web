package com.example.service;

import com.example.model.MarketReport;
import com.example.repository.MarketReportRepository;
import org.springframework.stereotype.Service;

import java.util.function.Supplier;

@Service
public class MarketReportService {

    private final MarketReportRepository marketReportRepository;

    public MarketReportService(MarketReportRepository marketReportRepository) {
        this.marketReportRepository = marketReportRepository;
    }

    public MarketReport latest() {
        return fetch(marketReportRepository::findLatest);
    }

    public MarketReport latestSector() {
        return fetch(marketReportRepository::findLatestSector);
    }

    private MarketReport fetch(Supplier<MarketReport> loader) {
        try {
            return loader.get();
        } catch (Exception ex) {
            return null;
        }
    }
}
