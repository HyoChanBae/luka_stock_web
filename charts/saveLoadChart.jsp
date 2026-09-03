<%@ page import="java.sql.*, javax.servlet.*, javax.servlet.http.*, java.io.*" %>
<%@ page import="org.json.JSONObject, oracle.sql.CLOB" %>
<%@page import="java.util.*"%>
<%@ page import="org.apache.log4j.Logger" %>
<%@ include file="../../dbConnect.jsp" %>

<%@ page contentType="application/json; charset=UTF-8" %>
<%
	//Logger 설정
	Logger logger = Logger.getLogger(getClass());

	response.setCharacterEncoding("UTF-8"); // 응답의 문자 인코딩을 UTF-8로 설정
	
	StringBuilder jsonString = new StringBuilder();
    BufferedReader reader = request.getReader();
    String line;
	// 요청의 내용을 읽어 StringBuilder에 저장
	while ((line = reader.readLine()) != null) {
		jsonString.append(line);
	}

	// JSON 문자열을 JSONObject로 변환
	JSONObject json = new JSONObject(jsonString.toString());
		
	// 요청 파라미터 추출
	String chartId = json.getString("id");
	String userId = json.getString("user_id");
	String menuId = json.getString("menu_id");
	// 요청 타입 확인
	String chartType = json.getString("chart_type");
	
	Connection conn = null;
	ResultSet rs = null;
	PreparedStatement pstmt = null;
	
    try {
		Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
		
        if ("I".equalsIgnoreCase(chartType) || "U".equalsIgnoreCase(chartType)) {
			String chartName = json.getString("name");
			String chartResolution = json.getString("resolution");
			String chartSymbol = json.getString("symbol");
			long lastUpdateDt = json.getLong("timestamp");
			
			String chartData = json.getString("content");
			
			//새로 차트 insert하는 경우에 차트 ID 새로 생성
			if("I".equalsIgnoreCase(chartType)) {
				String wSql = "	SELECT  DISTINCT																			" +
							  "		T1.USER_ID||'_'||																		" +
							  "		(SELECT  MAX(TO_NUMBER(REPLACE(T0.ARRANGE_ID, T0.USER_ID||'_', '')))+1 AS ARRANGE_ID	" +
							  "		   FROM  MIAS.F_USER_ARRANGE_DTL T0 													" +
							  "		 WHERE  1 = 1																			" +
							  "		 AND  T0.USER_ID = ?																	" +
							  "		)   AS ARRANGE_ID																		" +
							  "	FROM  MIAS.F_USER_ARRANGE_DTL T1 															" +
							  "	WHERE  1 = 1																				" +
							  "	  AND  T1.USER_ID = ?																		" +
							  "	UNION ALL																					" +
							  "	SELECT  ?	||'_'||1 AS ARRANGE_ID															" +	
							  "	  FROM  DUAL																				" +
							  "	 WHERE  1 = 1																				";
								  
				pstmt = conn.prepareStatement(wSql);
				pstmt.setString(1, userId);
				pstmt.setString(2, userId);
				pstmt.setString(3, userId);
						
				rs = pstmt.executeQuery();
				if (rs.next()) {
					chartId = rs.getString("ARRANGE_ID");
				}
				
				JSONObject dataObj = new JSONObject(chartData);
				dataObj.put("id", chartId);
				chartData = dataObj.toString();
			}
			
            // 저장 처리
			String wSql = "	MERGE INTO MIAS.F_USER_ARRANGE_DTL T1																									" +
						  "	USING  (																																" +
						  "			SELECT  ?					AS ARRANGE_ID																						" +
						  "				  , ?  					AS ARRANGE_NM																						" +
						  "				  , ? 					AS ARRANGE_DESC																						" +
						  "				  , ?					AS USER_ID																							" +
						  "				  , ?					AS CHART_SYMBOL_NM																					" +
						  "				  , ?					AS CHART_CYC_NM																						" +
						  "				  , ?					AS MENU_ID																							" +
						  "				  , SYSDATE     		AS DATA_WORK_DTTM																					" +
						  "				  , SYSDATE     		AS DATA_CHANGE_DTTM																					" +
						  "			 FROM DUAL																														" +
						  "			 WHERE  1 = 1																													" +
						  "			) T2																															" +
						  "	   ON  (T1.ARRANGE_ID = T2.ARRANGE_ID)																									" +
						  "	  WHEN  MATCHED THEN																													" +
						  "	  UPDATE																																" +
						  "	   SET  T1.ARRANGE_NM       = T2.ARRANGE_NM 																							" +	
						  "		  , T1.ARRANGE_DESC     = T2.ARRANGE_DESC																							" +
						  "		  , T1.CHART_SYMBOL_NM  = T2.CHART_SYMBOL_NM																						" +
						  "		  , T1.CHART_CYC_NM     = T2.CHART_CYC_NM																							" +
						  "		  , T1.DATA_CHANGE_DTTM = T2.DATA_CHANGE_DTTM																						" +	
						  "	  WHEN  NOT MATCHED THEN																												" +
						  "	INSERT (T1.ARRANGE_ID, T1.ARRANGE_NM, T1.ARRANGE_DESC, T1.USER_ID, T1.CHART_SYMBOL_NM, T1.CHART_CYC_NM, T1.MENU_ID, T1.DATA_WORK_DTTM)	" +
						  "	VALUES (T2.ARRANGE_ID, T2.ARRANGE_NM, T2.ARRANGE_DESC, T2.USER_ID, T2.CHART_SYMBOL_NM, T2.CHART_CYC_NM, T2.MENU_ID, T2.DATA_WORK_DTTM)	";
		  	
            pstmt = conn.prepareStatement(wSql);
            
			// Oracle CLOB 객체 생성
            CLOB oracleClob = CLOB.createTemporary(conn, true, CLOB.DURATION_SESSION);
            oracleClob.setString(1, chartData);

            // PreparedStatement에 CLOB 데이터 설정
			pstmt.setString(1, chartId);
			pstmt.setString(2, chartName);
			pstmt.setClob(3, oracleClob);
            pstmt.setString(4, userId);
			pstmt.setString(5, chartSymbol);
			pstmt.setString(6, chartResolution);
			pstmt.setString(7, menuId);
			
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                response.setContentType("application/json");
				//response.getWriter().write("{\"status\":\"ok\", \"id\":\"" + chartId + "\"}");
				response.getWriter().write(chartData);
            } else {
                response.setContentType("application/json");
                response.getWriter().write("{\"status\":\"error\"}");
            }
        } else if ("S".equalsIgnoreCase(chartType)) {
            // 불러오기 처리
            String sql = "SELECT ARRANGE_DESC, ARRANGE_NM, DATA_CHANGE_DTTM FROM MIAS.F_USER_ARRANGE_DTL WHERE ARRANGE_ID = ? AND USER_ID = ? AND MENU_ID = ? ";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, chartId);
			pstmt.setString(2, userId);
			pstmt.setString(3, menuId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                String chartData = rs.getString("ARRANGE_DESC");
                response.setContentType("application/json");
                response.getWriter().write(chartData);
            } else {
                response.setContentType("application/json");
                response.getWriter().write("{\"status\":\"error\", \"message\":\"No chart found\"}");
            }
        } else {
            response.setContentType("application/json");
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Invalid request method\"}");
        }
    } catch (Exception e) { 
        response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		String errorMessage = e.getMessage().replace("\n", "\\n").replace("\r", "\\r");
		response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { logger.error("error");}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { logger.error("error"); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { logger.error("error"); }
    }
	
%>