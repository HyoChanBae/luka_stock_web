package com.example.service;

import org.springframework.stereotype.Component;

@Component
public class DummyQuoteService {

    /**
     * 종목별로 항상 같은 더미 현재가를 돌려 줍니다. 실제 시세가 아닙니다.
     */
    public Double lastPrice(String symbol, Double buyPrice) {
        int seed = Math.abs((symbol == null ? "" : symbol).hashCode());
        double factor = 0.88 + (seed % 2501) / 10_000.0;
        if (buyPrice != null && buyPrice > 0) {
            return round(buyPrice * factor);
        }
        return round(10 + (seed % 50_000) / 10.0);
    }

    private static double round(double value) {
        return Math.round(value * 100.0) / 100.0;
    }
}
