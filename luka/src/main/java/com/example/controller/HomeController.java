package com.example.controller;

import com.example.service.BotService;
import com.example.service.InvestmentMockService;
import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    private final InvestmentMockService investmentMockService;
    private final BotService botService;

    public HomeController(InvestmentMockService investmentMockService, BotService botService) {
        this.investmentMockService = investmentMockService;
        this.botService = botService;
    }

    @GetMapping("/")
    public String home(Model model) {
        PageAttributes.apply(model, "home", "내 투자");
        model.addAttribute("assetAmount", investmentMockService.assetAmount());
        model.addAttribute("monthlyReturn", investmentMockService.monthlyReturn());
        model.addAttribute("benchmark", investmentMockService.benchmark());
        model.addAttribute("metrics", investmentMockService.homeMetrics());
        model.addAttribute("riskEvents", investmentMockService.riskEvents());
        model.addAttribute("decisions", investmentMockService.decisions());
        model.addAttribute("homeBots", botService.league());
        model.addAttribute("positions", investmentMockService.positions());
        model.addAttribute("summaries", investmentMockService.todaySummaries());
        model.addAttribute(
                "riskModalText",
                "CPI 발표가 가까워 신규 고변동 포지션 한도를 낮추고 있습니다. 동시에 보유 단일종목의 SEC 신규발행·ATM 관련 문서를 우선 감시합니다."
        );
        return "home";
    }
}
