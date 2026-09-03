package com.example.controller;

import com.example.service.MarketReportService;
import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/daily-report")
public class DailyReportController {

    private final MarketReportService marketReportService;

    public DailyReportController(MarketReportService marketReportService) {
        this.marketReportService = marketReportService;
    }

    @GetMapping
    public String dailyReport(Model model) {
        PageAttributes.apply(model, "daily-report", "일일 리포트");
        model.addAttribute("marketReport", marketReportService.latest());
        return "daily-report";
    }
}
