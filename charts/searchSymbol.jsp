<%@page import="org.json.simple.*"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@ include file="../../dbConnect.jsp" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%

	request.setCharacterEncoding("UTF-8");
	
	JSONArray jsonArrayList = new JSONArray();   // JSONArray 생성

	String paramSymbolNm = request.getParameter("symbolNm");
	String paramSymbolTy = request.getParameter("symbolType");
	String aclsfCd = request.getParameter("assetClsfCd");
	
	// 작은따옴표와 공백 제거 후 배열로 변환
	String[] aclsfCdArray = aclsfCd.replace("'", "").split(",\\s*");

	// Placeholder 생성
	String aclsfCdSql = String.join(", ", Collections.nCopies(aclsfCdArray.length, "?"));

	String exchange = request.getParameter("exchange");
	String userId = request.getParameter("saveUserId");
	
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	try{

        Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
		
		String wSql = "";
		wSql +=	"	SELECT * 																			"			
			 +  "	FROM (																				"
			 +  "	    SELECT * 																		"
			 +  "	    FROM (																			"
			 +  "	        SELECT 																		"
			 +  "	            PMARKET_CD AS SYMBOL_CD, 												"
			 +  "	            PMARKET_NM AS SYMBOL_DESC, 												"
			 +  "	            ASSET_NM AS SYMBOL_TYPE, 												"
			 +  "	            PMARKET_SRC_CD AS SYMBOL_EXCHANGE, 										"
			 +	"				ASSET_CLSF_CD	AS ASSET_CLSF_CD,										"
			 +  "	            SORT_ORDER AS SORT_ORDER												"
			 +  "	        FROM MIAS.D_PMARKET 														"
			 +  "	        WHERE 1=1 																	"
			 +  "	            AND USE_YN = 'Y' 														"
			 +  "	            AND (UPPER(PMARKET_CD) LIKE '%' || ? || '%'								"
			 +  "	                 OR UPPER(PMARKET_NM) LIKE '%' || ? || '%')							"
			 +  "	            AND UPPER(ASSET_CD) LIKE UPPER('%' || ? || '%')							"
			 +  "	        ORDER BY SORT_ORDER															"
			 +  "	    ) A																				"
			 +  "	    UNION ALL																		"
			 +  "	    SELECT * 																		"
			 +  "	    FROM (																			"
			 +  "	        SELECT 																		"
			 +  "	            CPMARKET_CD AS SYMBOL_CD, 												"
			 +  "	            CPMARKET_NM AS SYMBOL_DESC, 											"
			 +  "	            ASSET_NM AS SYMBOL_TYPE, 												"
			 +  "	            CPMARKET_SRC_CD AS SYMBOL_EXCHANGE, 									"
			 +	"				ASSET_CLSF_CD	AS ASSET_CLSF_CD,										"
			 +  "	            SORT_ORDER AS SORT_ORDER												"
			 +  "	        FROM MIAS.D_CPMARKET 														"
			 +  "	        WHERE 1=1 																	"
			 +  "	            AND USE_YN = 'Y' 														"
			 +  "	            AND (UPPER(CPMARKET_CD) LIKE '%' || ? || '%'							"
			 +  "	                 OR UPPER(CPMARKET_NM) LIKE '%' || ? || '%')						"
			 +  "	            AND UPPER(ASSET_CD) LIKE UPPER('%' || ? || '%')							"
			 +  "	        ORDER BY SORT_ORDER															"
			 +  "	    ) B																				"
			 +  "	)																					"
			 +  "	WHERE 1=1																			"
			 +	"	AND (SYMBOL_EXCHANGE IN (SELECT CODE_CD FROM CODE_TB WHERE CODE_GROUP = 'PRICE_MARKET_SOURCE' AND USE_YN = 'Y')		"
			 +	"		OR UPPER(SYMBOL_EXCHANGE) IN (SELECT GROUP_CODE FROM MIAS2.MTX_GROUP_LINK WHERE USER_CODE = ? GROUP BY GROUP_CODE))	";
		if (aclsfCd != null && !aclsfCd.isEmpty()) {
		wSql +=	"	AND ASSET_CLSF_CD IN ( " + aclsfCdSql + ") 															";
		}
		if(exchange != null && exchange != "") {
		wSql += "	AND SYMBOL_EXCHANGE = ? 															";
		}
		wSql +=	"	AND ROWNUM <= 50																	";

		//out.print(wSql);
        pstmt = conn.prepareStatement(wSql);
        pstmt.setString(1, paramSymbolNm);
		pstmt.setString(2, paramSymbolNm);
		pstmt.setString(3, paramSymbolTy);
		pstmt.setString(4, paramSymbolNm);
		pstmt.setString(5, paramSymbolNm);
		pstmt.setString(6, paramSymbolTy);
		pstmt.setString(7, userId);
		// 파라미터 인덱스 관리에 따라 조건 처리
		int currentIndex = 8;
		if (aclsfCd != null && !aclsfCd.isEmpty()) {
			for (int i = 0; i < aclsfCdArray.length; i++) {
				pstmt.setString(currentIndex, aclsfCdArray[i].trim());
				currentIndex++;
			}
			//pstmt.setString(currentIndex, aclsfCd);
			//currentIndex++;
		}
		if (exchange != null && !exchange.isEmpty()) {
			pstmt.setString(currentIndex, exchange);
			//currentIndex++;
		}
				
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
			JSONObject symbol = new JSONObject();
			symbol.put("symbol", rs.getString("SYMBOL_CD"));
			symbol.put("full_name", rs.getString("SYMBOL_CD"));
			symbol.put("description", rs.getString("SYMBOL_DESC"));
			symbol.put("exchange", rs.getString("SYMBOL_EXCHANGE"));
			symbol.put("ticker", rs.getString("SYMBOL_CD"));
			symbol.put("type", rs.getString("SYMBOL_TYPE"));
			jsonArrayList.add(symbol);
        }
        
        pstmt.close();
        rs.close();
        conn.close();
		
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
        response.getWriter().write(jsonArrayList.toString());
		
    }catch(Exception e){
        response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		//String errorMessage = e.getMessage().replace("\n", "\\n").replace("\r", "\\r");
		String errorMessage = "Occur Exception";
		response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
    }finally{
        try{
            if(rs != null)  rs.close();
            if(pstmt != null)   pstmt.close();
            if(conn != null) conn.close();
        }catch(Exception ex) {
            response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			//String errorMessage = ex.getMessage().replace("\n", "\\n").replace("\r", "\\r");
			String errorMessage = "Occur SQLException";
			response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
        }
    }
	
%>
