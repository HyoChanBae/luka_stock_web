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
    String userId = request.getParameter("saveUserId");
	String aclsfCd = request.getParameter("assetClsfCd");
	
	// 작은따옴표와 공백 제거 후 배열로 변환
	String[] aclsfCdArray = aclsfCd.replace("'", "").split(",\\s*");

	// Placeholder 생성
	String aclsfCdSql = String.join(", ", Collections.nCopies(aclsfCdArray.length, "?"));
	
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
    List<String> inSymbolList = new ArrayList<>();
	
    for (String token : tokenList) {
        if (token.matches("[a-zA-Z_][a-zA-Z0-9_]*") && !token.matches("\\d+")) {
            inSymbolList.add(token); 
        }
    }
	
    int symbolCnt = inSymbolList.size();
	String placeholders = String.join(",", Collections.nCopies(symbolCnt, "?"));

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet existsRs = null;
    ResultSet rs = null;

    try {
        Class.forName(driver);
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

		String wSql = " SELECT CASE WHEN COUNT(*) = " + symbolCnt + " THEN 'Y' ELSE 'N' END AS IS_SYMBOL 	" +
					  "	FROM (																				" +
					  "	SELECT PMARKET_CD AS SYMBOL_CD, PMARKET_SRC_CD AS EXCHANGE, ASSET_CLSF_CD			" +
					  "	FROM MIAS.D_PMARKET																	" +
					  "	WHERE 1=1																			" +
					  "	AND USE_YN = 'Y'																	" +
					  "	AND UPPER(PMARKET_CD) IN ( " + placeholders + ")									" +
					  "	UNION ALL																			" +
					  "	SELECT CPMARKET_CD AS SYMBOL_CD, CPMARKET_SRC_CD AS EXCHANGE, ASSET_CLSF_CD			" +
					  "	FROM MIAS.D_CPMARKET																" +
					  "	WHERE 1=1																			" +
					  "	AND USE_YN = 'Y'																	" +
					  "	AND UPPER(CPMARKET_CD) IN (" + placeholders + ")									" +
					  "	)																					" +
					  "	WHERE 1=1																			" +
					  "	AND (EXCHANGE IN (SELECT CODE_CD FROM CODE_TB WHERE CODE_GROUP = 'PRICE_MARKET_SOURCE' AND USE_YN ='Y')	" +
					  "	OR UPPER(EXCHANGE) IN (SELECT GROUP_CODE FROM MIAS2.MTX_GROUP_LINK WHERE USER_CODE = ? GROUP BY GROUP_CODE))	";
		if (aclsfCd != null && !aclsfCd.isEmpty()) {
			wSql +=	"	AND ASSET_CLSF_CD IN ( " + aclsfCdSql + ")	";
		}
		
        pstmt = conn.prepareStatement(wSql);
		for (int i = 0; i < symbolCnt; i++) { 
		    pstmt.setString(i + 1, inSymbolList.get(i).toUpperCase());  // 대문자로 변환하여 바인딩
		}
		
		int j=0;
		for (int i = symbolCnt; i < (symbolCnt*2); i++) { 
		    pstmt.setString(i + 1, inSymbolList.get(j).toUpperCase());  // 대문자로 변환하여 바인딩
			j++;
		}
		pstmt.setString(1+(symbolCnt*2), userId);
		
		int currentIndex = 2+(symbolCnt*2);
		if (aclsfCd != null && !aclsfCd.isEmpty()) {
			for (int i = 0; i < aclsfCdArray.length; i++) {
				pstmt.setString(currentIndex, aclsfCdArray[i].trim());
				currentIndex++;
			}
			//pstmt.setString(2+(symbolCnt*2), assetClsfCd);
		}
        existsRs = pstmt.executeQuery();
		
        if(existsRs.next()) {
            String symbolFlag = existsRs.getString("IS_SYMBOL");
            
            if (symbolFlag.equals("Y")) {
                String wSql2 = 	" SELECT 								" + 
								"	PMARKET_CD AS SYMBOL_CD,			" + 
								"	PMARKET_NM AS SYMBOL_DESC,			" + 
								"	ASSET_NM AS SYMBOL_TYPE,			" + 
								"	PMARKET_SRC_CD AS SYMBOL_EXCHANGE	" + 
								" FROM MIAS.D_PMARKET					" + 
								" WHERE 1=1								" + 
								" AND PMARKET_CD = ?					" + 
								" UNION ALL								" + 
								" SELECT 								" + 
								"	CPMARKET_CD AS SYMBOL_CD,			" + 
								"	CPMARKET_NM AS SYMBOL_DESC,			" + 
								"	ASSET_NM AS SYMBOL_TYPE,			" + 
								"	CPMARKET_SRC_CD AS SYMBOL_EXCHANGE	" + 
								" FROM MIAS.D_CPMARKET					" + 
								" WHERE 1=1								" + 
								" AND CPMARKET_CD = ?					";
                
                pstmt.close(); // 이전 pstmt 닫기
                pstmt = conn.prepareStatement(wSql2);
				pstmt.setString(1, symbol);
				pstmt.setString(2, symbol);
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