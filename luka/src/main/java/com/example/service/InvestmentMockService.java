package com.example.service;

import com.example.model.AlertSetting;
import com.example.model.BotRank;
import com.example.model.BotType;
import com.example.model.Decision;
import com.example.model.LabeledValue;
import com.example.model.Position;
import com.example.model.ScenarioForm;
import com.example.model.ScenarioResult;
import com.example.model.SummaryItem;
import org.springframework.stereotype.Service;

import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;

@Service
public class InvestmentMockService {

    public String assetAmount() {
        return "₩10,842,500";
    }

    public String monthlyReturn() {
        return "이번 달 +3.21%";
    }

    public String benchmark() {
        return "벤치마크 +1.64%";
    }

    public List<LabeledValue> homeMetrics() {
        return List.of(
                new LabeledValue("누적 수익률", "+8.43%"),
                new LabeledValue("최대 낙폭 MDD", "-5.8%"),
                new LabeledValue("현금 비중", "28%")
        );
    }

    public List<LabeledValue> riskEvents() {
        return List.of(
                new LabeledValue("소비자심리지수", "이번 주"),
                new LabeledValue("기대 인플레이션", "관찰 중"),
                new LabeledValue("SEC 신규발행 / ATM", "보유종목 감시")
        );
    }

    public List<Decision> decisions() {
        return List.of(
                new Decision(
                        "SMR은 그대로 유지했어요",
                        "ATM 발행 가능성은 부담이지만 계약 모멘텀이 아직 더 중요하다고 판단했어요.",
                        "HOLD",
                        "green",
                        "판단 근거 4개 보기 ›",
                        "SMR 판단 근거",
                        "긍정: 원전 계약 모멘텀과 섹터 상대강도 유지. 부정: 신규 ATM 가능성과 높은 변동성. 종합 신뢰도 72%."
                ),
                new Decision(
                        "반도체 ETF를 3% 추가매수했어요",
                        "단기 변동성 구간 하단에 진입했고 위험예산 안에서 분할매수가 가능해졌어요.",
                        "BUY",
                        "blue",
                        "매수 조건 확인 ›",
                        "",
                        ""
                ),
                new Decision(
                        "고위험 신규매수는 잠시 멈췄어요",
                        "CPI 발표 전까지 전체 위험예산을 20% 낮게 유지해요.",
                        "LIMIT",
                        "",
                        "",
                        "",
                        ""
                )
        );
    }

    public List<BotRank> botLeague() {
        return List.of(
                new BotRank(1, "WaveRider", "파도타기", "GPT", "+12.4%", "-5.1%", "34회"),
                new BotRank(2, "MacroShield", "거시 안정형", "Claude", "+9.7%", "-2.4%", "11회"),
                new BotRank(3, "BookValue", "가치투자", "GPT", "+8.1%", "-4.0%", "9회"),
                new BotRank(4, "VolQuant", "변동성 퀀트", "Rule+LLM", "+6.8%", "-7.8%", "57회")
        );
    }

    public List<BotRank> homeBotPreview() {
        return botLeague().stream().filter(bot -> bot.getRank() > 1 && bot.getRank() <= 3).toList();
    }

    public List<Position> positions() {
        return List.of(
                new Position("NVDA", "NVIDIA", "LLM 모멘텀", "22%", "+11.8%", "pos", "모멘텀"),
                new Position("SMR", "NuScale Power", "단일종목 연구", "16%", "-4.2%", "neg", "Research"),
                new Position("QQQ", "Nasdaq 100 ETF", "지수 안정형", "34%", "+6.1%", "pos", "Index"),
                new Position("₩", "현금", "Risk buffer", "28%", "—", "", "Buffer")
        );
    }

    public List<SummaryItem> todaySummaries() {
        return List.of(
                new SummaryItem("시장", "위험선호 중립", "대형 기술주는 강하지만 금리 민감 성장주는 혼조예요."),
                new SummaryItem("매크로", "CPI 전 신규 위험 축소", "발표 전까지 신규 고변동 포지션 한도를 낮췄어요."),
                new SummaryItem("보유종목", "SMR 공시를 우선 감시", "신규 발행 관련 SEC 문서와 계약 뉴스를 함께 봐요.")
        );
    }

