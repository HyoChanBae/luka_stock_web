<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<section class="grid">
    <div class="card span6">
        <h3 class="section-title">안 보는 전략</h3>
        <p class="small">가격은 덜 보고 정말 중요한 변화가 있을 때만 알려드려요.</p>
        <c:forEach items="${alertStrategies}" var="item">
            <div class="switchrow">
                <div>
                    <b>${item.title}</b>
                    <div class="small">${item.description}</div>
                </div>
                <div class="switch${item.enabled ? ' on' : ''}"><i></i></div>
            </div>
        </c:forEach>
    </div>
    <div class="card span6">
        <h3 class="section-title">이번 주 확인 습관</h3>
        <div class="asset asset-xl mt-25">-61%</div>
        <p class="small">지난 7일 동안 앱 확인 빈도가 줄었어요.</p>
        <div class="metrics">
            <c:forEach items="${habitMetrics}" var="metric">
                <div class="metric">
                    <label>${metric.label}</label>
                    <strong>${metric.value}</strong>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
