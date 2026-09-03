package com.example.service;

import com.example.model.MarketReport;
import com.example.repository.MarketReportRepository;
import org.springframework.stereotype.Service;

@Service
public class MarketReportService {

    private final MarketReportRepository marketReportRepository;

    public MarketReportService(MarketReportRepository marketReportRepository) {
        this.marketReportRepository = marketReportRepository;
    }

    public MarketReport latest() {
        try {
            return marketReportRepository.findLatest();
        } catch (Exception ex) {
            return null;
        }
    }
}
