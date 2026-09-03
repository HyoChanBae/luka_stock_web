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
	
	// 심볼 빈값 체크
    if (symbol == null || symbol.trim().isEmpty()) {
        response.setContentType("application/json");
        response.getWriter().write("{\"status\":\"error\", \"message\":\"Symbol is required.\"}");
        return;
    }
	
    List<String> tokenList = new ArrayList<>();

    Pattern allPattern = Pattern.compile("[\\+\\-\\*\\/\\(\\)]|[a-zA-Z_][a-zA-Z0-9_]*|\\d+");
    Matcher allMatcher = allPattern.matcher(symbol);

    while (allMatcher.find()) {
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

    String inSymbol = "";
    List<String> symbols = new ArrayList<>();
	
    for (String token : tokenList) {
        if (token.matches("[a-zA-Z_][a-zA-Z0-9_]*") && !token.matches("\\d+")) {
            symbols.add("UPPER('" + token + "')");
        }
    }
	
    if (!symbols.isEmpty()) {
        inSymbol = String.join(", ", symbols);
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet existsRs = null;
    ResultSet rs = null;

    try {
        Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

		String wSql = " SELECT CASE WHEN COUNT(*) = " + symbols.size() + " THEN 'Y' ELSE 'N' END AS IS_SYMBOL	" + 
					  " FROM (  SELECT 																			" +	
					  "				DISTINCT T1.ESTI_FCHARGE_CD AS SYMBOL_NM,									" +	
					  "				ESTI_FCHARGE_NM AS SYMBOL_DESC,												" +	
					  "				UPPER(CARGO_NM) AS SYMBOL_TYPE,												" +	
					  "				'RPA' AS SYMBOL_EXCHANGE,													" +	
					  "				'예상운임' AS GUBUN															" +	
					  "			FROM MIAS.D_AGRO_ESTI_FCHARGE T1												" +	
					  "			UNION ALL																		" +	
					  "			SELECT DISTINCT T1.PMARKET_CD AS SYMBOL_NM,										" +	
					  "				T1.PMARKET_DESC AS SYMBOL_DESC,												" +	
					  "				UPPER(T1.ASSET_NM) AS SYMBOL_TYPE,											" +	
					  "				T1.PMARKET_SRC_CD AS SYMBOL_EXCHANGE,										" +	
					  "				'식량' AS GUBUN																" +	
					  "			FROM MIAS.D_PMARKET T1															" +	
					  "			WHERE 1 = 1																		" +	
					  "			  AND  T1.AGRO_DIV_NM IS NOT NULL												" +
					  "		  )	B																				" +	
					  " WHERE 1=1																				" +	
					  " AND UPPER(SYMBOL_NM) IN (	" + inSymbol + ")											";
		
        pstmt = conn.prepareStatement(wSql);
        existsRs = pstmt.executeQuery();
		
        if(existsRs.next()) {
            String symbolFlag = existsRs.getString("IS_SYMBOL");
            
            if (symbolFlag.equals("Y")) {
                String wSql2 = 	" SELECT * FROM (									" +	
								"	SELECT 											" +	
								"		DISTINCT T1.ESTI_FCHARGE_CD AS SYMBOL_NM,	" +
								"		ESTI_FCHARGE_NM AS SYMBOL_DESC,				" +	
								"		UPPER(CARGO_NM) AS SYMBOL_TYPE,				" +	
								"		'RPA' AS SYMBOL_EXCHANGE,					" +	
								"		'예상운임' AS GUBUN							" +
								"	FROM MIAS.D_AGRO_ESTI_FCHARGE T1				" +	
								"	UNION ALL										" +	
								"	SELECT DISTINCT T1.PMARKET_CD AS SYMBOL_NM,		" +	
								"		T1.PMARKET_DESC AS SYMBOL_DESC,				" +	
								"		UPPER(T1.ASSET_NM) AS SYMBOL_TYPE,			" +	
								"		T1.PMARKET_SRC_CD AS SYMBOL_EXCHANGE,		" +	
								"		ASSET_CLSF_CD AS GUBUN						" +
								"	FROM MIAS.D_PMARKET T1							" +	
								"	WHERE 1 = 1										" +	
								"	  AND  T1.AGRO_DIV_NM IS NOT NULL				" +	
								" ) B												" + 
								" WHERE 1=1 										" +
								"	AND UPPER(SYMBOL_NM) = UPPER(?)					";
                
                pstmt.close(); // 이전 pstmt 닫기
                pstmt = conn.prepareStatement(wSql2);
				pstmt.setString(1, symbol);
                rs = pstmt.executeQuery();
				//out.println(wSql2 + "	symbol :::: " + symbol);
				
				JSONObject symbolInfo = new JSONObject();
				
                symbolInfo.put("session", "24x7");
                symbolInfo.put("timezone", "Asia/Seoul");
                symbolInfo.put("minmov", 1);
                symbolInfo.put("pricescale", 100);
                symbolInfo.put("has_intraday", true);    //1분, 30분 단위 데이터 지원
				
                if (rs.next()) {
					symbolInfo.put("symbol", rs.getString("SYMBOL_NM"));
					symbolInfo.put("name", rs.getString("SYMBOL_NM"));
					symbolInfo.put("ticker", rs.getString("SYMBOL_NM"));
					
                    symbolInfo.put("description", rs.getString("SYMBOL_DESC"));
                    symbolInfo.put("exchange", rs.getString("SYMBOL_EXCHANGE"));
                    symbolInfo.put("type", rs.getString("SYMBOL_TYPE"));
                }else {
					symbolInfo.put("symbol", symbol);
					symbolInfo.put("name", symbol);
					symbolInfo.put("ticker", symbol);
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
		String errorMessage = e.getMessage().replace("\n", "\\n").replace("\r", "\\r");
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
			String errorMessage = ex.getMessage().replace("\n", "\\n").replace("\r", "\\r");
			response.getWriter().write("{\"status\":\"error\", \"message\":\"" + errorMessage + "\"}");
        }
    }
%>