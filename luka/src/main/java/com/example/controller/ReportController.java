package com.example.controller;

import com.example.service.InvestmentMockService;
import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/report")
public class ReportController {

    private final InvestmentMockService investmentMockService;

    public ReportController(InvestmentMockService investmentMockService) {
        this.investmentMockService = investmentMockService;
    }

    @GetMapping
    public String report(Model model) {
        PageAttributes.apply(model, "report", "일일 리포트");
        model.addAttribute("reportItems", investmentMockService.reportItems());
        model.addAttribute("reportSections", investmentMockService.reportSections());
        return "report";
    }
}
