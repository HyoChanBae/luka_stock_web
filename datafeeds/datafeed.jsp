<%@page import="org.json.simple.*"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="java.util.regex.Pattern"%>
<%@ include file="../../dbConnect.jsp" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%

	request.setCharacterEncoding("UTF-8");
	
	JSONArray jsonArrayList = new JSONArray();   // JSONArray 생성

	String symbol = request.getParameter("symbol");
	String aclsfCd = request.getParameter("assetClsfCd");
	// 작은따옴표와 공백 제거 후 배열로 변환
	String[] aclsfCdArray = aclsfCd.replace("'", "").split(",\\s*");
	// Placeholder 생성
	String aclsfCdSql = String.join(", ", Collections.nCopies(aclsfCdArray.length, "?"));
	
	//입력된 symbol 값 데이터 조회
	List<String> tokenList = new ArrayList<>();
	Pattern allPattern = Pattern.compile("[\\+\\-\\*\\/\\(\\)]|[a-zA-Z_][a-zA-Z0-9_]*|\\d+");
	Matcher allMatcher = allPattern.matcher(symbol);
	
	while(allMatcher.find()) {
		String value = null; 
		Object resultValue = allMatcher.group(); 
	    // 값이 null이 아니고 문자열일 경우에만 처리
	    if (resultValue instanceof String && resultValue != null) {
	    	value = new String((String) resultValue); 
	    } 
	    // 값이 비어 있지 않으면 방어적으로 복사 후 추가
		if (value != null && !value.isEmpty()) {
		    List<String> tempTokenList = new ArrayList<>(tokenList); // 기존 리스트 복사
		    tempTokenList.add(value); // 복사본에 안전한 값을 추가
		    tokenList = Collections.unmodifiableList(tempTokenList); // 불변 리스트로 재할당
		}
	}
	
	long from  = Long.parseLong(request.getParameter("from"));
	long to = Long.parseLong(request.getParameter("to"));
	
	Date fromDate = new Date(from * 1000);
    Date toDate = new Date(to * 1000);
	
	SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
    String fromStr = format.format(fromDate);
	String toStr = format.format(toDate);
	
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
		
	try{		
        Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
		String inSymbol = "";
		List<String> inSymbolList = new ArrayList<>();
		List<String> copiedtokenList = new ArrayList<>(tokenList);  
		
		String 	wSql  = " SELECT BASE_DT, SUM(PRICE) AS PRICE FROM (			";
				wSql += "	SELECT 												";
				wSql +=	"		TO_TIMESTAMP(TO_DATE(BASE_DT))+0.50 AS BASE_DT, "; 
				wSql +=	"		ASSET_CLSF_CD, 									"; 
				for(int i=0; i<tokenList.size(); i++) {
					String token = null; 
					Object resultValue = copiedtokenList.get(i); 
				    // 값이 null이 아니고 문자열일 경우에만 처리
				    if (resultValue instanceof String && resultValue != null) {
				    	token = new String((String) resultValue);
				    }
					//심볼값인지 확인
					Pattern pattern = Pattern.compile("[a-zA-Z_][a-zA-Z0-9_]*");
					Matcher matcher = pattern.matcher(token);
					
					if(matcher.matches() && !token.matches("\\d+")) {
						wSql += "SUM(CASE WHEN UPPER(PMARKET_CD) = UPPER('" + token + "')";
						wSql += "		THEN CD_PRC ELSE 0 END )";
						inSymbolList.add(token); 
					}else {
						wSql += token;
					}
				}
				 
				int symbolCnt = inSymbolList.size();
				String placeholders = String.join(",", Collections.nCopies(symbolCnt, "?"));
				
				wSql += " 		AS PRICE										";
				wSql +=	"	FROM MIAS.F_DLY_PMARKET_SUM 						";
				wSql +=	"	WHERE 1=1											";
				wSql +=	"		AND UPPER(PMARKET_CD) IN (" + placeholders + ")	";
				wSql +=	"		AND BASE_DT BETWEEN ? AND ?						";
				wSql +=	"	GROUP BY BASE_DT, ASSET_CLSF_CD						";
				wSql += "	UNION ALL 											";
				wSql += "	SELECT 												";
				wSql +=	"		TO_TIMESTAMP(TO_DATE(BASE_DT))+0.50 AS BASE_DT, "; 
				wSql +=	"		ASSET_CLSF_CD, 									"; 
				for(int i=0; i<tokenList.size(); i++) {
					String token = null; 
					Object resultValue = copiedtokenList.get(i); 
				    // 값이 null이 아니고 문자열일 경우에만 처리
				    if (resultValue instanceof String && resultValue != null) {
				    	token = new String((String) resultValue);
				    }
					//심볼값인지 확인
					Pattern pattern = Pattern.compile("[a-zA-Z_][a-zA-Z0-9_]*");
					Matcher matcher = pattern.matcher(token);
					
					if(matcher.matches() && !token.matches("\\d+")) {
						wSql += "SUM(CASE WHEN UPPER(CPMARKET_CD) = UPPER('" + token + "')";
						wSql += "		THEN CD_PRC ELSE 0 END )";
					}else {
						wSql += token;
					}
				}
				
				wSql += " 		AS PRICE										";
				wSql +=	"	FROM MIAS.F_DLY_CPMARKET_SUM 						";
				wSql +=	"	WHERE 1=1											";
				wSql +=	"		AND UPPER(CPMARKET_CD) IN (" + placeholders + ")";
				wSql +=	"		AND BASE_DT BETWEEN ? AND ?						";
				wSql +=	"	GROUP BY BASE_DT, ASSET_CLSF_CD						";
				wSql += "	) 													";
				wSql += " WHERE 1=1												";
				if (aclsfCd != null && !aclsfCd.isEmpty()) {
					wSql +=	"	AND ASSET_CLSF_CD IN ( " + aclsfCdSql + ")	";
				}
				wSql += " GROUP BY BASE_DT ORDER BY BASE_DT					";

		pstmt = conn.prepareStatement(wSql);
		
		for (int i = 0; i < symbolCnt; i++) { 
		    pstmt.setString(i + 1, inSymbolList.get(i).toUpperCase());  // 대문자로 변환하여 바인딩
		}
		
		pstmt.setString(1+symbolCnt, fromStr);		
		pstmt.setString(2+symbolCnt, toStr);
		
		int j=0;
		for (int i = 3+symbolCnt; i < 3+(symbolCnt*2); i++) { 
		    pstmt.setString(i, inSymbolList.get(j).toUpperCase());  // 대문자로 변환하여 바인딩
			j++;
		}
		
		pstmt.setString(3+(symbolCnt*2), fromStr);
		pstmt.setString(4+(symbolCnt*2), toStr);
		
		int currentIndex = 5+(symbolCnt*2);
		if (aclsfCd != null && !aclsfCd.isEmpty()) {
			for (int i = 0; i < aclsfCdArray.length; i++) {
				pstmt.setString(currentIndex, aclsfCdArray[i].trim());
				currentIndex++;
			}
			//pstmt.setString(5+(symbolCnt*2), assetClsfCd);
		}
		
        rs = pstmt.executeQuery();
		
        while(rs.next()) {
			Date time = rs.getTimestamp("BASE_DT");
			double price = rs.getDouble("PRICE");
			
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("time", time.getTime());
			jsonObject.put("low", price);
			jsonObject.put("high", price);
			jsonObject.put("open", price);
			jsonObject.put("close", price);
						
			jsonArrayList.add(jsonObject);
        }
        
        pstmt.close();
        rs.close();
		
		String jsonResponse = "";
		if(jsonArrayList.size() == 0) {
			wSql  = "	SELECT MAX(NEXT_TIME) FROM (								";
			wSql += "	SELECT 														";
			wSql +=	"		TO_TIMESTAMP(TO_DATE(MAX(BASE_DT))) AS NEXT_TIME 		";
			wSql +=	"	FROM MIAS.F_DLY_PMARKET_SUM 								";
			wSql +=	"	WHERE 1=1 													";
			wSql +=	"		AND UPPER(PMARKET_CD) IN (" + placeholders + ")			";
			wSql +=	"		AND BASE_DT < ? 										";
			wSql += "	UNION ALL													";
			wSql += "	SELECT 														";	
			wSql +=	"		TO_TIMESTAMP(TO_DATE(MAX(BASE_DT))) AS NEXT_TIME		";
			wSql +=	"	FROM MIAS.F_DLY_CPMARKET_SUM								";
			wSql +=	"	WHERE 1=1 													";
			wSql +=	"		AND UPPER(CPMARKET_CD) IN (" + placeholders + ")		";
			wSql +=	"		AND BASE_DT < ? 		)								";
		
			pstmt = conn.prepareStatement(wSql);
			
			for (int i = 0; i < symbolCnt; i++) { 
			    pstmt.setString(i + 1, inSymbolList.get(i).toUpperCase());  // 대문자로 변환하여 바인딩
			} 
			pstmt.setString(1+symbolCnt, fromStr);
			
			j=0;
			for (int i = 2+symbolCnt; i < 2+(symbolCnt*2); i++) { 
			    pstmt.setString(i, inSymbolList.get(j).toUpperCase());  // 대문자로 변환하여 바인딩
			}
			
			pstmt.setString(2+(symbolCnt*2), fromStr);
			
			rs = pstmt.executeQuery();
			
			JSONObject jsonObject = new JSONObject();
			if (rs.next()) {
				Date time = rs.getTimestamp("NEXT_TIME");
				if (time != null) {
					jsonObject.put("status", "nextData");
					jsonObject.put("nextTime", time.getTime());
				} else {
					jsonObject.put("status", "noData");
				}
			} else {
				jsonObject.put("status", "noData");
			}
			
			pstmt.close();
			rs.close();
			
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
