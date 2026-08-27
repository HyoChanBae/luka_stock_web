package com.example.controller;

import com.example.service.InvestmentMockService;
import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/alerts")
public class AlertController {

    private final InvestmentMockService investmentMockService;

    public AlertController(InvestmentMockService investmentMockService) {
        this.investmentMockService = investmentMockService;
    }

    @GetMapping
    public String alerts(Model model) {
        PageAttributes.apply(model, "alerts", "알림 전략");
        model.addAttribute("alertStrategies", investmentMockService.alertStrategies());
        model.addAttribute("habitMetrics", investmentMockService.checkHabitMetrics());
        return "alerts";
    }
}
