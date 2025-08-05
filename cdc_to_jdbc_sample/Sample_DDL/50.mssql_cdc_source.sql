
drop table if exists customers;
drop table if exists products;
drop table if exists orders;
drop table if exists order_items;

-- 아래 Create Table 스크립트수행.
CREATE TABLE customers (
      customer_id   int          NOT NULL PRIMARY KEY
    , email_address varchar(255) NOT NULL
    , full_name     varchar(255) NOT NULL
) ;

CREATE TABLE products (
      product_id       int           NOT NULL PRIMARY KEY
    , product_name     varchar(255)  NULL
    , product_category varchar(255)  NULL
    , unit_price       decimal(10,0) NULL
) ;

CREATE TABLE orders (
	  order_id       int         NOT NULL PRIMARY KEY
    , order_datetime datetime    NOT NULL
    , customer_id    int         NOT NULL
    , order_status   varchar(10) NOT NULL
    , store_id       int         NOT NULL
) ;

CREATE TABLE order_items (
	  order_id     int            NOT NULL
    , line_item_id int            NOT NULL
    , product_id   int            NOT NULL
    , unit_price   decimal(10, 2) NOT NULL
    , quantity     int            NOT NULL
    , primary key (order_id, line_item_id)
) ;


select * from customers;
select * from products;
select * from orders;
select * from order_items;

/* 테스트 데이터 만드는 프로시저  */


CREATE OR ALTER PROCEDURE PROC_MAKE_DATA
   @P_CNT INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @V_PRD_INQIRE_DTM DATETIME;
    DECLARE @V_PRD_CD VARCHAR(30);

    WHILE @i <= @P_CNT
    BEGIN
        -- 랜덤 시간: 현재 시간으로부터 -0~10일 사이
        SET @V_PRD_INQIRE_DTM = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 10, GETDATE());

        -- 랜덤 상품 코드: PRD00001 ~ PRD99999
        SET @V_PRD_CD = 'PRD' + RIGHT('00000' + CAST(ABS(CHECKSUM(NEWID())) % 99999 + 1 AS VARCHAR), 5);


		insert into oc.dbo.customers (customer_id, email_address, full_name)
			values
		(@i, 'test_01@test.com', 'test_name_01');

		insert into oc.dbo.products (product_id, product_name, product_category, unit_price)
			values
		(@i, @V_PRD_CD,'kind_01', 10000);

		insert into oc.dbo.orders (order_id, order_datetime, customer_id, order_status, store_id)
			values
		(@i, @V_PRD_INQIRE_DTM, @i, '주문완료', 100);

		insert into oc.dbo.order_items (order_id, line_item_id, product_id, unit_price, quantity)
			values
		(@i, @i, @i, 30000, 1);

        SET @i += 1;
    END
END;

EXEC DBO.PROC_MAKE_DATA 1000;


/* 테스트 데이터 만드는 프로시저 실행 */
EXEC oc.dbo.CONNECT_DML_TEST
    @max_customer_id = 100,
    @max_order_id = 100,
    @repeat_cnt = 100,
    @upd_mod = 10;


select count(*) from oc.dbo.customers union all
select count(*) from oc.dbo.products union all
select count(*) from oc.dbo.orders union all
select count(*) from oc.dbo.order_items;

insert into oc.dbo.customers (customer_id, email_address, full_name) values (1, 'test01@test.com', 'test_name_01');
insert into oc.dbo.customers (customer_id, email_address, full_name) values (2, 'test02@test.com', 'test_name_02');
insert into oc.dbo.customers (customer_id, email_address, full_name) values (3, 'test03@test.com', 'test_name_03');

insert into oc.dbo.products (product_id, product_name, product_category, unit_price) values (1,'prdname_01','kind_10',10000);
insert into oc.dbo.products (product_id, product_name, product_category, unit_price) values (2,'prdname_02','kind_20',20000);
insert into oc.dbo.products (product_id, product_name, product_category, unit_price) values (3,'prdname_03','kind_30',30000);

insert into oc.dbo.orders (order_id, order_datetime, customer_id, order_status, store_id)  values (1, getdate(), 1, '주문완료', 100);
insert into oc.dbo.orders (order_id, order_datetime, customer_id, order_status, store_id)  values (2, getdate(), 2, '주문완료', 200);
insert into oc.dbo.orders (order_id, order_datetime, customer_id, order_status, store_id)  values (3, getdate(), 3, '주문완료', 300);

insert into oc.dbo.order_items (order_id, line_item_id, product_id, unit_price, quantity) values (1, 1, 1, 30000, 1);
insert into oc.dbo.order_items (order_id, line_item_id, product_id, unit_price, quantity) values (2, 1, 1, 40000, 2);
insert into oc.dbo.order_items (order_id, line_item_id, product_id, unit_price, quantity) values (3, 1, 1, 50000, 3);


USE oc;
EXEC sys.sp_cdc_enable_db;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'customers',   -- ← 여기에 실제 테이블명
    @role_name     = NULL;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'products',   -- ← 여기에 실제 테이블명
    @role_name     = NULL;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'orders',   -- ← 여기에 실제 테이블명
    @role_name     = NULL;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'order_items',   -- ← 여기에 실제 테이블명
    @role_name     = NULL;



EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Agent XPs', 1;
RECONFIGURE;



SELECT servicename, status_desc
FROM sys.dm_server_services
WHERE servicename LIKE 'SQL Server Agent%';


SELECT SERVERPROPERTY('Edition');



SELECT name, is_cdc_enabled FROM sys.databases WHERE name = 'oc';


SELECT name, is_cdc_enabled FROM sys.databases WHERE name = 'oc';

SELECT name, is_tracked_by_cdc FROM sys.tables WHERE is_tracked_by_cdc = 1;


USE oc;
SELECT is_cdc_enabled FROM sys.databases WHERE name = 'oc';


SELECT name, is_tracked_by_cdc FROM sys.tables WHERE is_tracked_by_cdc = 1;


