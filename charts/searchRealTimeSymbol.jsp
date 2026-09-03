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
	String assetClsfCd = request.getParameter("assetClsfCd");
	String exchange = request.getParameter("exchange");
	
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	try{

        Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

		String 	wSql  = " SELECT * FROM (							";
				wSql +=	"	SELECT 									";
				wSql +=	"		PMARKET_CD 		AS SYMBOL_CD, 		";
				wSql +=	"		PMARKET_NM 		AS SYMBOL_DESC,		";
				wSql +=	"		ASSET_NM		AS SYMBOL_TYPE,		";
				wSql += "		PMARKET_SRC_CD	AS SYMBOL_EXCHANGE 	";
				wSql +=	"	FROM MIAS.D_PMARKET 					";
				wSql +=	"	WHERE 1=1 								";
				wSql +=	"	AND USE_YN = 'Y' 						";
				wSql += "	AND BPIPE_YN= 'Y'						";
				wSql +=	"	AND (UPPER(PMARKET_CD) LIKE TRIM(UPPER('%' || ?  || '%' ))";
				wSql +=	"		OR UPPER(PMARKET_NM) LIKE TRIM(UPPER('%' || ?  || '%' )))";
				wSql +=	"	AND UPPER(ASSET_CD) LIKE TRIM(UPPER('%' || ?  || '%' ))";
				
				if(assetClsfCd != null && assetClsfCd != "") {
					wSql +=	"		AND ASSET_CLSF_CD = ? 			";
				}
				
				if(exchange != null && exchange != "") {
					wSql += "		AND PMARKET_SRC_CD = ?			";
				}
				wSql +=	"	ORDER BY SORT_ORDER						";
				wSql += " 	) WHERE ROWNUM < 50						";
				

		//out.print(wSql);
        pstmt = conn.prepareStatement(wSql);
        pstmt.setString(1, paramSymbolNm);
		pstmt.setString(2, paramSymbolNm);
		pstmt.setString(3, paramSymbolTy);
		// 파라미터 인덱스 관리에 따라 조건 처리
		int currentIndex = 4;
		if (assetClsfCd != null && !assetClsfCd.isEmpty()) {
			pstmt.setString(currentIndex, assetClsfCd);
			currentIndex++;
		}
		if (exchange != null && !exchange.isEmpty()) {
			pstmt.setString(currentIndex, exchange);
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
		String errorMessage = e.getMessage().replace("\n", "\\n").replace("\r", "\\r");
		response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
    }finally{
        try{
            if(rs != null)  rs.close();
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
