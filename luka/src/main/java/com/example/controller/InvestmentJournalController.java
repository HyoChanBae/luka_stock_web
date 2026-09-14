package com.example.controller;

import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/investment-journal")
public class InvestmentJournalController {

    @GetMapping
    public String investmentJournal(Model model) {
        PageAttributes.apply(model, "investment-journal", "투자 기록");
        model.addAttribute("pageSubtitle", "생각부터 투자 내역까지, 셀에 바로 기록하세요.");
        return "investment-journal";
    }
}
