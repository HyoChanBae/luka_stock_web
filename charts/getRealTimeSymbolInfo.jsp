<%@page import="org.json.simple.*"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="java.util.regex.Pattern"%>

<%@ include file="../../dbConnect.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    String symbol = request.getParameter("symbol");
	String isRealTime = request.getParameter("isRealTime");
	
	// 심볼 빈값 체크
    if (symbol == null || symbol.trim().isEmpty()) {
        response.setContentType("application/json");
        response.getWriter().write("{\"status\":\"error\", \"message\":\"Symbol is required.\"}");
        return;
    }
	
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet existsRs = null;
    ResultSet rs = null;

    try {
        Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

		String wSql = " SELECT CASE WHEN EXISTS(					" + 
					  "		SELECT * FROM MIAS.D_PMARKET WHERE 1=1	" + 
					  "			AND USE_YN= 'Y'						" +
					  "			AND BPIPE_YN= 'Y'					" +
					  "			AND UPPER(PMARKET_CD) = UPPER(?)) 	" + 
					  "	THEN 'Y' ELSE 'N' END AS IS_SYMBOL FROM DUAL" ;
		
        pstmt = conn.prepareStatement(wSql);
		pstmt.setString(1, symbol);
        existsRs = pstmt.executeQuery();
		
        if(existsRs.next()) {
            String symbolFlag = existsRs.getString("IS_SYMBOL");
            
            if (symbolFlag.equals("Y")) {
                String wSql2 = 	" SELECT 								" + 
								"	PMARKET_CD AS SYMBOL_CD, 			" + 
								" 	PMARKET_NM AS SYMBOL_DESC, 			" +
								"	ASSET_NM AS SYMBOL_TYPE, 			" + 
								"	PMARKET_SRC_CD AS SYMBOL_EXCHANGE 	" +
								" FROM MIAS.D_PMARKET 					" + 
								" WHERE 1=1 							" +
								"	AND BPIPE_YN= 'Y'					" +
								"	AND UPPER(PMARKET_CD) = UPPER(?)	";
                
                pstmt.close(); // 이전 pstmt 닫기
                pstmt = conn.prepareStatement(wSql2);
				pstmt.setString(1, symbol);
                rs = pstmt.executeQuery();
				//out.println(symbol);
				
				JSONObject symbolInfo = new JSONObject();
				
                symbolInfo.put("symbol", symbol);
                symbolInfo.put("name", symbol);
                symbolInfo.put("ticker", symbol);
                symbolInfo.put("session", "24x7");
                symbolInfo.put("timezone", "Asia/Seoul");
                symbolInfo.put("minmov", 1);
                symbolInfo.put("pricescale", 100);
                symbolInfo.put("has_intraday", true);
				
                while (rs.next()) {
                    symbolInfo.put("description", rs.getString("SYMBOL_DESC"));
                    symbolInfo.put("exchange", rs.getString("SYMBOL_EXCHANGE"));
                    symbolInfo.put("type", rs.getString("SYMBOL_TYPE"));
                }
			
				response.setContentType("application/json");
				response.setCharacterEncoding("UTF-8");
				String jsonResponse = String.format("{\"status\":\"success\", \"data\":%s}", symbolInfo.toJSONString());
				response.getWriter().write(jsonResponse);
			
			}else {
                response.getWriter().write("{\"status\":\"error\", \"message\":\"Symbol not found.\"}");
            }
        }
				
    } catch (Exception e) {
        response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		//String errorMessage = e.getMessage().replace("\n", "\\n").replace("\r", "\\r");
		String errorMessage = "Occur Exception";
		response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
    } finally {
        try {
            if (rs != null) rs.close();
            if (existsRs != null) existsRs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException ex) {
            response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			//String errorMessage = ex.getMessage().replace("\n", "\\n").replace("\r", "\\r");
			String errorMessage = "Occur SQLException";
			response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
        }
    }
%>