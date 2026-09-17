<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<section class="grid">
    <c:set var="reportTitle" value="시장 리포트" scope="request"/>
    <c:set var="reportData" value="${marketReport}" scope="request"/>
    <c:set var="reportDomId" value="market-report" scope="request"/>
    <c:set var="reportEmptyMessage" value="아직 등록된 리포트가 없습니다." scope="request"/>
    <c:set var="reportWide" value="${false}" scope="request"/>
    <jsp:include page="/WEB-INF/views/fragments/report-doc.jsp"/>

    <c:set var="reportTitle" value="섹터 리포트" scope="request"/>
    <c:set var="reportData" value="${sectorReport}" scope="request"/>
    <c:set var="reportDomId" value="sector-report" scope="request"/>
    <c:set var="reportEmptyMessage" value="아직 등록된 섹터 리포트가 없습니다." scope="request"/>
    <c:set var="reportWide" value="${true}" scope="request"/>
    <jsp:include page="/WEB-INF/views/fragments/report-doc.jsp"/>

<%--<div class="card span12 chart-card">
        <div id="tv_chart_container"></div>
    </div> --%>
    <div class="card span12 chart-card">
      <div id="tv_chart_container">
        <iframe
            src="${chartEmbedUrl}"
            title="트레이딩뷰 차트"
            style="width:100%;height:100%;border:0;"
        ></iframe>
      </div>
    </div>
</section>

<%--
<script src="${pageContext.request.contextPath}/resources/js/charting_library/charting_library.standalone.js"></script>
<script>
    window.QuietAlphaChartConfig = {
        libraryPath: "${pageContext.request.contextPath}/resources/js/charting_library/"
    };
</script>
<script src="${pageContext.request.contextPath}/resources/js/page/chart.js"></script>
--%>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
