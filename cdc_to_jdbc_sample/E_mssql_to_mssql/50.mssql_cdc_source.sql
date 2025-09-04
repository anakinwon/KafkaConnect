
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

/* 데이터 생성 실행 */
EXEC DBO.PROC_MAKE_DATA 100000;


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



USE oc;

CDC설정
USE [db_adm];
/**
   <Database CDC 활성>
     1. 개별 테이블에 대한 캡처 인스턴스를 생성하려면 먼저 데이터베이스에 대한 변경 데이터 캡처를 사용하도록 설정해야 합니다.
 */
EXEC sys.sp_cdc_enable_db;

/* CDC를 사용하도록 설정된 데이터베이스가 삭제되면 변경 데이터 캡처 작업이 자동으로 제거됩니다. */
EXEC sys.sp_cdc_disable_db;

/**
   <Table CDC 활성>
      1. 변경 테이블에 대한 액세스를 제어하는 역할 부여.
 */
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'customers',
    @role_name     = NULL,
    @supports_net_changes = 1;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'products',
    @role_name     = NULL,
    @supports_net_changes = 1;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'orders',
    @role_name     = NULL,
    @supports_net_changes = 1;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'order_items',
    @role_name     = NULL,
    @supports_net_changes = 1;


/* 변경 테이블에 대한 액세스를 제어하는 역할 회수. */
EXEC sys.sp_cdc_disable_table
    @source_schema = N'dbo',
    @source_name   = N'customers',
    @capture_instance = N'dbo_customers';



CDC설정
/**
  <설정 조회>
     1. Database와 Table 모두 CDC가 활성화되어 있어야 하며,
   아래 쿼리를 사용하여 현재의 상태 값을 조회할 수 있다.
   0이 비활성화, 1이 활성화 상태다.
  */

select name
     , is_cdc_enabled
  from sys.databases;

select name
     , is_tracked_by_cdc
  from sys.tables;


/**
  <권한 확인 및 CDC 설정 정보>
      1. CDC가 제대로 활성화되었다면 CDC라는 스키마에 변경 내용이 저장되게 된다.
     Debezium에서 커넥터 설정에 입력될 DB 계정으로 로그인하여 CDC 스키마 및 내부의 테이블에 Select 권한이 제대로 있는지 확인한다.
         아래 쿼리를 사용하여 DB 및 Table에 적용된 CDC 설정을 한 번에 확인하는 방법도 있다.
  *
  */

EXEC sys.sp_cdc_help_change_data_capture;
