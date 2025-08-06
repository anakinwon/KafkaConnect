
drop table if exists customers_sink;
drop table if exists products_sink;
drop table if exists orders_sink;
drop table if exists order_items_sink;

-- 아래 Create Table 스크립트수행.
CREATE TABLE customers_sink (
      customer_id   int          NOT NULL PRIMARY KEY
    , email_address varchar(255) NOT NULL
    , full_name     varchar(255) NOT NULL
) ;

CREATE TABLE products_sink (
      product_id       int           NOT NULL PRIMARY KEY
    , product_name     varchar(255)  NULL
    , product_category varchar(255)  NULL
    , unit_price       decimal(10,0) NULL
) ;

CREATE TABLE orders_sink (
	  order_id       int         NOT NULL PRIMARY KEY
    , order_datetime datetime    NOT NULL
    , customer_id    int         NOT NULL
    , order_status   varchar(10) NOT NULL
    , store_id       int         NOT NULL
) ;

CREATE TABLE order_items_sink (
	  order_id     int            NOT NULL
    , line_item_id int            NOT NULL
    , product_id   int            NOT NULL
    , unit_price   decimal(10, 2) NOT NULL
    , quantity     int            NOT NULL
    , primary key (order_id, line_item_id)
) ;


select * from customers_sink;
select * from products_sink;
select * from order_sinks;
select * from order_items_sink;


select count(*) from customers_sink union all
select count(*) from products_sink union all
select count(*) from orders_sink union all
select count(*) from order_items_sink;



USE oc_sink;

/**
   CDC설정
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
    @source_name   = N'customers_sink',
    @role_name     = NULL,
    @supports_net_changes = 1;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'products_sink',
    @role_name     = NULL,
    @supports_net_changes = 1;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'orders_sink',
    @role_name     = NULL,
    @supports_net_changes = 1;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'order_items_sink',
    @role_name     = NULL,
    @supports_net_changes = 1;


/* 변경 테이블에 대한 액세스를 제어하는 역할 회수. */
EXEC sys.sp_cdc_disable_table
    @source_schema = N'dbo',
    @source_name   = N'customers_sink',
    @capture_instance = N'dbo_customers_sink';

EXEC sys.sp_cdc_disable_table
    @source_schema = N'dbo',
    @source_name   = N'products_sink',
    @capture_instance = N'dbo_products_sink';

EXEC sys.sp_cdc_disable_table
    @source_schema = N'dbo',
    @source_name   = N'orders_sink',
    @capture_instance = N'dbo_orders_sink';

EXEC sys.sp_cdc_disable_table
    @source_schema = N'dbo',
    @source_name   = N'order_items_sink',
    @capture_instance = N'dbo_order_items_sink';



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
