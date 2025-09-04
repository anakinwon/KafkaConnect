
/* Source 테이블 신규 생성 ********************************************************************************************* */
DROP TABLE CUSTOMERS;
DROP TABLE PRODUCTS;
DROP TABLE ORDERS;
DROP TABLE ORDER_ITEMS;

-- 아래 Create Table 스크립트수행.
CREATE TABLE CUSTOMERS (
      CUSTOMER_ID   INT          NOT NULL PRIMARY KEY
    , EMAIL_ADDRESS VARCHAR2(255) NOT NULL
    , FULL_NAME     VARCHAR2(255) NOT NULL
) ;

CREATE TABLE PRODUCTS (
      PRODUCT_ID       INT           NOT NULL PRIMARY KEY
    , PRODUCT_NAME     VARCHAR2(255)  NULL
    , PRODUCT_CATEGORY VARCHAR2(255)  NULL
    , UNIT_PRICE       DECIMAL(10,0) NULL
) ;

CREATE TABLE ORDERS (
	  ORDER_ID       INT         NOT NULL PRIMARY KEY
    , ORDER_DATETIME DATETIME    NOT NULL
    , CUSTOMER_ID    INT         NOT NULL
    , ORDER_STATUS   VARCHAR2(10) NOT NULL
    , STORE_ID       INT         NOT NULL
) ;

CREATE TABLE ORDER_ITEMS (
	  ORDER_ID     INT            NOT NULL
    , LINE_ITEM_ID INT            NOT NULL
    , PRODUCT_ID   INT            NOT NULL
    , UNIT_PRICE   DECIMAL(10, 2) NOT NULL
    , QUANTITY     INT            NOT NULL
    , PRIMARY KEY (ORDER_ID, LINE_ITEM_ID)
) ;


SELECT * FROM CUSTOMERS;
SELECT * FROM PRODUCTS;
SELECT * FROM ORDERS;
SELECT * FROM ORDER_ITEMS;
/* Source 테이블 신규 생성 ********************************************************************************************* */







/* Sink 테이블 신규 생성 *********************************************************************************************** */
DROP TABLE CUSTOMERS_SINK;
DROP TABLE PRODUCTS_SINK;
DROP TABLE ORDERS_SINK;
DROP TABLE ORDER_ITEMS_SINK;

CREATE TABLE CUSTOMERS_SINK (
      CUSTOMER_ID   INT          NOT NULL PRIMARY KEY
    , EMAIL_ADDRESS VARCHAR2(255) NOT NULL
    , FULL_NAME     VARCHAR2(255) NOT NULL
) ;

CREATE TABLE PRODUCTS_SINK (
      PRODUCT_ID       INT           NOT NULL PRIMARY KEY
    , PRODUCT_NAME     VARCHAR2(255)  NULL
    , PRODUCT_CATEGORY VARCHAR2(255)  NULL
    , UNIT_PRICE       DECIMAL(10,0) NULL
) ;

CREATE TABLE ORDERS_SINK (
	  ORDER_ID       INT          NOT NULL PRIMARY KEY
    , ORDER_DATETIME DATE         NOT NULL
    , CUSTOMER_ID    INT          NOT NULL
    , ORDER_STATUS   VARCHAR2(10) NOT NULL
    , STORE_ID       INT          NOT NULL
) ;

CREATE TABLE ORDER_ITEMS_SINK (
	  ORDER_ID     INT            NOT NULL
    , LINE_ITEM_ID INT            NOT NULL
    , PRODUCT_ID   INT            NOT NULL
    , UNIT_PRICE   DECIMAL(10, 2) NOT NULL
    , QUANTITY     INT            NOT NULL
    , PRIMARY KEY (ORDER_ID, LINE_ITEM_ID)
) ;


SELECT * FROM CUSTOMERS_SINK;
SELECT * FROM PRODUCTS_SINK;
SELECT * FROM ORDERS_SINK;
SELECT * FROM ORDER_ITEMS_SINK;
/* Sink 테이블 신규 생성 *********************************************************************************************** */



