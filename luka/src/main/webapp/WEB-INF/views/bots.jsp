<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<section class="grid">
    <div class="card span12">
        <div class="hrow">
            <div>
                <h3 class="section-title">AI 투자 봇 리그</h3>
                <p class="small">전일 대비와 누적 수익률을 함께 보고, 상세정보에서 거래 근거까지 확인할 수 있어요.</p>
            </div>
            <a class="btn primary" href="<c:url value='/scenario'/>">내 봇 만들기</a>
        </div>
        <div class="mt-16">
            <div class="bot-rank bot-rank-head">
                <div>순위</div>
                <div>봇</div>
                <div>모델</div>
                <div>전일 대비</div>
                <div>누적 수익률</div>
                <div></div>
            </div>
            <c:choose>
                <c:when test="${empty botLeague}">
                    <p class="small mt-18">아직 등록된 봇이 없습니다. API로 봇과 성과를 넣으면 여기에 표시됩니다.</p>
                </c:when>
                <c:otherwise>
                    <c:forEach items="${botLeague}" var="bot">
                        <div class="bot-rank">
                            <div class="rank">${bot.rank}</div>
                            <div class="botname">
                                <b>${bot.name}</b>
                                <span>${bot.description}</span>
                            </div>
                            <div>${bot.modelType}</div>
                            <div class="${bot.dailyClass}">${bot.dailyDisplay}</div>
                            <div class="${bot.cumClass}">${bot.cumDisplay}</div>
                            <div>
                                <button type="button"
                                        class="link js-bot-detail"
                                        data-bot-name="${bot.name}"
                                        data-trades-url="<c:url value='/api/bots/${bot.botId}/trades'/>">상세정보</button>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</section>

<div id="tradeModal" class="modal">
    <div class="modalbox trade-box">
        <button type="button" class="close" aria-label="닫기">×</button>
        <h2>봇 거래내역</h2>
        <p id="tradeModalBot" class="small"></p>
        <div id="tradeModalBody" class="mt-16"></div>
    </div>
</div>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
