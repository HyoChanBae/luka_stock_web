<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="ij">
    <div class="ij-status">
        <span class="ij-save" id="ij-save" role="status">자동 저장 준비</span>
    </div>

    <div class="ij-cards">
        <div class="ij-card">
            <div class="ij-label"><span id="ij-total-label">장기 투자 총액</span></div>
            <div class="ij-value"><span id="ij-total">0</span><span class="ij-unit">만원</span></div>
            <div class="ij-sub">선택한 탭의 투자 금액 합계</div>
        </div>
        <div class="ij-card">
            <div class="ij-label">투자 기록</div>
            <div class="ij-value"><span id="ij-count">0</span><span class="ij-unit">건</span></div>
            <div class="ij-sub">선택한 탭에 기록된 투자 내역</div>
        </div>
        <div class="ij-card">
            <div class="ij-label">최근 구매 날짜</div>
            <div class="ij-value" id="ij-latest">—</div>
            <div class="ij-sub">선택한 탭의 구매 날짜 기준</div>
        </div>
    </div>

    <section id="ij-sheetview">
        <div class="ij-sheet">
            <div class="ij-toolbar">
                <div class="ij-sheetheading">
                    <strong>투자 내역 <span class="ij-sheetnote">/ 편집 가능한 시트</span></strong>
                    <div class="ij-tabs" role="tablist" aria-label="투자 기간">
                        <button type="button" id="ij-tab-long" class="ij-tab" role="tab" aria-selected="true" aria-controls="ij-panel" data-term="long">
                            장기<span class="ij-tabcount" id="ij-count-long"></span>
                        </button>
                        <button type="button" id="ij-tab-medium" class="ij-tab" role="tab" aria-selected="false" aria-controls="ij-panel" data-term="medium" tabindex="-1">
                            중기<span class="ij-tabcount" id="ij-count-medium"></span>
                        </button>
                        <button type="button" id="ij-tab-short" class="ij-tab" role="tab" aria-selected="false" aria-controls="ij-panel" data-term="short" tabindex="-1">
                            단기<span class="ij-tabcount" id="ij-count-short"></span>
                        </button>
                    </div>
                </div>
                <div class="ij-buttons">
                    <button type="button" class="ij-btn" id="ij-undo" disabled>↶ 실행 취소</button>
                    <button type="button" class="ij-btn" id="ij-del" disabled>선택 삭제</button>
                    <button type="button" class="ij-btn" id="ij-export">현재 탭 CSV</button>
                    <button type="button" class="ij-btn primary" id="ij-add">＋ 행 추가</button>
                </div>
            </div>
            <div class="ij-formula">
                <span class="ij-address" id="ij-address">A1</span>
                <span class="ij-fx">fx</span>
                <input id="ij-formula" aria-label="선택한 셀 값" placeholder="셀을 선택해 내용을 편집하세요"/>
            </div>
            <div class="ij-gridwrap" id="ij-panel" role="tabpanel" aria-labelledby="ij-tab-long">
                <table aria-label="투자 기록 편집 표">
                    <colgroup>
                        <col style="width:28px"/>
                        <col style="width:28px"/>
                        <col style="width:88px"/>
                        <col style="width:84px"/>
                        <col style="width:58px"/>
                        <col style="width:86px"/>
                        <col style="width:58px"/>
                        <col style="width:86px"/>
                        <col style="width:120px"/>
                        <col style="width:92px"/>
                        <col style="width:92px"/>
                        <col style="width:86px"/>
                        <col style="width:68px"/>
                        <col style="width:48px"/>
                    </colgroup>
                    <thead>
                    <tr>
                        <th><input type="checkbox" id="ij-all" aria-label="전체 행 선택"/></th>
                        <th>#</th>
                        <th><small>A</small>구매일</th>
                        <th><small>B</small>종목</th>
                        <th><small>C</small>기간</th>
                        <th><small>D</small>매수단가</th>
                        <th><small>E</small>수량</th>
                        <th><small>F</small>현재가</th>
                        <th><small>G</small>메모</th>
                        <th>매수금액<br/><small>자동</small></th>
                        <th>평가금액<br/><small>자동</small></th>
                        <th>평가손익<br/><small>자동</small></th>
                        <th>수익률<br/><small>자동</small></th>
                        <th>레포트</th>
                    </tr>
                    </thead>
                    <tbody id="ij-body"></tbody>
                </table>
            </div>
            <div class="ij-sheetfooter">
                <span id="ij-rows"></span>
                <span>매수금액 합계 <strong id="ij-sum"></strong> 만원</span>
            </div>
        </div>
        <div class="ij-hint">
            <strong>현재가는 수동 입력이며 실시간 시세가 아닙니다.</strong>
            모든 가격은 원화 기준입니다. 수익률 = (현재가 − 매수 단가) ÷ 매수 단가 × 100 (수수료·세금·배당 제외).<br/>
            종목명·매수 단가·주식 수를 입력해 주세요. 단가·수량 미입력 시 기존 투자금액을 합계에 유지합니다.<br/>
            셀 클릭 후 입력 · Tab / Shift+Tab: 좌우 이동 · Enter / Shift+Enter: 아래 / 위 이동<br/>
            엑셀에서 복사한 여러 셀을 붙여넣을 수 있습니다. 날짜: YYYY-MM-DD · 단가·주식 수: 0 이상의 숫자. A~G열은 입력, 회색 컬럼은 자동 계산입니다.<br/>
            이 브라우저에 자동 저장됩니다. 다른 기기로 옮기거나 보관하려면 CSV를 내려받으세요. 최초 2개 행은 가상 거래 예시이며 실제 보유 내역이 아닙니다. 장기·중기·단기 탭별로 독립적으로 관리됩니다.
        </div>
    </section>

    <section class="ij-detail" id="ij-detailview">
        <button type="button" class="ij-btn" id="ij-back">← 투자 기록으로</button>
        <div class="ij-detailgrid">
            <div class="ij-card ij-wide">
                <h2 id="ij-detailtitle"></h2>
                <p id="ij-detailmeta"></p>
            </div>
            <div class="ij-card">
                <h2>섹터 시황 / 투자 근거</h2>
                <p>관찰한 변화와 투자 판단을 기록하세요.</p>
                <textarea id="ij-analysis" aria-label="섹터 시황 및 투자 근거" placeholder="예: 수요 변화, 수급 상황, 투자 가설"></textarea>
            </div>
            <div class="ij-card">
                <h2>관련 레포트 / 체크 포인트</h2>
                <p>참고 자료와 다음에 확인할 내용을 모아두세요.</p>
                <textarea id="ij-report" aria-label="관련 레포트 및 체크 포인트" placeholder="보고서 제목, URL, 확인할 날짜 등을 입력하세요."></textarea>
            </div>
        </div>
    </section>
    <div id="ij-message" role="status"></div>
</div>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