/* 벌크 테스트 데이터 생성 ********************************************************************************************** */
CREATE OR REPLACE PROCEDURE GENERATE_SAMPLE_DATA (
    p_customer_cnt IN NUMBER,  -- 고객 수 (예: 10000)
    p_product_cnt  IN NUMBER,  -- 상품 수 (예: 5000)
    p_order_cnt    IN NUMBER   -- 주문 수 (예: 10000)
) IS
BEGIN
    -- 1. 고객 생성
    FOR i IN 1 .. p_customer_cnt LOOP
        INSERT INTO CUSTOMERS (CUSTOMER_ID, EMAIL_ADDRESS, FULL_NAME)
        VALUES (
            i,
            'customer' || i || '@example.com',
            'Customer ' || i
        );
    END LOOP;

    -- 2. 상품 생성
    FOR j IN 1 .. p_product_cnt LOOP
        INSERT INTO PRODUCTS (PRODUCT_ID, PRODUCT_NAME, PRODUCT_CATEGORY, UNIT_PRICE)
        VALUES (
            j,
            'Product ' || j,
            CASE MOD(j, 3)
                WHEN 0 THEN 'Food'
                WHEN 1 THEN 'Electronics'
                ELSE 'Clothing'
            END,
            ROUND(DBMS_RANDOM.VALUE(1000, 10000), 0) -- 1000~10000 사이 가격
        );
    END LOOP;

    -- 3. 주문 생성
    FOR k IN 1 .. p_order_cnt LOOP
        INSERT INTO ORDERS (ORDER_ID, ORDER_DATETIME, CUSTOMER_ID, ORDER_STATUS, STORE_ID)
        VALUES (
            k,
            TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 365)), -- 최근 1년 사이 날짜
            TRUNC(DBMS_RANDOM.VALUE(1, p_customer_cnt)), -- 무작위 고객
            CASE MOD(k, 3)
                WHEN 0 THEN 'NEW'
                WHEN 1 THEN 'SHIP'
                ELSE 'DONE'
            END,
            TRUNC(DBMS_RANDOM.VALUE(1, 100)) -- 1~100 사이 매장
        );

        -- 주문 아이템 (1~5개 랜덤)
        DECLARE
            v_item_cnt NUMBER := TRUNC(DBMS_RANDOM.VALUE(1, 6));
        BEGIN
            FOR m IN 1 .. v_item_cnt LOOP
                DECLARE
                    v_prod_id NUMBER := TRUNC(DBMS_RANDOM.VALUE(1, p_product_cnt));
                    v_price   NUMBER;
                BEGIN
                    SELECT UNIT_PRICE INTO v_price FROM PRODUCTS WHERE PRODUCT_ID = v_prod_id;

                    INSERT INTO ORDER_ITEMS (ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY)
                    VALUES (
                        k,
                        m,
                        v_prod_id,
                        v_price,
                        TRUNC(DBMS_RANDOM.VALUE(1, 5)) -- 1~5개 수량
                    );
                END;
            END LOOP;
        END;
    END LOOP;

    COMMIT;
END;
/* 벌크 테스트 데이터 생성 ********************************************************************************************** */

/* 벌크 테스트 데이터 생성 ********************************************************************************************** */
BEGIN
    GENERATE_SAMPLE_DATA(10000, 5000, 10000);
END;
/* 벌크 테스트 데이터 생성 ********************************************************************************************** */



/* 데이터 확인 ******************************************************************************************************** */
SELECT 'CUSTOMERS' AS TNAME  , count(*) from HR.CUSTOMERS UNION ALL
SELECT 'ORDERS' AS TNAME     , count(*) from HR.ORDERS UNION ALL
SELECT 'PRODUCTS' AS TNAME   , count(*) from HR.PRODUCTS UNION ALL
SELECT 'ORDER_ITEMS' AS TNAME, count(*) from HR.ORDER_ITEMS;


