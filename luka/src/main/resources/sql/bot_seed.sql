-- Truncate 한 뒤에 이 스크립트를 한 번만 실행하세요.
-- 봇은 BOT_CODE 기준 1행씩만 넣습니다. 성과/거래는 BOT_CODE로 BOT_ID를 찾아 연결합니다.

INSERT INTO DEMO_RAW_DB.RAW.BOT
    (BOT_CODE, BOT_NAME, DESCRIPTION, MODEL_TYPE, STRATEGY_TYPE)
VALUES
    ('trading_buy1_bot', 'trading_buy1_bot', '파도타기', 'GPT', 'Swing'),
    ('macroshield', 'MacroShield', '거시 안정형', 'Claude', 'Macro'),
    ('bookvalue', 'BookValue', '가치투자', 'GPT', 'Value'),
    ('volquant', 'VolQuant', '변동성 퀀트', 'Rule+LLM', 'Quant');

INSERT INTO DEMO_RAW_DB.RAW.BOT_PERF_DAILY
    (BOT_ID, PERF_DATE, DAILY_RETURN, CUM_RETURN)
SELECT b.BOT_ID, CURRENT_DATE(), s.DAILY_RETURN, s.CUM_RETURN
FROM DEMO_RAW_DB.RAW.BOT b
JOIN (
    SELECT COLUMN1 AS BOT_CODE, COLUMN2 AS DAILY_RETURN, COLUMN3 AS CUM_RETURN
    FROM VALUES
        ('macroshield', 9.7, -2.4),
        ('bookvalue', 8.1, -4.0),
        ('trading_buy1_bot', 12.4, -5.1),
        ('volquant', 6.8, -7.8)
) s ON s.BOT_CODE = b.BOT_CODE;

INSERT INTO DEMO_RAW_DB.RAW.BOT_TRADE
    (BOT_ID, SYMBOL, SELECT_REASON, BUY_PRICE, BUY_AT)
SELECT
    b.BOT_ID,
    s.SYMBOL,
    s.SELECT_REASON,
    s.BUY_PRICE,
    DATEADD('day', s.DAYS_AGO, DATE_TRUNC('minute', CURRENT_TIMESTAMP()))
FROM DEMO_RAW_DB.RAW.BOT b
JOIN (
    SELECT
        COLUMN1 AS BOT_CODE,
        COLUMN2 AS SYMBOL,
        COLUMN3 AS SELECT_REASON,
        COLUMN4 AS BUY_PRICE,
        COLUMN5 AS DAYS_AGO
    FROM VALUES
        (
            'trading_buy1_bot',
            'NVDA',
            'LLM 수요와 반도체 상대강도가 함께 유지되어 분할 매수 구간으로 판단했습니다.',
            128.45,
            -2
        ),
        (
            'trading_buy1_bot',
            'SMR',
            '원전 계약 모멘텀은 유효하나 ATM 리스크를 고려해 소량만 편입했습니다.',
            18.32,
            -1
        ),
        (
            'macroshield',
            'QQQ',
            '금리 민감 구간에서 지수 ETF로 위험 노출을 낮추는 편이 낫다고 판단했습니다.',
            492.10,
            -3
        )
) s ON s.BOT_CODE = b.BOT_CODE;

--------------------------------------------

INSERT INTO DEMO_RAW_DB.RAW.BOT
    (BOT_CODE, BOT_NAME, DESCRIPTION, MODEL_TYPE, STRATEGY_TYPE)
VALUES
    ('trading_buy2_bot', 'trading_buy2_bot', '추세 추종형', 'GPT', 'Swing');


INSERT INTO DEMO_RAW_DB.RAW.BOT_PERF_DAILY
    (BOT_ID, PERF_DATE, DAILY_RETURN, CUM_RETURN)
SELECT
    b.BOT_ID,
    CURRENT_DATE(),
    s.DAILY_RETURN,
    s.CUM_RETURN
FROM DEMO_RAW_DB.RAW.BOT b
JOIN (
    SELECT
        COLUMN1 AS BOT_CODE,
        COLUMN2 AS DAILY_RETURN,
        COLUMN3 AS CUM_RETURN
    FROM VALUES
        ('trading_buy2_bot', 10.8, -3.2)
) s
    ON s.BOT_CODE = b.BOT_CODE;


INSERT INTO DEMO_RAW_DB.RAW.BOT_TRADE
    (BOT_ID, SYMBOL, SELECT_REASON, BUY_PRICE, BUY_AT)
SELECT
    b.BOT_ID,
    s.SYMBOL,
    s.SELECT_REASON,
    s.BUY_PRICE,
    DATEADD(
        'day',
        s.DAYS_AGO,
        DATE_TRUNC('minute', CURRENT_TIMESTAMP())
    )
FROM DEMO_RAW_DB.RAW.BOT b
JOIN (
    SELECT
        COLUMN1 AS BOT_CODE,
        COLUMN2 AS SYMBOL,
        COLUMN3 AS SELECT_REASON,
        COLUMN4 AS BUY_PRICE,
        COLUMN5 AS DAYS_AGO
    FROM VALUES
        (
            'trading_buy2_bot',
            'NVDA',
            '기술적 추세와 거래량이 동시에 개선되고 있어 상승 모멘텀이 이어질 가능성이 높다고 판단했습니다.',
            131.20,
            -1
        )
) s
    ON s.BOT_CODE = b.BOT_CODE;