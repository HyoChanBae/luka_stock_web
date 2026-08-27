<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<section class="grid">
    <div class="card span12">
        <div class="hrow">
            <div>
                <h3 class="section-title">AI 투자 봇 리그</h3>
                <p class="small">수익률만 보지 않고 MDD, 거래수, 전략 유형까지 같이 비교해요.</p>
            </div>
            <a class="btn primary" href="<c:url value='/scenario'/>">내 봇 만들기</a>
        </div>
        <div class="mt-16">
            <c:forEach items="${botLeague}" var="bot">
                <div class="bot-rank">
                    <div class="rank">${bot.rank}</div>
                    <div class="botname">
                        <b>${bot.name}</b>
                        <span>${bot.style}</span>
                    </div>
                    <div>${bot.llm}</div>
                    <div class="perf">${bot.returnRate}</div>
                    <div>${bot.mdd}</div>
                    <div>${bot.trades}</div>
                </div>
            </c:forEach>
        </div>
    </div>

    <div class="card span12">
        <h3 class="section-title">어떤 봇을 만들 수 있나요?</h3>
        <div class="botgrid mt-18">
            <c:forEach items="${botTypes}" var="bot">
                <div class="botcard${empty bot.modalTitle ? '' : ' js-open-modal'}"
                     data-title="${bot.modalTitle}"
                     data-text="${bot.modalText}">
                    <h4>${bot.title}</h4>
                    <p>${bot.description}</p>
                    <span class="chip">${bot.chip}</span>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