SELECT 'CUSTOMERS_SINK' AS TNAME  , count(*) from HR.CUSTOMERS_SINK UNION ALL
SELECT 'ORDERS_SINK' AS TNAME     , count(*) from HR.ORDERS_SINK UNION ALL
SELECT 'PRODUCTS_SINK' AS TNAME   , count(*) from HR.PRODUCTS_SINK UNION ALL
SELECT 'ORDER_ITEMS_SINK' AS TNAME, count(*) from HR.ORDER_ITEMS_SINK;
/* 데이터 확인 ******************************************************************************************************** */





/* 테스트 데이터 생성 ************************************************************************************************** */
INSERT INTO HR.CUSTOMERS (CUSTOMER_ID, EMAIL_ADDRESS, FULL_NAME) VALUES(1, 'test01@test.com', 'test01');
INSERT INTO HR.CUSTOMERS (CUSTOMER_ID, EMAIL_ADDRESS, FULL_NAME) VALUES(2, 'test02@test.com', 'test02');
INSERT INTO HR.CUSTOMERS (CUSTOMER_ID, EMAIL_ADDRESS, FULL_NAME) VALUES(3, 'test03@test.com', 'test03');
INSERT INTO HR.CUSTOMERS (CUSTOMER_ID, EMAIL_ADDRESS, FULL_NAME) VALUES(4, 'test04@test.com', 'test04');
INSERT INTO HR.CUSTOMERS (CUSTOMER_ID, EMAIL_ADDRESS, FULL_NAME) VALUES(5, 'test05@test.com', 'test05');

INSERT INTO HR.ORDERS (ORDER_ID, ORDER_DATETIME, CUSTOMER_ID, ORDER_STATUS, STORE_ID) VALUES(1, SYSDATE, 1, '10', 100);
INSERT INTO HR.ORDERS (ORDER_ID, ORDER_DATETIME, CUSTOMER_ID, ORDER_STATUS, STORE_ID) VALUES(2, SYSDATE, 2, '20', 200);
INSERT INTO HR.ORDERS (ORDER_ID, ORDER_DATETIME, CUSTOMER_ID, ORDER_STATUS, STORE_ID) VALUES(3, SYSDATE, 3, '30', 300);
INSERT INTO HR.ORDERS (ORDER_ID, ORDER_DATETIME, CUSTOMER_ID, ORDER_STATUS, STORE_ID) VALUES(4, SYSDATE, 4, '40', 400);
INSERT INTO HR.ORDERS (ORDER_ID, ORDER_DATETIME, CUSTOMER_ID, ORDER_STATUS, STORE_ID) VALUES(5, SYSDATE, 5, '50', 500);


INSERT INTO HR.PRODUCTS (PRODUCT_ID, PRODUCT_NAME, PRODUCT_CATEGORY, UNIT_PRICE) VALUES(1, '상품1', '분류1', 10000);
INSERT INTO HR.PRODUCTS (PRODUCT_ID, PRODUCT_NAME, PRODUCT_CATEGORY, UNIT_PRICE) VALUES(2, '상품2', '분류2', 20000);
INSERT INTO HR.PRODUCTS (PRODUCT_ID, PRODUCT_NAME, PRODUCT_CATEGORY, UNIT_PRICE) VALUES(3, '상품3', '분류3', 30000);
INSERT INTO HR.PRODUCTS (PRODUCT_ID, PRODUCT_NAME, PRODUCT_CATEGORY, UNIT_PRICE) VALUES(4, '상품4', '분류4', 40000);
INSERT INTO HR.PRODUCTS (PRODUCT_ID, PRODUCT_NAME, PRODUCT_CATEGORY, UNIT_PRICE) VALUES(5, '상품5', '분류5', 50000);


INSERT INTO HR.ORDER_ITEMS (ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY) VALUES(1, 1, 1, 10000, 10);
INSERT INTO HR.ORDER_ITEMS (ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY) VALUES(2, 2, 2, 20000, 20);
INSERT INTO HR.ORDER_ITEMS (ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY) VALUES(3, 3, 3, 30000, 30);
INSERT INTO HR.ORDER_ITEMS (ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY) VALUES(4, 4, 4, 40000, 40);
INSERT INTO HR.ORDER_ITEMS (ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY) VALUES(5, 5, 5, 50000, 50);
/* 테스트 데이터 생성 ************************************************************************************************** */
