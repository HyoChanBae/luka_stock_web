<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<section class="grid">
    <div class="card span12 chart-card">
        <div id="tv_chart_container"></div>
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