    public List<BotType> botTypes() {
        return List.of(
                new BotType(
                        "단타 봇",
                        "짧은 주기, 높은 회전율. 거래비용과 슬리피지를 함께 고려해요.",
                        "Short-term",
                        "단타 봇",
                        "짧은 보유기간 동안 거래대금·변동성·모멘텀을 함께 보고 진입과 청산을 반복해요."
                ),
                new BotType(
                        "파도타기 봇",
                        "급등 추격보다 중간 주기 하락·상승 파동을 활용해요.",
                        "Swing",
                        "파도타기 봇",
                        "중간 수준의 가격 파동을 이용해 분할매수·분할매도를 반복해요."
                ),
                new BotType(
                        "단일종목 봇",
                        "특정 종목의 뉴스와 공시를 깊게 보는 리서치형 전략이에요.",
                        "Research",
                        "단일종목 봇",
                        "뉴스, SEC 공시, 매크로 이벤트, 희석 가능성을 한 종목 중심으로 통합해요."
                ),
                new BotType("섹터 봇", "AI, 원전, 반도체 등 섹터의 상대강도와 수급을 비교해요.", "Sector", "", ""),
                new BotType("LLM 비교 봇", "동일 데이터로 여러 LLM의 판단과 성과 차이를 비교해요.", "Benchmark", "", ""),
                new BotType("가치투자 독서 봇", "책과 문서에서 추출한 투자 원칙을 재무데이터에 적용해요.", "RAG + Rules", "", "")
        );
    }

    public List<SummaryItem> reportItems() {
        return List.of(
                new SummaryItem("시장 흐름", "위험선호는 중립이에요", "대형 기술주는 상대적으로 강하지만 성장주의 변동성이 커지고 있어요."),
                new SummaryItem("연준 / 금리", "주요 지표 발표 전 경계 구간", "금리 기대가 다시 흔들릴 가능성이 있어 신규 위험노출을 줄였어요."),
                new SummaryItem("보유종목", "SMR 공시 이벤트를 우선 감시", "신규 발행 가능성과 계약 모멘텀을 함께 추적하고 있어요.")
        );
    }

    public List<AlertSetting> reportSections() {
        return List.of(
                new AlertSetting("시장 흐름", "", true),
                new AlertSetting("연준 / 금리", "", true),
                new AlertSetting("환율", "", true),
                new AlertSetting("SEC 공시", "", true),
                new AlertSetting("개별종목 뉴스", "", true)
        );
    }

    public List<AlertSetting> alertStrategies() {
        return List.of(
                new AlertSetting("가격 화면 최소화", "일중 시세 대신 하루 1회 요약", true),
                new AlertSetting("위험 알림만 받기", "손실·공시·매크로 급변 시에만", true),
                new AlertSetting("주간 정기 리포트", "매주 일요일 한 번 요약", true),
                new AlertSetting("이벤트 데이 알림", "CPI / FOMC / 실적발표", false)
        );
    }

    public List<LabeledValue> checkHabitMetrics() {
        return List.of(
                new LabeledValue("확인 횟수", "11회"),
                new LabeledValue("위험 알림", "3건"),
                new LabeledValue("불필요 확인", "4회")
        );
    }

    public ScenarioResult simulate(ScenarioForm form) {
        long capital = parseCapital(form.getCapital());
        double monthly = monthlyRate(form.getBotType());
        long estimated = Math.round(capital * Math.pow(1 + monthly / 100, 12));
        NumberFormat format = NumberFormat.getInstance(Locale.KOREA);
        return new ScenarioResult(
                "₩" + format.format(estimated),
                "월 " + monthly + "% 단순 가정",
                "70%",
                "30%",
                form.getMaxDrawdown()
        );
    }

    private long parseCapital(String raw) {
        if (raw == null || raw.isBlank()) {
            return 10_000_000L;
        }
        try {
            return Long.parseLong(raw.replaceAll("[^0-9]", ""));
        } catch (NumberFormatException ex) {
            return 10_000_000L;
        }
    }

    private double monthlyRate(String botType) {
        if (botType == null) {
            return 1.3;
        }
        return switch (botType) {
            case "지수 안정형" -> 1.1;
            case "파도타기" -> 1.8;
            case "단일종목" -> 2.2;
            default -> 1.3;
        };
    }
}
