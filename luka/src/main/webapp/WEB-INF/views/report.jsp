<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<section class="grid">
    <div class="card span8">
        <h3 class="section-title">오늘의 투자 리포트</h3>
        <div class="summary-list">
            <c:forEach items="${reportItems}" var="item">
                <div class="summary-item">
                    <div class="k">${item.kind}</div>
                    <div class="v">${item.value}</div>
                    <div class="d">${item.detail}</div>
                </div>
            </c:forEach>
        </div>
    </div>
    <div class="card span4">
        <h3 class="section-title">리포트 구성</h3>
        <c:forEach items="${reportSections}" var="section">
            <div class="switchrow">
                <span>${section.title}</span>
                <div class="switch${section.enabled ? ' on' : ''}"><i></i></div>
            </div>
        </c:forEach>
    </div>
</section>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
