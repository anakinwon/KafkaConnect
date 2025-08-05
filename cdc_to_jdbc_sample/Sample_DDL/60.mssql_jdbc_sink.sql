
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
EXEC sys.sp_cdc_enable_db;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'customers_sink',   -- ← 여기에 실제 테이블명
    @role_name     = NULL;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'products_sink',   -- ← 여기에 실제 테이블명
    @role_name     = NULL;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'orders_sink',   -- ← 여기에 실제 테이블명
    @role_name     = NULL;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'order_items_sink',   -- ← 여기에 실제 테이블명
    @role_name     = NULL;
