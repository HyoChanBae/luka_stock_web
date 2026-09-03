<%@page import="org.json.simple.*"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@ page import="org.apache.log4j.Logger" %>
<%@ include file="../../dbConnect.jsp" %>

<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	//Logger 설정
	Logger logger = Logger.getLogger(getClass());

	request.setCharacterEncoding("UTF-8");
	
	String userId = request.getParameter("userId");
	String menuId = request.getParameter("menuId");
	
	Connection conn = null;
	ResultSet rs = null;
	PreparedStatement pstmt = null;
	
	try{		
        Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

		String 	wSql  = "	SELECT ARRANGE_ID, ARRANGE_NM, CASE WHEN DATA_CHANGE_DTTM IS NULL THEN DATA_WORK_DTTM ELSE DATA_CHANGE_DTTM END AS LAST_UPDATE_DT, CHART_SYMBOL_NM, CHART_CYC_NM FROM MIAS.F_USER_ARRANGE_DTL 	";
				wSql +=	"	WHERE 1=1									";
				wSql += "	AND USER_ID = ?								";
				wSql += "	AND MENU_ID = ?								";
		
        pstmt = conn.prepareStatement(wSql);
		pstmt.setString(1, userId);
		pstmt.setString(2, menuId);
		rs = pstmt.executeQuery();
        
		JSONArray chartsArray = new JSONArray();
		
		while(rs.next()) {			
			JSONObject chart = new JSONObject();
			chart.put("id", rs.getString("ARRANGE_ID"));
			chart.put("name", rs.getString("ARRANGE_NM"));
			//날짜 형식 변환
			Timestamp time = rs.getTimestamp("LAST_UPDATE_DT");
			chart.put("timestamp", time.getTime());
			chart.put("symbol", rs.getString("CHART_SYMBOL_NM"));
			chart.put("resolution", rs.getString("CHART_CYC_NM"));
			chartsArray.add(chart);
        }
        
		pstmt.close();
        conn.close();
		
		response.setContentType("application/json");
        response.getWriter().write(chartsArray.toString());
		
    }catch(Exception e){ 
        response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		String errorMessage = e.getMessage().replace("\n", "\\n").replace("\r", "\\r");
		response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
    }finally{
    	if (rs != null) try { rs.close(); } catch (SQLException e) { logger.error("error");}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { logger.error("error"); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { logger.error("error"); }
    }
	
%>
