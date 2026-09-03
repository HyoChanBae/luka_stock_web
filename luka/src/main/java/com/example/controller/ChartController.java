package com.example.controller;

import com.example.web.PageAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/chart")
public class ChartController {

    @GetMapping
    public String chart(Model model) {
        PageAttributes.apply(model, "chart", "차트");
        return "chart";
    }
}
