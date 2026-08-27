<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
    </main>
</div>

<div id="modal" class="modal">
    <div class="modalbox">
        <button type="button" class="close" aria-label="닫기">×</button>
        <h2 id="modalTitle"></h2>
        <p id="modalText" class="small small-14"></p>
        <h3>AI 판단을 더 깊게 보면</h3>
        <p class="small">근거 데이터 · 최근 거래 · MDD · 신뢰도 · 사용 LLM · 프롬프트/룰 버전 · 데이터 소스까지 단계적으로 열람할 수 있어요.</p>
    </div>
</div>

<script src="<c:url value='/resources/js/ui/modal.js'/>"></script>
<script src="<c:url value='/resources/js/ui/switch.js'/>"></script>
<script src="<c:url value='/resources/js/page/scenario.js'/>"></script>
<script src="<c:url value='/resources/js/app.js'/>"></script>
</body>
</html>
