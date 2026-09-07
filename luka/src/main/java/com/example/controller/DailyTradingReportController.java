package com.example.controller;

import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/daily-trading-report")
public class DailyTradingReportController {

    @GetMapping
    public String dailyTradingReport(Model model) {
        PageAttributes.apply(model, "daily-trading-report", "일일 트레이딩 리포트");
        return "daily-trading-report";
    }
}
