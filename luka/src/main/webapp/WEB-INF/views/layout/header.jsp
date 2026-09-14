<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Luka — ${pageTitle}</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/base.css'/>"/>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>"/>
    <link rel="stylesheet" href="<c:url value='/resources/css/components.css'/>"/>
    <c:if test="${activeNav eq 'daily-report-final'}">
        <link rel="stylesheet" href="<c:url value='/resources/css/report-final.css'/>"/>
    </c:if>
    <c:if test="${activeNav eq 'investment-journal'}">
        <link rel="stylesheet" href="<c:url value='/resources/css/investment-journal.css'/>"/>
    </c:if>
    <script>
        (function () {
            try {
                if (localStorage.getItem("quietalpha-nav-collapsed") === "1") {
                    document.documentElement.classList.add("nav-collapsed");
                }
            } catch (e) {}
        })();
    </script>
</head>
<body class="${activeNav eq 'daily-report' ? 'page-daily-report' : ''} ${activeNav eq 'chart' or activeNav eq 'daily-trading-report' ? 'page-chart' : ''} ${activeNav eq 'daily-report-final' ? 'page-report-final' : ''} ${activeNav eq 'bots' ? 'page-bots' : ''} ${activeNav eq 'investment-journal' ? 'page-journal' : ''}">
<div class="app">
    <aside id="app-sidebar">
        <div class="aside-head">
            <div class="brand">
                <span class="brand-text brand-accent">Luka</span>
                <span class="brand-mark" aria-hidden="true">L</span>
            </div>
            <button type="button" class="sidebar-toggle" id="sidebarToggle"
                    aria-controls="app-sidebar" aria-expanded="true" aria-label="사이드바 접기" title="사이드바 접기">
                <span class="sidebar-toggle-icon" aria-hidden="true"></span>
            </button>
        </div>
        <div class="nav-title">MY INVESTMENT</div>
        <nav>
            <a href="<c:url value='/'/>" class="${activeNav eq 'bots' ? 'active' : ''}" title="봇 랭킹">
                <span class="ico">◈</span><span class="nav-label">봇 랭킹</span>
            </a>
            <a href="<c:url value='/dashboard'/>" class="${activeNav eq 'home' ? 'active' : ''}" title="대시보드">
                <span class="ico">⌂</span><span class="nav-label">대시보드</span>
            </a>
            <a href="<c:url value='/scenario'/>" class="${activeNav eq 'scenario' ? 'active' : ''}" title="내 투자 시나리오">
                <span class="ico">＋</span><span class="nav-label">내 투자 시나리오</span>
            </a>
            <a href="<c:url value='/daily-report'/>" class="${activeNav eq 'daily-report' ? 'active' : ''}" title="일일 리포트">
                <span class="ico">▤</span><span class="nav-label">일일 리포트</span>
            </a>
            <a href="<c:url value='/daily-trading-report'/>" class="${activeNav eq 'daily-trading-report' ? 'active' : ''}" title="일일 트레이딩 리포트">
                <span class="ico">◈</span><span class="nav-label">일일 트레이딩 리포트</span>
            </a>
            <a href="<c:url value='/investment-journal'/>" class="${activeNav eq 'investment-journal' ? 'active' : ''}" title="투자 기록">
                <span class="ico">▦</span><span class="nav-label">투자 기록</span>
            </a>
            <a href="<c:url value='/daily-report-final'/>" class="${activeNav eq 'daily-report-final' ? 'active' : ''}" title="일일 리포트 최종">
                <span class="ico">▤</span><span class="nav-label">일일 리포트 최종</span>
            </a>
            <a href="<c:url value='/chart'/>" class="${activeNav eq 'chart' ? 'active' : ''}" title="차트">
                <span class="ico">◈</span><span class="nav-label">차트</span>
            </a>
            <a href="<c:url value='/report'/>" class="${activeNav eq 'report' ? 'active' : ''}" title="리포트 알림">
                <span class="ico">▤</span><span class="nav-label">리포트 알림</span>
            </a>
            <a href="<c:url value='/alerts'/>" class="${activeNav eq 'alerts' ? 'active' : ''}" title="알림 전략">
                <span class="ico">◎</span><span class="nav-label">알림 전략</span>
            </a>
        </nav>
        <div class="sidebox">
            <b>주식창을 덜 봐도 괜찮아요</b>
            <p>중요한 판단과 위험 신호만 Luka가 정리해드려요.</p>
        </div>
    </aside>
    <main>
        <div class="top">
            <div class="title">
                <h1>${pageTitle}</h1>
                <p>${pageSubtitle}</p>
            </div>
            <div class="mode"><span class="dot"></span>PAPER TRADING</div>
        </div>
