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
	String chartId = request.getParameter("chartId");

	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
			
	try{		
        Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

		String 	wSql  = "	DELETE FROM MIAS.F_USER_ARRANGE_DTL 	";
				wSql +=	"	WHERE 1=1									";
				wSql += "	AND USER_ID = ?								";
				wSql += "	AND MENU_ID = ?								";
				wSql += "	AND ARRANGE_ID = ?							";
		
        pstmt = conn.prepareStatement(wSql);
		pstmt.setString(1, userId);
		pstmt.setString(2, menuId);
		pstmt.setString(3, chartId);
		
		int rows = pstmt.executeUpdate();
        response.setContentType("application/json");
		
        if (rows > 0) {
			response.getWriter().write("{\"status\":\"success\", \"id\":\"" + chartId + "\"}");
        } else {
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Layout not found\"}");
        }
		
    }catch(Exception e){
        response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		String errorMessage = e.getMessage().replace("\n", "\\n").replace("\r", "\\r");
		response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
    }finally{
    	if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { logger.error("error"); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { logger.error("error"); }
    }
	
%>
