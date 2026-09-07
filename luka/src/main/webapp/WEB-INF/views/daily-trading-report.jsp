<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<section class="grid">
    <div class="card span12 chart-card">
        <div id="tv_chart_container">
            <iframe
                src="http://localhost:4751/chart-all"
                title="트레이딩뷰 차트"
                style="width:100%;height:100%;border:0;"
            ></iframe>
        </div>
    </div>
</section>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
