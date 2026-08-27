<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>QuietAlpha — ${pageTitle}</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/base.css'/>"/>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>"/>
    <link rel="stylesheet" href="<c:url value='/resources/css/components.css'/>"/>
</head>
<body>
<div class="app">
    <aside>
        <div class="brand">Quiet<span>Alpha</span></div>
        <div class="nav-title">MY INVESTMENT</div>
        <nav>
            <a href="<c:url value='/'/>" class="${activeNav eq 'home' ? 'active' : ''}">
                <span class="ico">⌂</span>대시보드
            </a>
            <a href="<c:url value='/bots'/>" class="${activeNav eq 'bots' ? 'active' : ''}">
                <span class="ico">◈</span>봇 랭킹
            </a>
            <a href="<c:url value='/scenario'/>" class="${activeNav eq 'scenario' ? 'active' : ''}">
                <span class="ico">＋</span>내 투자 시나리오
            </a>
            <a href="<c:url value='/report'/>" class="${activeNav eq 'report' ? 'active' : ''}">
                <span class="ico">▤</span>일일 리포트
            </a>
            <a href="<c:url value='/alerts'/>" class="${activeNav eq 'alerts' ? 'active' : ''}">
                <span class="ico">◎</span>알림 전략
            </a>
        </nav>
        <div class="sidebox">
            <b>주식창을 덜 봐도 괜찮아요</b>
            <p>중요한 판단과 위험 신호만 QuietAlpha가 정리해드려요.</p>
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
