package com.example.controller;

import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/daily-report-final")
public class DailyReportFinalController {

    @GetMapping
    public String dailyReportFinal(Model model) {
        PageAttributes.apply(model, "daily-report-final", "일일 리포트 최종");
        return "daily-report-final";
    }
}
