<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<section class="grid">
    <div class="card hero span8">
        <div class="hrow">
            <div>
                <div class="eyebrow">가상 평가금액</div>
                <div class="asset">${assetAmount}</div>
                <div class="return">${monthlyReturn} <span class="small">· ${benchmark}</span></div>
            </div>
            <span class="chip blue">30일</span>
        </div>
        <div class="hero-chart">
            <svg viewBox="0 0 900 230" preserveAspectRatio="none">
                <defs>
                    <linearGradient id="area" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stop-color="#3182f6" stop-opacity=".18"/>
                        <stop offset="100%" stop-color="#3182f6" stop-opacity="0"/>
                    </linearGradient>
                </defs>
                <path d="M0,190 C70,178 100,190 150,160 S245,145 300,125 S385,138 440,112 S530,120 585,86 S690,101 755,62 S830,65 900,42 L900,230 L0,230 Z" fill="url(#area)"/>
                <path d="M0,190 C70,178 100,190 150,160 S245,145 300,125 S385,138 440,112 S530,120 585,86 S690,101 755,62 S830,65 900,42" fill="none" stroke="#3182f6" stroke-width="4" stroke-linecap="round"/>
                <path d="M0,196 C120,190 190,184 270,170 S420,162 510,150 S690,137 900,112" fill="none" stroke="#b8c0c9" stroke-width="2" stroke-dasharray="7 7"/>
            </svg>
        </div>
        <div class="metrics">
            <c:forEach items="${metrics}" var="metric">
                <div class="metric">
                    <label>${metric.label}</label>
                    <strong>${metric.value}</strong>
                </div>
            </c:forEach>
        </div>
    </div>

    <div class="card span4 status-card">
        <div>
            <div class="hrow">
                <h3 class="section-title">지금 투자 상태</h3>
                <span class="chip warn">주의</span>
            </div>
            <div class="risk">
                <div class="risk-icon">⚡</div>
                <div>
                    <strong>CPI 발표 전이에요</strong>
                    <p class="small">고위험 신규 매수를 줄이고 있어요.</p>
                </div>
            </div>
            <div class="divider"></div>
            <c:forEach items="${riskEvents}" var="event">
                <div class="eventline">
                    <span>${event.label}</span>
                    <span>${event.value}</span>
                </div>
            </c:forEach>
        </div>
        <button type="button" class="btn soft js-open-modal"
                data-title="현재 위험 신호"
                data-text="${riskModalText}">위험 신호 자세히 보기</button>
    </div>

    <div class="card span7">
        <div class="hrow">
            <h3 class="section-title">오늘 AI는 이렇게 판단했어요</h3>
            <a class="link" href="<c:url value='/report'/>">전체 ${fn:length(decisions)}건 보기 ›</a>
        </div>
        <div class="mt-18">
            <c:forEach items="${decisions}" var="decision">
                <div class="decision">
                    <div class="decision-head">
                        <div>
                            <h4>${decision.title}</h4>
                            <p>${decision.description}</p>
                        </div>
                        <span class="chip ${decision.actionClass}">${decision.actionLabel}</span>
                    </div>
                    <c:if test="${not empty decision.reasonLabel}">
                        <c:choose>
                            <c:when test="${not empty decision.reasonTitle}">
                                <div class="reason js-open-modal"
                                     data-title="${decision.reasonTitle}"
                                     data-text="${decision.reasonText}">${decision.reasonLabel}</div>
                            </c:when>
                            <c:otherwise>
                                <div class="reason">${decision.reasonLabel}</div>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                </div>
            </c:forEach>
        </div>
    </div>

    <div class="card span5">
        <div class="hrow">
            <h3 class="section-title">이번 달 가장 잘한 AI</h3>
            <a class="link" href="<c:url value='/bots'/>">전체 랭킹 ›</a>
        </div>
        <c:forEach items="${homeBots}" var="bot" varStatus="status">
            <c:if test="${status.first}">
                <div class="featured-bot">
                    <div class="eyebrow">🥇 ${bot.name} · ${bot.description}</div>
                    <div class="asset top-bot-return ${bot.dailyClass}">${bot.dailyDisplay}</div>
                    <div class="small">누적 ${bot.cumDisplay} · ${bot.modelType}</div>
                </div>
            </c:if>
            <c:if test="${!status.first && status.index lt 3}">
                <div class="bot-rank">
                    <div class="rank">${bot.rank}</div>
                    <div class="botname">
                        <b>${bot.name}</b>
                        <span>${bot.description}</span>
                    </div>
                    <div>${bot.modelType}</div>
                    <div class="${bot.dailyClass}">${bot.dailyDisplay}</div>
                    <div class="${bot.cumClass}">${bot.cumDisplay}</div>
                    <div></div>
                </div>
            </c:if>
        </c:forEach>
    </div>

    <div class="card span7">
        <div class="hrow">
            <h3 class="section-title">내 포트폴리오</h3>
            <a class="link" href="<c:url value='/scenario'/>">상세 보기 ›</a>
        </div>
        <c:forEach items="${positions}" var="position">
            <div class="position">
                <div class="ticker">
                    <div class="logo">${position.ticker}</div>
                    <div>
                        <b>${position.name}</b>
                        <span>${position.strategy}</span>
                    </div>
                </div>
                <div>${position.weight}</div>
                <div class="${position.returnClass}">${position.returnRate}</div>
                <div><span class="chip">${position.chip}</span></div>
            </div>
        </c:forEach>
    </div>

    <div class="card span5">
        <h3 class="section-title">오늘 꼭 볼 것만 요약했어요</h3>
        <div class="summary-list">
            <c:forEach items="${summaries}" var="item">
                <div class="summary-item">
                    <div class="k">${item.kind}</div>
                    <div class="v">${item.value}</div>
                    <div class="d">${item.detail}</div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
