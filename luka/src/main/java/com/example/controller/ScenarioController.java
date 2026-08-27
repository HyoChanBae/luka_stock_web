package com.example.controller;

import com.example.model.ScenarioForm;
import com.example.service.InvestmentMockService;
import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/scenario")
public class ScenarioController {

    private final InvestmentMockService investmentMockService;

    public ScenarioController(InvestmentMockService investmentMockService) {
        this.investmentMockService = investmentMockService;
    }

    @GetMapping
    public String form(@ModelAttribute("scenarioForm") ScenarioForm scenarioForm, Model model) {
        PageAttributes.apply(model, "scenario", "내 투자 시나리오");
        return "scenario";
    }

    @PostMapping
    public String run(@ModelAttribute("scenarioForm") ScenarioForm scenarioForm, Model model) {
        PageAttributes.apply(model, "scenario", "내 투자 시나리오");
        model.addAttribute("scenarioResult", investmentMockService.simulate(scenarioForm));
        return "scenario";
    }
}
