<%@page import="org.json.simple.*"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.time.Instant"%>
<%@ include file="../../dbConnect.jsp" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%

	request.setCharacterEncoding("UTF-8");
	
	JSONArray jsonArrayList = new JSONArray();   // JSONArray 생성

	String symbol = request.getParameter("symbol");
	String assetClsfCd = request.getParameter("assetClsfCd");
	String isRealTime = request.getParameter("isRealTime");
	//out.println("Received Symbol: " + symbol);
			
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
		
	try{		
        Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
		String inSymbol = "";

		String 	wSql = "";
			wSql += "   WITH MIN_TH_BAR_TIME AS (													";
			wSql += "       SELECT TO_CHAR(MIN(A.TH_BAR_TIME), 'YYYYMMDD') AS MIN_TH_BAR_TIME		";
			wSql += "       FROM MIAS.O_BLOOMBERG_OHLC A											";
			wSql += "       INNER JOIN MIAS.D_PMARKET B												";
			wSql += "       ON A.SECURITY = B.SYMBOL_NM												";
			wSql += "       WHERE UPPER(B.PMARKET_CD) = UPPER(?)									";
			wSql += "   )																			";
			wSql += "   SELECT                                      								";
			wSql += "       A.TH_BAR_TIME AS BASE_DT,           									";
			wSql += "       A.TH_BAR_OPEN AS CD_PRC_OPEN,           								";
			wSql += "       A.TH_BAR_HIGH AS CD_PRC_HIGH,           								";
			wSql += "       A.TH_BAR_LOW AS CD_PRC_LOW,             								";
			wSql += "       A.TH_BAR_CLOSE AS CD_PRC_CLOSE,         								";
			wSql += "       A.TH_BAR_VOLUME AS CD_PRC_VOLUME        								";
			wSql += "   FROM MIAS.O_BLOOMBERG_OHLC A                								";
			wSql += "   INNER JOIN MIAS.D_PMARKET B                 								";
			wSql += "   ON A.SECURITY = B.SYMBOL_NM                 								";
			wSql += "   WHERE 1=1                                   								";
			wSql += "       AND UPPER(B.PMARKET_CD) = UPPER(?)										";
			wSql += "   UNION ALL																	";
			wSql += "   SELECT 																		";
			wSql += "       TO_TIMESTAMP(TO_DATE(BASE_DT)) + 0.50 AS BASE_DT,						";
			wSql += "       CD_PRC AS CD_PRC_OPEN,          										";
			wSql += "       CD_PRC AS CD_PRC_HIGH,          										";
			wSql += "       CD_PRC AS CD_PRC_LOW,           										";
			wSql += "       CD_PRC AS CD_PRC_CLOSE, 												";
			wSql += "       0 AS CD_PRC_VOLUME														";
			wSql += "   FROM MIAS.F_DLY_PMARKET_SUM													";
			wSql += "   WHERE 1=1                                   								";
			wSql += "       AND UPPER(PMARKET_CD) = UPPER(?)										";
			wSql += "       AND BASE_DT < NVL((SELECT MIN_TH_BAR_TIME FROM MIN_TH_BAR_TIME), '99999999')		";
			wSql += "   ORDER BY BASE_DT															";
		
		pstmt = conn.prepareStatement(wSql);
		pstmt.setString(1, symbol);
		pstmt.setString(2, symbol);
		pstmt.setString(3, symbol);
			
		rs = pstmt.executeQuery();
        
        while(rs.next()) {
			Timestamp time = rs.getTimestamp("BASE_DT");
			long millsTime = time.getTime();
			double open = rs.getDouble("CD_PRC_OPEN");
			double high = rs.getDouble("CD_PRC_HIGH");
			double low = rs.getDouble("CD_PRC_LOW");
			double close = rs.getDouble("CD_PRC_CLOSE");
			double volume = rs.getDouble("CD_PRC_VOLUME");
			
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("timeStr", time.toString());
			jsonObject.put("time", millsTime);
			jsonObject.put("low", low);
			jsonObject.put("high", high);
			jsonObject.put("open", open);
			jsonObject.put("close", close);
			jsonObject.put("volume", volume);
						
			jsonArrayList.add(jsonObject);
        }
        
        pstmt.close();
        rs.close();
		
		String jsonResponse = "";
		if(jsonArrayList.size() == 0) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("status", "noData");
			
			jsonResponse = jsonObject.toJSONString();
		}else {
			jsonResponse = String.format("{\"status\":\"success\", \"data\":%s}", jsonArrayList.toJSONString());
		}
		
		conn.close();
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		response.getWriter().write(jsonResponse);
		
    }catch(Exception e){
        response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		String errorMessage = e.getMessage().replace("\n", "\\n").replace("\r", "\\r");
		response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
    }finally{
        try{
            if(rs != null) 	 rs.close();
            if(pstmt != null)   pstmt.close();
			if(conn != null) conn.close();
        }catch(Exception ex) {
            response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			String errorMessage = ex.getMessage().replace("\n", "\\n").replace("\r", "\\r");
			response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
        }
    }
	
%>
