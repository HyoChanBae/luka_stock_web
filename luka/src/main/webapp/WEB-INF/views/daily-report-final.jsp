<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="fr-page">
    <header class="fr-head">
        <div>
            <h2 class="fr-title">일일 시장 리포트</h2>
            <p class="fr-date">2026.09.03 (목) 08:30 KST</p>
        </div>
        <button type="button" class="fr-pdf" disabled>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                <path d="M12 3v12m0 0 4-4m-4 4-4-4M5 21h14" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            PDF 다운로드
        </button>
    </header>

    <section class="fr-hero">
        <article class="fr-card fr-summary">
            <h3>오늘의 시장 한 줄 요약</h3>
            <p class="fr-quote">“장기금리 상승과 달러 강세로 위험자산에는 다소 부담”</p>
            <div class="fr-metrics">
                <div>
                    <span class="fr-label">RISK LEVEL</span>
                    <div class="fr-dots" aria-label="위험 수준 3/5">
                        <i class="on"></i><i class="on"></i><i class="on"></i><i></i><i></i>
                    </div>
                </div>
                <div>
                    <span class="fr-label">MARKET MOOD</span>
                    <strong class="fr-mood">CAUTIOUS</strong>
                </div>
            </div>
        </article>
        <article class="fr-card">
            <h3>지표 상태 핵심 요약</h3>
            <div class="fr-indicators">
                <div class="fr-ind">
                    <span>주식</span>
                    <em class="ico-neu" title="중립" aria-label="중립">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="10.5" width="14" height="3.2" rx="1.6"/></svg>
                    </em>
                    <b>중립~약세</b>
                    <small>위험자산 부담</small>
                </div>
                <div class="fr-ind">
                    <span>미국채</span>
                    <em class="ico-down" title="하락" aria-label="하락">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 18.5 4.2 7.8h15.6z"/></svg>
                    </em>
                    <b>금리 상승</b>
                    <small>10Y 강세</small>
                </div>
                <div class="fr-ind">
                    <span>달러</span>
                    <em class="ico-up" title="상승" aria-label="상승">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5.5 19.8 16.2H4.2z"/></svg>
                    </em>
                    <b>강세</b>
                    <small>DXY 상승</small>
                </div>
                <div class="fr-ind">
                    <span>유가</span>
                    <em class="ico-up" title="상승" aria-label="상승">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5.5 19.8 16.2H4.2z"/></svg>
                    </em>
                    <b>소폭 상승</b>
                    <small>WTI 반등</small>
                </div>
                <div class="fr-ind">
                    <span>Fed</span>
                    <em class="ico-neu" title="중립" aria-label="중립">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="10.5" width="14" height="3.2" rx="1.6"/></svg>
                    </em>
                    <b>신중</b>
                    <small>데이터 의존</small>
                </div>
            </div>
        </article>
    </section>

    <section class="fr-mid">
        <article class="fr-card">
            <h3>오늘의 핵심 3가지</h3>
            <ol class="fr-keys">
                <li>
                    <span>01</span>
                    <div>
                        <b>장기 국채 금리 상승</b>
                        <ul>
                            <li>10년물 금리가 오르며 성장주 밸류에이션 부담이 커졌습니다.</li>
                            <li>듀레이션이 긴 자산일수록 가격 조정이 두드러집니다.</li>
                        </ul>
                    </div>
                </li>
                <li>
                    <span>02</span>
                    <div>
                        <b>달러 강세 지속</b>
                        <ul>
                            <li>금리 차와 안전자산 수요로 DXY가 상대적 강세를 유지했습니다.</li>
                            <li>신흥국 통화와 원자재에는 역풍으로 작용합니다.</li>
                        </ul>
                    </div>
                </li>
                <li>
                    <span>03</span>
                    <div>
                        <b>Fed는 데이터 의존 기조</b>
                        <ul>
                            <li>추가 인하 기대는 남아 있으나 속도는 신중하다는 톤입니다.</li>
                            <li>고용·물가 지표 확인 전까지 관망 심리가 이어질 수 있습니다.</li>
                        </ul>
                    </div>
                </li>
            </ol>
        </article>
        <article class="fr-card">
            <div class="fr-card-head">
                <h3>Market Dashboard</h3>
                <span class="fr-more">더보기 ›</span>
            </div>
            <table class="fr-table">
                <thead>
                <tr>
                    <th>지수/자산</th>
                    <th>현재가</th>
                    <th>전일 대비</th>
                    <th>코멘트</th>
                </tr>
                </thead>
                <tbody>
                <tr>
                    <td>S&amp;P 500</td>
                    <td>5,642</td>
                    <td class="neg">▼ 0.42%</td>
                    <td>금리 부담</td>
                </tr>
                <tr>
                    <td>NASDAQ</td>
                    <td>17,812</td>
                    <td class="neg">▼ 0.71%</td>
                    <td>성장주 약세</td>
                </tr>
                <tr>
                    <td>US 10Y Yield</td>
                    <td>4.18%</td>
                    <td class="pos">▲ 6bp</td>
                    <td>장기금리 상승</td>
                </tr>
                <tr>
                    <td>DXY</td>
                    <td>104.2</td>
                    <td class="pos">▲ 0.28%</td>
                    <td>달러 강세</td>
                </tr>
                <tr>
                    <td>WTI</td>
                    <td>$78.4</td>
                    <td class="pos">▲ 0.9%</td>
                    <td>공급 경계</td>
                </tr>
                <tr>
                    <td>Gold</td>
                    <td>$2,412</td>
                    <td class="neg">▼ 0.3%</td>
                    <td>달러 역풍</td>
                </tr>
                </tbody>
            </table>
        </article>
    </section>

    <h3 class="fr-section-title">섹션별 시장 분석</h3>
    <section class="fr-sectors">
        <article class="fr-card fr-sector">
            <div class="fr-sector-top">
                <b><span class="fr-flag" aria-hidden="true">🇺🇸</span> Fed &amp; 통화정책</b>
                <em class="pill neu">NEUTRAL</em>
            </div>
            <dl class="fr-mini">
                <div><dt>Stance</dt><dd>데이터 의존</dd></div>
                <div><dt>Bias</dt><dd>신중</dd></div>
            </dl>
            <ul>
                <li>인사 발언은 물가 둔화를 인정하면서도 고용을 확인하겠다는 톤</li>
                <li>시장은 연내 인하 기대를 유지하나 속도 논쟁은 여전</li>
            </ul>
            <div class="fr-impact">
                <span>시장 영향</span>
                <i class="chip-n">성장주 Neutral</i>
                <i class="chip-p">금융주 Positive</i>
            </div>
        </article>
        <article class="fr-card fr-sector">
            <div class="fr-sector-top">
                <b><span class="fr-flag" aria-hidden="true">📈</span> 국채 시장</b>
                <em class="pill bear">BEARISH</em>
            </div>
            <dl class="fr-mini">
                <div><dt>10Y</dt><dd>4.18%</dd></div>
                <div><dt>2Y</dt><dd>3.96%</dd></div>
                <div><dt>Spread</dt><dd>+22bp</dd></div>
            </dl>
            <ul>
                <li>장기물 중심 금리 상승으로 듀레이션 부담</li>
                <li>안전자산 수요는 있으나 가격은 약세</li>
            </ul>
            <div class="fr-impact">
                <span>시장 영향</span>
                <i class="chip-d">성장주 Negative</i>
                <i class="chip-p">금융주 Positive</i>
            </div>
        </article>
        <article class="fr-card fr-sector">
            <div class="fr-sector-top">
                <b><span class="fr-flag" aria-hidden="true">💱</span> 환율 시장</b>
                <em class="pill bull">BULLISH $</em>
            </div>
            <dl class="fr-mini">
                <div><dt>DXY</dt><dd>104.2</dd></div>
                <div><dt>USD/KRW</dt><dd>1,348</dd></div>
                <div><dt>EUR/USD</dt><dd>1.09</dd></div>
            </dl>
            <ul>
                <li>달러가 주요 통화 대비 상대 강세</li>
                <li>원화는 금리 차와 위험회피 속에 약보합</li>
            </ul>
            <div class="fr-impact">
                <span>시장 영향</span>
                <i class="chip-n">수출주 Mixed</i>
                <i class="chip-d">원자재 Negative</i>
            </div>
        </article>
        <article class="fr-card fr-sector">
            <div class="fr-sector-top">
                <b><span class="fr-flag" aria-hidden="true">🛢️</span> 원자재 시장</b>
                <em class="pill neu">NEUTRAL</em>
            </div>
            <dl class="fr-mini">
                <div><dt>WTI</dt><dd>$78.4</dd></div>
                <div><dt>Gold</dt><dd>$2,412</dd></div>
                <div><dt>Copper</dt><dd>혼조</dd></div>
            </dl>
            <ul>
                <li>유가는 공급 이슈로 소폭 반등</li>
                <li>금은 달러 강세에 제한적 흐름</li>
            </ul>
            <div class="fr-impact">
                <span>시장 영향</span>
                <i class="chip-p">에너지 Positive</i>
                <i class="chip-n">금 Neutral</i>
            </div>
        </article>
    </section>

    <section class="fr-bottom">
        <article class="fr-card">
            <div class="fr-card-head">
                <h3>Asset Impact (종합 시장 영향)</h3>
                <span class="fr-more">더보기 ›</span>
            </div>
            <table class="fr-table">
                <thead>
                <tr>
                    <th>자산/섹터</th>
                    <th>View</th>
                    <th>근거</th>
                </tr>
                </thead>
                <tbody>
                <tr>
                    <td>성장주 / 나스닥</td>
                    <td><em class="view bear"><i>×</i> Bearish</em></td>
                    <td>장기금리 상승, 밸류에이션 부담</td>
                </tr>
                <tr>
                    <td>금융주</td>
                    <td><em class="view bull"><i>✓</i> Bullish</em></td>
                    <td>순이자마진 개선 기대</td>
                </tr>
                <tr>
                    <td>달러</td>
                    <td><em class="view bull"><i>✓</i> Bullish</em></td>
                    <td>금리 차, 안전자산 수요</td>
                </tr>
                <tr>
                    <td>금</td>
                    <td><em class="view neu"><i>–</i> Neutral</em></td>
                    <td>달러 강세와 헷지 수요가 상쇄</td>
                </tr>
                <tr>
                    <td>에너지</td>
                    <td><em class="view bull"><i>✓</i> Bullish</em></td>
                    <td>공급 리스크, 유가 반등</td>
                </tr>
                </tbody>
            </table>
        </article>
        <article class="fr-card">
            <div class="fr-card-head">
                <h3>오늘 체크할 주요 이벤트</h3>
                <span class="fr-more">더보기 ›</span>
            </div>
            <table class="fr-table">
                <thead>
                <tr>
                    <th>시간 (KST)</th>
                    <th>이벤트</th>
                    <th>중요도</th>
                </tr>
                </thead>
                <tbody>
                <tr>
                    <td>21:30</td>
                    <td><span class="fr-flag">🇺🇸</span> US Jobless Claims</td>
                    <td><em class="imp high">높음</em></td>
                </tr>
                <tr>
                    <td>22:00</td>
                    <td><span class="fr-flag">🇺🇸</span> 연준 인사 발언</td>
                    <td><em class="imp high">높음</em></td>
                </tr>
                <tr>
                    <td>23:00</td>
                    <td><span class="fr-flag">🇺🇸</span> 원유 재고</td>
                    <td><em class="imp mid">중간</em></td>
                </tr>
                <tr>
                    <td>익일 08:00</td>
                    <td><span class="fr-flag">🌏</span> 아시아 개장 수급</td>
                    <td><em class="imp mid">중간</em></td>
                </tr>
                </tbody>
            </table>
        </article>
    </section>

    <footer class="fr-foot">
        <p>참고: 본 리포트는 AI 분석 기반으로 작성된 더미 구성이며, 투자 권유가 아닙니다. 최종 판단과 책임은 투자자 본인에게 있습니다.</p>
        <p>Data Source: Bloomberg, Investing.com</p>
    </footer>
</div>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
