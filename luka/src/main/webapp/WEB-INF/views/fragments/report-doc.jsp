<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="card span12 report-doc${reportWide ? ' report-wide' : ''}" id="${reportDomId}">
    <h3 class="report-card-title"><c:out value="${reportTitle}"/></h3>
    <c:if test="${not empty reportData and not empty reportData.createdAtDisplay}">
        <p class="report-date">${reportData.createdAtDisplay}</p>
    </c:if>
    <c:choose>
        <c:when test="${empty reportData}">
            <p class="small mt-16"><c:out value="${empty reportEmptyMessage ? '아직 등록된 리포트가 없습니다.' : reportEmptyMessage}"/></p>
        </c:when>
        <c:when test="${empty reportData.sections}">
            <div class="report-body mt-16"><c:out value="${reportData.report}"/></div>
        </c:when>
        <c:otherwise>
            <div class="report-sections">
                <c:forEach items="${reportData.sections}" var="section">
                    <article class="report-section${section.subsection ? ' report-sub' : ''}">
                        <h4><c:out value="${section.title}"/></h4>
                        <c:forEach items="${section.blocks}" var="block">
                            <c:if test="${not empty block.heading}">
                                <p class="report-block-title"><c:out value="${block.heading}"/></p>
                            </c:if>
                            <c:if test="${not empty block.table}">
                                <div class="report-table-wrap">
                                    <table class="report-table">
                                        <thead>
                                        <tr>
                                            <c:forEach items="${block.table.headers}" var="column">
                                                <th><c:out value="${column}"/></th>
                                            </c:forEach>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach items="${block.table.rows}" var="row">
                                            <tr>
                                                <c:forEach items="${row}" var="cell">
                                                    <td class="${cell.tone}"><c:out value="${cell.text}"/></td>
                                                </c:forEach>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:if>
                            <c:forEach items="${block.items}" var="item">
                                <p class="report-item"><c:out value="${item}"/></p>
                            </c:forEach>
                        </c:forEach>
                    </article>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>
