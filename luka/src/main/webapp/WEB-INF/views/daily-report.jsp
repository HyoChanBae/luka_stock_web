<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<section class="grid">
    <div class="card span12 report-doc">
        <h3 class="report-card-title">시장 리포트</h3>
        <c:if test="${not empty marketReport and not empty marketReport.createdAtDisplay}">
            <p class="report-date">${marketReport.createdAtDisplay}</p>
        </c:if>
        <c:choose>
            <c:when test="${empty marketReport}">
                <p class="small mt-16">아직 등록된 리포트가 없습니다.</p>
            </c:when>
            <c:when test="${empty marketReport.sections}">
                <div class="report-body mt-16"><c:out value="${marketReport.report}"/></div>
            </c:when>
            <c:otherwise>
                <div class="report-sections">
                    <c:forEach items="${marketReport.sections}" var="section">
                        <c:if test="${not empty section.items}">
                            <article class="report-section">
                                <h4><c:out value="${section.title}"/></h4>
                                <c:forEach items="${section.items}" var="item">
                                    <p class="report-item"><c:out value="${item}"/></p>
                                </c:forEach>
                            </article>
                        </c:if>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
<%--<div class="card span12 chart-card">
        <div id="tv_chart_container"></div>
    </div> --%>
    <div class="card span12 chart-card">
      <div id="tv_chart_container">
        <iframe
            src="http://localhost:4751/chart"
            title="트레이딩뷰 차트"
            style="width:100%;height:100%;border:0;"
        ></iframe>
      </div>
    </div>
</section>

<script src="${pageContext.request.contextPath}/resources/js/charting_library/charting_library.standalone.js"></script>
<script>
    window.QuietAlphaChartConfig = {
        libraryPath: "${pageContext.request.contextPath}/resources/js/charting_library/"
    };
</script>
<script src="${pageContext.request.contextPath}/resources/js/page/chart.js"></script>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
