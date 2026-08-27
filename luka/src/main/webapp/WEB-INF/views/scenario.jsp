<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<section class="grid">
    <div class="card span6">
        <h3 class="section-title">내 투자 시나리오 만들기</h3>
        <p class="small">실계좌 없이 가상의 금액과 전략으로 먼저 테스트해보세요.</p>
        <form id="scenarioForm" method="post" action="<c:url value='/scenario'/>" class="formgrid mt-18">
            <div class="field">
                <label for="capital">초기 투자금</label>
                <input class="input" id="capital" name="capital" value="${scenarioForm.capital}"/>
            </div>
            <div class="field">
                <label>기준 통화</label>
                <select class="input" name="currency">
                    <option value="KRW" ${scenarioForm.currency eq 'KRW' ? 'selected' : ''}>KRW</option>
                    <option value="USD" ${scenarioForm.currency eq 'USD' ? 'selected' : ''}>USD</option>
                </select>
            </div>
            <div class="field">
                <label>봇 유형</label>
                <select class="input" id="botType" name="botType">
                    <option ${scenarioForm.botType eq '지수 안정형' ? 'selected' : ''}>지수 안정형</option>
                    <option ${scenarioForm.botType eq '파도타기' ? 'selected' : ''}>파도타기</option>
                    <option ${scenarioForm.botType eq '단일종목' ? 'selected' : ''}>단일종목</option>
                    <option ${scenarioForm.botType eq '가치투자' ? 'selected' : ''}>가치투자</option>
                </select>
            </div>
            <div class="field">
                <label>위험 성향</label>
                <select class="input" name="risk">
                    <option ${scenarioForm.risk eq '보수적' ? 'selected' : ''}>보수적</option>
                    <option ${scenarioForm.risk eq '중립' ? 'selected' : ''}>중립</option>
                    <option ${scenarioForm.risk eq '공격적' ? 'selected' : ''}>공격적</option>
                </select>
            </div>
            <div class="field">
                <label>목표 수익률</label>
                <input class="input" name="targetReturn" value="${scenarioForm.targetReturn}"/>
            </div>
            <div class="field">
                <label>최대 허용 하락률</label>
                <input class="input" name="maxDrawdown" value="${scenarioForm.maxDrawdown}"/>
            </div>
            <button type="submit" class="btn primary block">시나리오 실행</button>
        </form>
    </div>
    <div class="card span6">
        <h3 class="section-title">예상 시나리오</h3>
        <c:choose>
            <c:when test="${not empty scenarioResult}">
                <div class="mt-18">
                    <div class="eyebrow">12개월 가정 평가금액</div>
                    <div class="asset asset-lg">${scenarioResult.estimatedAmount}</div>
                    <div class="return">${scenarioResult.monthlyRateLabel}</div>
                    <div class="metrics">
                        <div class="metric">
                            <label>주식 / ETF</label>
                            <strong>${scenarioResult.stockWeight}</strong>
                        </div>
                        <div class="metric">
                            <label>현금 버퍼</label>
                            <strong>${scenarioResult.cashWeight}</strong>
                        </div>
                        <div class="metric">
                            <label>최대 허용 MDD</label>
                            <strong>${scenarioResult.maxMdd}</strong>
                        </div>
                    </div>
                    <p class="small mt-16">실제 수익을 예측하는 값이 아니라 UI 검증용 시뮬레이션입니다.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="small mt-18">왼쪽 설정을 바꾸고 실행하면 예상 결과가 표시됩니다.</div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
