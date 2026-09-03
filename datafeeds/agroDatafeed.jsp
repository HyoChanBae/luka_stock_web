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
	String resolution = request.getParameter("resolution");
	//out.println("Received Symbol: " + symbol);
	
	//입력된 symbol 값 데이터 조회
	List<String> tokenList = new ArrayList<>();
	Pattern allPattern = Pattern.compile("[\\+\\-\\*\\/\\(\\)]|[a-zA-Z_][a-zA-Z0-9_]*|\\d+");
	Matcher allMatcher = allPattern.matcher(symbol);
	
	while(allMatcher.find()) {
		//tokenList.add(allMatcher.group());
		//String value  = allMatcher.group() != null ? new String(allMatcher.group()) : null; 
		String value = null; 
		Object resultValue = allMatcher.group(); 
	    // 값이 null이 아니고 문자열일 경우에만 처리
	    if (resultValue instanceof String && resultValue != null) {
	    	value = new String((String) resultValue); 
	    } 
     	//tokenList.add(value);
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
		
		String 	wSql  = "	SELECT "	;
				wSql +=	"		TO_TIMESTAMP(TO_DATE(T1.BASE_DT))+0.50 AS BASE_DT, "; 
				for(int i=0; i<tokenList.size(); i++) {
					//String token = tokenList.get(i);
					//String token  = tokenList.get(i) != null ? new String(tokenList.get(i)) : null; 
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
						wSql += "SUM(CASE WHEN UPPER(T1.PMARKET_CD) = UPPER('" + token + "')";
						wSql += "		THEN T1.CD_PRC ELSE 0 END )";
						if(inSymbol == "") {
							inSymbol += "UPPER('" + token + "')";
						}else {
							inSymbol += ", UPPER('" + token + "')";
						}
						inSymbolList.add(token); 
					}else {
						wSql += token;
					}
				}
 
				int symbolCnt = inSymbolList.size();
				String placeholders = String.join(",", Collections.nCopies(symbolCnt, "?"));
				
				wSql += " AS PRICE											";
				wSql +=	"	FROM MIAS.F_AGRO_PMARKET_SUM T1			";
				wSql +=	"	 LEFT OUTER JOIN MIAS.D_AGRO_ESTI_FCHARGE T2	";
				wSql +=	"		ON  T1.PMARKET_CD = T2.ESTI_FCHARGE_CD		";
				wSql +=	"	 LEFT OUTER JOIN MIAS.D_PMARKET T3				";
				wSql +=	"		ON  T1.PMARKET_CD = T3.PMARKET_CD			";
				wSql +=	"	WHERE 1 = 1										";
				wSql +=	"		AND (T1.PMARKET_SRC_CD = 'RPA' OR T3.AGRO_DIV_NM IS NOT NULL)	";
				wSql +=	"		AND UPPER(T1.PMARKET_CD) IN (" + placeholders + ")";
				wSql +=	"		AND T1.BASE_DT BETWEEN ? AND ?					";
				wSql +=	"	GROUP BY T1.BASE_DT	";
				wSql +=	"	ORDER BY T1.BASE_DT	";
		
		pstmt = conn.prepareStatement(wSql); 
		
		List<String> copiedList = new ArrayList<>(inSymbolList);  
		for (int i = 0; i < symbolCnt; i++) { 
			String param = null; 
		    Object resultValue = copiedList.get(i); 
		    // 값이 null이 아니고 문자열일 경우에만 처리
		    if (resultValue instanceof String && resultValue != null) {
		    	param = new String((String) resultValue);
		    } 
		    //pstmt.setString(i + 1, inSymbolList.get(i).toUpperCase());  // 대문자로 변환하여 바인딩
		    pstmt.setString(i + 1, param.toUpperCase());  // 대문자로 변환하여 바인딩
		}  
		pstmt.setString(1+symbolCnt, fromStr);
		pstmt.setString(2+symbolCnt, toStr); 
		
        rs = pstmt.executeQuery();
		//out.println(wSql);
        
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
			wSql  = "	SELECT "	;
			wSql +=	"		TO_TIMESTAMP(TO_DATE(MAX(T1.BASE_DT))) AS NEXT_TIME ";
			wSql +=	"	FROM MIAS.F_AGRO_PMARKET_SUM T1			";
			wSql +=	"	 LEFT OUTER JOIN MIAS.D_AGRO_ESTI_FCHARGE T2	";
			wSql +=	"		ON  T1.PMARKET_CD = T2.ESTI_FCHARGE_CD		";
			wSql +=	"	 LEFT OUTER JOIN MIAS.D_PMARKET T3				";
			wSql +=	"		ON  T1.PMARKET_CD = T3.PMARKET_CD			";
			wSql +=	"	WHERE 1 = 1										";
			wSql +=	"		AND (T1.PMARKET_SRC_CD = 'RPA' OR T3.AGRO_DIV_NM IS NOT NULL)	";
			wSql +=	"		AND UPPER(T1.PMARKET_CD) IN (" + placeholders + ")";
			wSql +=	"		AND T1.BASE_DT < ? 		";
		
			pstmt = conn.prepareStatement(wSql);
			
			for (int i = 0; i < symbolCnt; i++) { 
				String param = null; 
			    Object resultValue = inSymbolList.get(i); 
			    // 값이 null이 아니고 문자열일 경우에만 처리
			    if (resultValue instanceof String && resultValue != null) {
			    	param = new String((String) resultValue); // 방어적 복사하여 userCode 생성
			    } 
			    //pstmt.setString(i + 1, inSymbolList.get(i).toUpperCase());  // 대문자로 변환하여 바인딩
			    pstmt.setString(i + 1, param.toUpperCase());  // 대문자로 변환하여 바인딩
			} 
			pstmt.setString(1+symbolCnt, fromStr); 
			
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
